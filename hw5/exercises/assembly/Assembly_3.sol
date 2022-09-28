pragma solidity ^0.8.4;

contract SubOverflow {
    // Modify this function so that on overflow it returns the value 0
    // otherwise it should return x - y
    function subtract(uint256 x, uint256 y) public pure returns (uint256) {
        // Write assembly code that handles overflows
        uint256 _x = type(uint256).max;
        uint256 _y = 1;
        assembly {
            switch lt(x, y)
                case 1 { 
                    mstore(0x80, 0) 
                } case 0 {
                    let diff := sub(x, y)
                    mstore(0x80, diff)
                }
            return(0x80, 32)
        }
    }
}
