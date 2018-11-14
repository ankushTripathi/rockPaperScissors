pragma solidity ^0.4.24;

contract Game{

    mapping (address => uint) public balances;

    uint8[3][3] evaluate;

    address player;
    uint public wager;
    uint8 move;


    constructor (){

        /*
        **moves**
        *  0 => rock 
        *  1 => paper
        *  2 => scissor
        **results**
        * 0 => draw
        * 1 => loose
        * 2 => win
        */
        evaluate[0][0] = 0;
        evaluate[0][1] = 1;
        evaluate[0][2] = 2;
        evaluate[1][0] = 2;
        evaluate[1][1] = 0;
        evaluate[1][2] = 1;
        evaluate[2][0] = 1;
        evaluate[2][1] = 2;
        evaluate[2][2] = 0;
        
    }

    function isNewGame() public view returns(bool){
        return (player==0);
    }

    function getCurrentPlayer() public view returns(address){
        return player;
    }

    function getCurrentWager() public view returns(uint){
        return wager;
    }

    function play(uint8 _move) public payable{

        if(player == 0){

            move = _move;
            player = msg.sender;
            wager = msg.value;
            balances[player] += wager;
            return;
        }

        require(msg.sender != player);
        require(msg.value == wager);

        balances[msg.sender] += wager;

        if(evaluate[move][_move] == 2){
         
            balances[player] += wager;
            balances[msg.sender] -= wager;
        }
        else if(evaluate[move][_move] == 1){
         
            balances[player] -= wager;
            balances[msg.sender] += wager;
        }

        player = 0;
    }

    function withdraw() public {

        require(balances[msg.sender] > 0);
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}