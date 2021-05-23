// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./base/token/ERC20/extensions/IERC20Metadata.sol";
import "./base/access/Ownable.sol";
import "./base/utils/Context.sol";
import "./base/token/ERC20/extensions/AntiWhale.sol";


/*
Notes: Usage of SafeMath is not required as of solidity 0.8.0 due to built-in safety checks
*/
contract Yell is Context, IERC20Metadata, Ownable, AntiWhale {

    mapping (address => uint256) private _balances; //Total number of tokens owned by each address
    mapping (address => mapping (address => uint256)) private _allowances;

    string private constant _name = "Yell";
    string private constant _symbol = "YELL";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply;

    constructor () {
        // Create initial tokens and provide them to the message sender
        mint(_msgSender(), 100000000000 * 10**_decimals); //100 billion supply

        setTransactionLimit(_totalSupply / 100); //1% transaction limit
    }

    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);

        // Ensure that there is enough allowance for this transfer
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");

        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }
    
    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "Mint to the zero address is not allowed");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "Cannot burn tokens from the zero address");

        // Ensure there are enough tokens to be burned
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "Burn amount exceeds balance");
        
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
    

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfers from the zero address are not allowed");
        
        
        // If we are not burning, check that amount is within the allowed limit
        if (recipient != address(0))
        {
            // Check that we are not transferring big amounts (Anti-whale)
            require(isWithinLimit(amount), "Transaction amount exceeds the configured limit");
        }
        
        
        // Ensure that sender has the needed amount
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");

        // Update the balances
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Cannot approve from the zero address");
        require(spender != address(0), "Cannot approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        //Ensure that there is enough allowance
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "Cannot decrease allowance below zero");

        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }
}