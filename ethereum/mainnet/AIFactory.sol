// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./GPT3.5-ERC20.sol";
import "./GPT4-AntiWhaleERC20.sol";
import "./GPT4-NoOwnerERC20.sol";
import "./GPT4-ERC20.sol";
import "./GPT4-TaxableERC20.sol";
import "./Ownable.sol";

contract AIFactory is Ownable {
    uint256 public deploymentFee;
    address[] public deployedTokens;
    event TokenDeployed(address indexed tokenAddress, address indexed owner, string name, string ipfsHash);
    constructor(uint256 _deploymentFee) Ownable(msg.sender) {
        deploymentFee = _deploymentFee;
    }
    receive() external payable {}
    function setDeploymentFee(uint256 _newFee) external onlyOwner {
        deploymentFee = _newFee;
    }
    function createToken(string memory _name, string memory _symbol, uint _initialSupply, string memory ipfsHash, bool isPremium, bool isAntiwhale, bool noOwner, bool taxable, uint256 taxRate, address taxReceiver) public payable returns (address) {
        require(msg.value == deploymentFee, "Insufficient fee in ETH");
        require(taxRate <= 10, "Tax rate must be less than or equal to 10%");
        AIToken newToken;

        if (!isPremium) {
            newToken = new AIToken();
        } else if (isAntiwhale) {
            newToken = new AITokenAntiWhale();
        } else if (noOwner) {
            newToken = new AITokenNoOwner();
        } else if (taxRate) {
            newToken = new AITokenTaxable();
        } else {
            newToken = new AITokenGPT4();
        }

        if (taxable) {
            newToken.initialize(_name, _symbol, _initialSupply, msg.sender, taxReceiver, taxRate);
        } else {
            newToken.initialize(_name, _symbol, _initialSupply, msg.sender);
        }
        deployedTokens.push(address(newToken));
        emit TokenDeployed(address(newToken), msg.sender, _name, ipfsHash);
        return address(newToken);
    }
    function getDeployedTokens() external view returns (address[] memory) {
        return deployedTokens;
    }
    function withdrawFees(address payable to) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");
        to.transfer(balance);
    }
}