// SPDX-License-Identifier: MIT
/*
 █████╗ ██╗              
██╔══██╗██║              
███████║██║              
██╔══██║██║              
██║  ██║██║              
╚═╝  ╚═╝╚═╝              
██╗███████╗              
██║██╔════╝              
██║███████╗              
██║╚════██║              
██║███████║              
╚═╝╚══════╝              
██████╗ ███████╗██╗   ██╗
██╔══██╗██╔════╝██║   ██║
██║  ██║█████╗  ██║   ██║
██║  ██║██╔══╝  ╚██╗ ██╔╝
██████╔╝███████╗ ╚████╔╝ 
╚═════╝ ╚══════╝  ╚═══╝  
https://aiis.dev
*/

// This token was generated AND deployed using GPT-4 and DALLE-3 with taxable mechanisms on https://aiis.dev! 
// All tokens deployed from this website adhere to basic token standards, ensuring secure code and compatibility among the blockchain ecosystem.
// Check it out now! https://aiis.dev


pragma solidity ^0.8.9;

import "./Ownable.sol";
import "./interfaces/IERC20.sol";


contract AITokenTaxable is IERC20, Ownable {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 private _totalSupply;
    address public taxAddress;
    uint256 public taxRate;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private allowances;

    address public factory;

    constructor() Ownable(_msgSender()){
        factory = msg.sender;
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _initialHolder,
        address _taxAddress,
        uint256 _taxRate
    ) external {
        require(msg.sender == factory, "only factory can init");
        require(_taxRate <= 10, "tax rate must be less than 10");
        transferOwnership(_initialHolder);
        name = _name;
        symbol = _symbol;
        taxAddress = _taxAddress;
        taxRate = _taxRate;
        _totalSupply = _initialSupply * (10 ** uint256(decimals));
        _balances[_initialHolder] = _totalSupply;
        emit Transfer(address(0), _initialHolder, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(
            msg.sender != address(0),
            "ERC20: transfer from the zero address"
        );
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: insufficient balance");

        uint256 taxAmount = amount * taxRate / 100;
        uint256 amountAfterTax = amount - taxAmount;

        _balances[taxAddress] += taxAmount;
        _balances[msg.sender] -= amount;
        _balances[recipient] += amountAfterTax;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        require(
            msg.sender != address(0),
            "ERC20: approve from the zero address"
        );
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: insufficient balance");
        require(
            allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );

        uint256 taxAmount = amount * taxRate / 100;
        uint256 amountAfterTax = amount - taxAmount;

        _balances[taxAddress] += taxAmount;
        _balances[sender] -= amount;
        _balances[recipient] += amountAfterTax;
        allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        _approve(
            msg.sender,
            spender,
            allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        uint256 currentAllowance = allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setTaxAddress(address _taxAddress) external onlyOwner {
        taxAddress = _taxAddress;
    }

    function setTaxRate(uint256 _taxRate) external onlyOwner {
        require(_taxRate <= 10, "tax rate must be less than 10");
        taxRate = _taxRate;
    }
}