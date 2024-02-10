//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CrowdFunding{
    //entities involved in crowdfunding
    mapping(address=>uint) public contributors;
    
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint=>Request) public requests;
    uint public numRequests;

    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline; //10 sec + 360 sec (60*60)
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    modifier onlyManager(){
        require(msg.sender==manager,"You are not the manager");
        _;
    }

    function createRequest(string calldata _description,address payable _recipient,uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function contribution() public payable{
        require(block.timestamp<deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"Minimum Contribution is 100 wei");

        if(contributors[msg.sender]==0){ //for unique contributors
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }

    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"You are not elegible for refund");
        require(contributors[msg.sender]>0,"You are not a contributor");
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You are not a contributor");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"Youhave already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target,"Target is not reached");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false,"The request has been completed");
        require(thisRequest.noOfVoters>noOfContributors/2,"Majority does not support the request");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;

    }







    



}
