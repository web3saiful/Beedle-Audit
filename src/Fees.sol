// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./utils/Errors.sol";
import "./utils/Structs.sol";

import {IERC20} from "./interfaces/IERC20.sol";

import {ISwapRouter} from "./interfaces/ISwapRouter.sol";
/*(File Summary
Purpose: _profits টোকেনকে WETH-এ swap করা এবং staking ঠিকানায় পাঠানো।
Main function: sellProfits(address _profits)
Key external dependency: Uniswap V3 Router (swapRouter)*/


contract Fees {
    address public immutable WETH;
    address public immutable staking;

    /// uniswap v3 router
    ISwapRouter public constant swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    constructor(address _weth, address _staking) {
        WETH = _weth;
        staking = _staking;
    }

    /// @notice swap loan tokens for collateral tokens from liquidations
    /// @param _profits the token to swap for WETH
    function sellProfits(address _profits) public {//@a function sellProfits(address _profits) external onlyOwner

        require(_profits != WETH, "not allowed");
        uint256 amount = IERC20(_profits).balanceOf(address(this));
  
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _profits,
                tokenOut: WETH,
                fee: 3000,
                recipient: address(this),//Beedle maybe hold profits in Fees contract
                deadline: block.timestamp,
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amount = swapRouter.exactInputSingle(params);
        IERC20(WETH).transfer(staking, IERC20(WETH).balanceOf(address(this)));
    }//                                     ^uint
}
