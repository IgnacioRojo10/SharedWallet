// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol"; //trying to import ownable library from OpenZeppelin

contract Allowance is Ownable { //this is just to clean the other contract, one for allowance and the other for transfers

    event AllowanceChanged(address indexed _forWho, address indexed _fromWhom, uint _oldAmount, uint _newAmount); //indexed so we can look for them easily in the events chain

    mapping (address => uint) public allowance; //how much they are allowed to withdraw

    function addAllowance(address _who, uint _amount) public onlyOwner{ //Only owner can tell how much of each account can withdraw
        emit AllowanceChanged  (_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }

   
    modifier ownerOrAllowed(uint _amount) {      
        require( isOwner() || allowance[msg.sender] >= _amount); //Can only withdraw money if they are the owner or its inside their allowance
        _;
    }

    function reduceAllowance(address _who, uint _amount) internal {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who] - _amount);
        allowance[_who] -= _amount;
    }

}

contract SharedWalletProject is Allowance { 

    event MoneySent (address indexed _to, uint _amount); //from the contract to...
    event MoneyReceived (address indexed _from, uint _amount);

    // struct Accounts {
    //     uint totalBalance;
    //     bool allowed;
    // }

    // mapping (address => Accounts) public myAccount;


    // function changeAllowed(address _address) public onlyOwner{
    //     myAccount[_address].allowed = true;
    // }

    // function depositFunds() public payable ownerOnly{
    //     myAccount[msg.sender].totalBalance += msg.value; //this function adds the value to the sender balance
    // }

    // function contractBalance() public view returns(uint) { //to check balance in the contract
    //     return address(this).balance;
    // }

    // function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
    //     require(myAccount[msg.sender].totalBalance >= _amount, "Insufficent funds");
    //     myAccount[msg.sender].totalBalance -= _amount;
    //     myAccount[_to].totalBalance += _amount;

    // }


    function withdrawMoneySC(address payable _to, uint _amount) public ownerOrAllowed(_amount){
        require(_amount <= address(this).balance, "There is not enough money in the contract"); //just so we make sure that there is money in the contract before executing anything
        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount); // this line take the money from INSIDE the contract
    }



   receive () external payable {
    //    depositFunds(); //this function add the value to the contract
    emit MoneyReceived(msg.sender, msg.value);
   } 


}