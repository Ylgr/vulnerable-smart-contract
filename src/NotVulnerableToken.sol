contract NotVulnerableToken {
    mapping(address => uint256) balances;

    function transfer(address _to, uint256 _amount) public {
        require(_amount <= balances[msg.sender]);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}