// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Exchange is ERC20{

    address public tokenAddress;

    constructor (address token) ERC20("ETH Lp Token", "lpETHTOKEN") {
        require(token != address(0),"Address is cannot be null");
        tokenAddress = token;
    }

    function getReserve() public view returns(uint256){
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    function addLiquidity(uint256 tokenAmount) public payable returns(uint256){

        uint256 lpTokensToMint;
        uint256 ethReserve = address(this).balance;
        uint256 tokenReserve = getReserve();

        ERC20 token = ERC20(tokenAddress);

        if(tokenReserve==0){
            token.transferFrom(msg.sender,address(this),tokenAmount);

            lpTokensToMint =ethReserve;
            _mint(msg.sender,lpTokensToMint);
            return lpTokensToMint;
        }

        uint256 ethReserveBeforeThisCall = address(this).balance - msg.value;
        uint256 minTokensRequired = (tokenReserve * msg.value)/ethReserveBeforeThisCall;

        require(tokenAmount >= minTokensRequired, "Token sent invalid ");
        token.transferFrom(msg.sender,address(this), minTokensRequired);

        lpTokensToMint = (totalSupply()*msg.value)/ethReserveBeforeThisCall;
        _mint(msg.sender,lpTokensToMint);

        return lpTokensToMint;

    }

    function removeLiquidity(uint256 lpTokenAmount) public returns(uint256,uint256){
        require(lpTokenAmount>0,"Amount of tokens send to remove should be greater than zero");
        uint256 ethReserve = address(this).balance;
        uint256 lpTokenTotalSupply = totalSupply();

        uint256 ethToReturn = (ethReserve*lpTokenAmount)/lpTokenTotalSupply;
        uint256 tokenToReturn = (getReserve()*lpTokenAmount)/lpTokenTotalSupply;

        _burn(msg.sender, lpTokenAmount);
        payable(msg.sender).transfer(ethToReturn);
        ERC20(tokenAddress).transfer(msg.sender, tokenToReturn);

        return (ethToReturn,tokenToReturn); 
    }

    function getOutputAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns(uint256){
        require(inputReserve>0 && outputReserve>0,"The reserves must be greater than zero");
        uint256 inputAmountWithFee = inputAmount*99;
        uint256 numerator = outputReserve*inputAmountWithFee;
        uint256 denominator = inputAmountWithFee+(inputReserve*100);

        return numerator/denominator;
    }

    function ethToTokenSwap(uint256 minTokensToReceive) public payable{
        uint256 tokenReserve = getReserve();
        uint256 tokensYouWillReceive = getOutputAmount(
            msg.value,
            address(this).balance - msg.value, 
            tokenReserve
            );

        require(tokensYouWillReceive >= minTokensToReceive,"Tokens received are less than the miin Tokens specified");

        ERC20(tokenAddress).transfer(msg.sender,tokensYouWillReceive);
    }

    function tokenToEthSwap(uint256 tokensToSwap,uint256 minEthReceived) public payable{

        uint256 ethYouWillReceive = getOutputAmount(tokensToSwap, getReserve(), address(this).balance);

        require(minEthReceived>=ethYouWillReceive,"Eth received is less than the min amount required");

        ERC20(tokenAddress).transferFrom(msg.sender, address(this), tokensToSwap);

        payable(msg.sender).transfer(ethYouWillReceive);
    }

    
}