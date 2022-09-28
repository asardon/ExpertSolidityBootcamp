pragma solidity ^0.8.4;

contract Exercise1 {
    function test() external payable returns (uint256) {
        assembly {
            let callValue := callvalue()
            mstore(0x80, callValue)
            return(0x80, 32)
        }
    }
}