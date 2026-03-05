// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title StakedTitan (sTITAN)
 * @author Berke (pzzaworks)
 * @notice Liquid staking token for TITAN with auto-compounding rewards and governance voting power
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Nonces.sol";

/**
 * @title StakedTitan
 * @notice Stake TITAN and receive sTITAN - a liquid staking token with auto-compounding and voting power
 *
 * How it works:
 * - Deposit TITAN → receive sTITAN based on current exchange rate
 * - sTITAN holders automatically have governance voting power
 * - Exchange rate increases over time based on rewardRate
 * - Withdraw sTITAN → receive TITAN at current exchange rate
 */
contract StakedTitan is ERC20, ERC20Permit, ERC20Votes, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice The TITAN token
    IERC20 public immutable titan;

    /// @notice Minimum deposit amount to prevent rounding issues
    uint256 public constant MINIMUM_DEPOSIT = 1e15; // 0.001 TITAN

    /// @notice Virtual offset to prevent first depositor attack (similar to OpenZeppelin ERC4626)
    /// @dev Added to both assets and shares in exchange rate calculation
    uint256 private constant VIRTUAL_OFFSET = 1e8;

    /// @notice Reward rate per second per total staked (scaled by 1e18)
    uint256 public rewardRate;

    /// @notice Last time rewards were accrued
    uint256 public lastRewardTime;

    /// @notice Virtual total TITAN (actual balance + accrued rewards)
    uint256 public totalTitanAccrued;

    /// @notice Whether deposits are paused
    bool public depositsPaused;

    /// @notice Whether withdrawals are paused
    bool public withdrawalsPaused;

    /// @notice Emitted when TITAN is deposited
    event Deposited(address indexed user, uint256 titanAmount, uint256 sTitanAmount);

    /// @notice Emitted when sTITAN is withdrawn
    event Withdrawn(address indexed user, uint256 sTitanAmount, uint256 titanAmount);

    /// @notice Emitted when rewards are accrued
    event RewardsAccrued(uint256 amount, uint256 newExchangeRate);

    /// @notice Emitted when reward rate is updated
    event RewardRateUpdated(uint256 oldRate, uint256 newRate);

    /// @notice Emitted when rewards are deposited
    event RewardsDeposited(address indexed from, uint256 amount);

    /// @notice Emitted when pause state changes
    event DepositsPausedChanged(bool paused);
    event WithdrawalsPausedChanged(bool paused);

    /// @notice Error definitions
    error InvalidToken();
    error DepositTooSmall();
    error InsufficientBalance();
    error DepositsPaused();
    error WithdrawalsPaused();
    error ZeroAmount();
    error ZeroShares();
    error InsufficientRewards();

    /**
     * @notice Constructs the StakedTitan contract
     * @param _titan Address of the TITAN token
     * @param _rewardRate Initial reward rate per second (scaled by 1e18)
     * @param _owner Address of the contract owner
     */
    constructor(
        address _titan,
        uint256 _rewardRate,
        address _owner
    ) ERC20("Staked Titan", "sTITAN") ERC20Permit("Staked Titan") Ownable(_owner) {
        if (_titan == address(0)) revert InvalidToken();
        titan = IERC20(_titan);
        rewardRate = _rewardRate;
        lastRewardTime = block.timestamp;
    }

    /**
     * @notice Accrue rewards based on time elapsed
     */
    function _accrueRewards() internal {
        if (totalSupply() == 0) {
            lastRewardTime = block.timestamp;
            return;
        }

        uint256 timeElapsed = block.timestamp - lastRewardTime;
        if (timeElapsed == 0) return;

        uint256 currentTotal = totalTitanAccrued > 0 ? totalTitanAccrued : titan.balanceOf(address(this));
        uint256 newRewards = (currentTotal * rewardRate * timeElapsed) / 1e18;

        uint256 actualBalance = titan.balanceOf(address(this));
        uint256 maxRewards = actualBalance > currentTotal ? actualBalance - currentTotal : 0;

        if (newRewards > maxRewards) {
            newRewards = maxRewards;
        }

        if (newRewards > 0) {
            totalTitanAccrued = currentTotal + newRewards;
            emit RewardsAccrued(newRewards, exchangeRate());
        }

        lastRewardTime = block.timestamp;
    }

    /**
     * @notice Get the current exchange rate (TITAN per sTITAN)
     * @return Exchange rate scaled by 1e18
     * @dev Uses virtual offset to prevent first depositor attack
     */
    function exchangeRate() public view returns (uint256) {
        uint256 supply = totalSupply() + VIRTUAL_OFFSET;

        uint256 currentTotal = totalTitanAccrued > 0 ? totalTitanAccrued : titan.balanceOf(address(this));
        uint256 timeElapsed = block.timestamp - lastRewardTime;
        uint256 pendingRewards = (currentTotal * rewardRate * timeElapsed) / 1e18;

        uint256 actualBalance = titan.balanceOf(address(this));
        uint256 maxRewards = actualBalance > currentTotal ? actualBalance - currentTotal : 0;
        if (pendingRewards > maxRewards) {
            pendingRewards = maxRewards;
        }

        uint256 totalWithPending = currentTotal + pendingRewards + VIRTUAL_OFFSET;
        return (totalWithPending * 1e18) / supply;
    }

    /**
     * @notice Get the total TITAN backing all sTITAN
     */
    function totalTitan() external view returns (uint256) {
        uint256 currentTotal = totalTitanAccrued > 0 ? totalTitanAccrued : titan.balanceOf(address(this));
        uint256 timeElapsed = block.timestamp - lastRewardTime;
        uint256 pendingRewards = (currentTotal * rewardRate * timeElapsed) / 1e18;

        uint256 actualBalance = titan.balanceOf(address(this));
        uint256 maxRewards = actualBalance > currentTotal ? actualBalance - currentTotal : 0;
        if (pendingRewards > maxRewards) {
            pendingRewards = maxRewards;
        }

        return currentTotal + pendingRewards;
    }

    /**
     * @notice Preview how much sTITAN you would receive for a TITAN deposit
     * @dev Uses virtual offset for consistent calculation
     */
    function previewDeposit(uint256 titanAmount) public view returns (uint256) {
        uint256 rate = exchangeRate();
        return (titanAmount * 1e18) / rate;
    }

    /**
     * @notice Preview how much TITAN you would receive for an sTITAN withdrawal
     */
    function previewWithdraw(uint256 sTitanAmount) public view returns (uint256) {
        uint256 supply = totalSupply();
        if (supply == 0) {
            return 0;
        }
        return (sTitanAmount * exchangeRate()) / 1e18;
    }

    /**
     * @notice Deposit TITAN and receive sTITAN with automatic voting power
     * @param titanAmount Amount of TITAN to deposit
     * @return sTitanAmount Amount of sTITAN minted
     */
    function deposit(uint256 titanAmount) external nonReentrant returns (uint256 sTitanAmount) {
        if (depositsPaused) revert DepositsPaused();
        if (titanAmount == 0) revert ZeroAmount();
        if (titanAmount < MINIMUM_DEPOSIT) revert DepositTooSmall();

        _accrueRewards();

        sTitanAmount = previewDeposit(titanAmount);
        if (sTitanAmount == 0) revert ZeroShares();

        titan.safeTransferFrom(msg.sender, address(this), titanAmount);
        totalTitanAccrued += titanAmount;

        _mint(msg.sender, sTitanAmount);

        // Auto-delegate to self if not delegated yet (enables voting power automatically)
        if (delegates(msg.sender) == address(0)) {
            _delegate(msg.sender, msg.sender);
        }

        emit Deposited(msg.sender, titanAmount, sTitanAmount);
    }

    /**
     * @notice Withdraw TITAN by burning sTITAN
     */
    function withdraw(uint256 sTitanAmount) external nonReentrant returns (uint256 titanAmount) {
        if (withdrawalsPaused) revert WithdrawalsPaused();
        if (sTitanAmount == 0) revert ZeroAmount();
        if (balanceOf(msg.sender) < sTitanAmount) revert InsufficientBalance();

        _accrueRewards();

        titanAmount = previewWithdraw(sTitanAmount);
        if (titanAmount == 0) revert ZeroAmount();
        if (titan.balanceOf(address(this)) < titanAmount) revert InsufficientRewards();

        totalTitanAccrued -= titanAmount;
        _burn(msg.sender, sTitanAmount);
        titan.safeTransfer(msg.sender, titanAmount);

        emit Withdrawn(msg.sender, sTitanAmount, titanAmount);
    }

    /**
     * @notice Withdraw all sTITAN
     */
    function withdrawAll() external nonReentrant returns (uint256 titanAmount) {
        if (withdrawalsPaused) revert WithdrawalsPaused();

        uint256 sTitanAmount = balanceOf(msg.sender);
        if (sTitanAmount == 0) revert ZeroAmount();

        _accrueRewards();

        titanAmount = previewWithdraw(sTitanAmount);
        if (titanAmount == 0) revert ZeroAmount();
        if (titan.balanceOf(address(this)) < titanAmount) revert InsufficientRewards();

        totalTitanAccrued -= titanAmount;
        _burn(msg.sender, sTitanAmount);
        titan.safeTransfer(msg.sender, titanAmount);

        emit Withdrawn(msg.sender, sTitanAmount, titanAmount);
    }

    /**
     * @notice Deposit reward tokens to fund future rewards
     */
    function depositRewards(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        _accrueRewards();
        titan.safeTransferFrom(msg.sender, address(this), amount);
        emit RewardsDeposited(msg.sender, amount);
    }

    /**
     * @notice Update the reward rate
     */
    function setRewardRate(uint256 newRate) external onlyOwner {
        _accrueRewards();
        uint256 oldRate = rewardRate;
        rewardRate = newRate;
        emit RewardRateUpdated(oldRate, newRate);
    }

    /**
     * @notice Pause or unpause deposits
     */
    function setDepositsPaused(bool paused) external onlyOwner {
        depositsPaused = paused;
        emit DepositsPausedChanged(paused);
    }

    /**
     * @notice Pause or unpause withdrawals
     */
    function setWithdrawalsPaused(bool paused) external onlyOwner {
        withdrawalsPaused = paused;
        emit WithdrawalsPausedChanged(paused);
    }

    /**
     * @notice Get the TITAN value of an account's sTITAN holdings
     */
    function titanBalanceOf(address account) external view returns (uint256) {
        return previewWithdraw(balanceOf(account));
    }

    /**
     * @notice Get available reward balance
     */
    function availableRewards() external view returns (uint256) {
        uint256 balance = titan.balanceOf(address(this));
        uint256 owed = totalTitanAccrued > 0 ? totalTitanAccrued : 0;
        return balance > owed ? balance - owed : 0;
    }

    /**
     * @notice Get current APY based on reward rate
     */
    function currentAPY() external view returns (uint256) {
        return (rewardRate * 365 days * 100) / 1e18;
    }

    // ============ ERC20Votes Overrides ============

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
