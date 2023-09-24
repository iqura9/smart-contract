// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UniInsurance {
    address public owner;
    uint256 public premiumAmount;
    uint256 public coverageAmount;
    uint256 public expirationDate;
    bool public isClaimed;

    enum PolicyState { Active, Expired, Claimed }
    PolicyState public policyState;

    event PolicyCreated(address indexed labOwner, uint256 premium, uint256 coverage, uint256 expirationDate);
    event ClaimProcessed(address indexed beneficiary, uint256 amount);

    constructor(uint256 _premiumAmount, uint256 _coverageAmount, uint256 _durationDays) {
        owner = msg.sender;
        premiumAmount = _premiumAmount;
        coverageAmount = _coverageAmount;
        expirationDate = block.timestamp + (_durationDays * 1 days);
        isClaimed = false;
        policyState = PolicyState.Active;

        emit PolicyCreated(owner, premiumAmount, coverageAmount, expirationDate);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier isPolicyActive() {
        require(policyState == PolicyState.Active, "The policy is not active.");
        _;
    }

    modifier isPolicyExpired() {
        require(policyState == PolicyState.Expired, "The policy is not yet expired.");
        _;
    }

    function claimInsurance() external onlyOwner isPolicyActive {
        require(block.timestamp >= expirationDate, "You can only claim insurance after the policy has expired.");
        require(!isClaimed, "Insurance has already been claimed for this policy.");

        isClaimed = true;
        policyState = PolicyState.Claimed;

        payable(owner).transfer(coverageAmount);

        emit ClaimProcessed(owner, coverageAmount);
    }

    function extendPolicy(uint256 _additionalDays) external onlyOwner isPolicyActive {
        require(_additionalDays > 0, "Additional days should be greater than zero.");

        expirationDate += _additionalDays * 1 days;

        emit PolicyCreated(owner, premiumAmount, coverageAmount, expirationDate);
    }

    function checkPolicyStatus() external view returns (PolicyState) {
        if (policyState == PolicyState.Claimed) {
            return PolicyState.Claimed;
        } else if (block.timestamp >= expirationDate) {
            return PolicyState.Expired;
        } else {
            return PolicyState.Active;
        }
    }
}

