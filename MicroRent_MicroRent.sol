// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MicroRent
 * @notice Provides precise per-minute billing structures for physical property sharing.
 */
contract MicroRent {
    address public provider;
    uint256 public ratePerMinute = 0.00001 ether; // Lease cost per minute

    struct RentalSession {
        uint256 startTime;
        bool isActive;
    }

    mapping(address => RentalSession) public activeSessions;

    event CheckedIn(address indexed user, uint256 startTime);
    event CheckedOut(address indexed user, uint256 durationMinutes, uint256 totalCost, uint256 refundAmount);
    event RateUpdated(uint256 newRate);

    modifier onlyProvider() {
        require(msg.sender == provider, "Only the service provider can configure rates");
        _;
    }

    constructor() {
        provider = msg.sender;
    }

    /**
     * @notice Initiates a live tracking rental session.
     */
    function checkIn() external {
        require(!activeSessions[msg.sender].isActive, "An active leasing session already exists");
        
        activeSessions[msg.sender] = RentalSession({
            startTime: block.timestamp,
            isActive: true
        });

        emit CheckedIn(msg.sender, block.timestamp);
    }

    /**
     * @notice Closes out the user's rental session and calculates exact time-slice expenses.
     */
    function checkOut() external payable {
        RentalSession storage session = activeSessions[msg.sender];
        require(session.isActive, "No active workspace leasing session detected");

        uint256 durationSeconds = block.timestamp - session.startTime;
        uint256 durationMinutes = durationSeconds / 60;
        if (durationMinutes == 0) durationMinutes = 1; // Round up minimum charge parameters

        uint256 totalCost = durationMinutes * ratePerMinute;
        require(msg.value >= totalCost, "Insufficient financial liquidity attached to settle checkout fees");

        session.isActive = false;
        uint256 refundAmount = msg.value - totalCost;

        // Immediately route the exact usage cost to property operator
        payable(provider).transfer(totalCost);

        // Refund additional unspent liquidity balances back to the tenant
        if (refundAmount > 0) {
            payable(msg.sender).transfer(refundAmount);
        }

        emit CheckedOut(msg.sender, durationMinutes, totalCost, refundAmount);
    }

    function updateRate(uint256 _newRate) external onlyProvider {
        ratePerMinute = _newRate;
        emit RateUpdated(_newRate);
    }
}