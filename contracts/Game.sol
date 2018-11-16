pragma solidity ^0.4.24;

contract Game{

    mapping (address => uint) public balances;

    mapping( bytes32 => mapping(bytes32 => uint8)) evaluate;

    address player;
    uint public wager;
    bytes32 hashedMove;

    event LogNewGame(address newPlayer, uint newWager);
    event LogWinner(address indexed winner, uint amountWon);
    event LogDraw(address player1,address player2);
    event LogWithdrawBalance(address indexed player, uint amount);

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
        bytes32 z = keccak256(0);
        bytes32 o = keccak256(1);
        bytes32 t = keccak256(2);
        
        evaluate[z][z] = 0;
        evaluate[z][o] = 1;
        evaluate[z][t] = 2;
        evaluate[o][z] = 2;
        evaluate[o][o] = 0;
        evaluate[o][t] = 1;
        evaluate[t][z] = 1;
        evaluate[t][o] = 2;
        evaluate[t][t] = 0;
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

            hashedMove = keccak256(_move);
            player = msg.sender;
            wager = msg.value;
            balances[player] += wager;
            emit LogNewGame(player,wager);
            return;
        }

        require(msg.sender != player);
        require(msg.value == wager);

        balances[msg.sender] += wager;

        bytes32 _hashedMove = keccak256(_move);
        if(evaluate[hashedMove][_hashedMove] == 2){
         
            balances[player] += wager;
            balances[msg.sender] -= wager;
            emit LogWinner(player,2*wager);
        }
        else if(evaluate[hashedMove][_hashedMove] == 1){
         
            balances[player] -= wager;
            balances[msg.sender] += wager;
            emit LogWinner(msg.sender,2*wager);
        }
        else
            emit LogDraw(player,msg.sender);

        player = 0;
    }

    function withdraw() public {

        uint amount = balances[msg.sender];
        require(amount > 0);
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}