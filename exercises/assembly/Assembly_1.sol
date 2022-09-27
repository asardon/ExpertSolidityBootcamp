pragma solidity ^0.8.4;

contract Intro {
    uint256 constant MOL = 420;
    function intro() public view returns (uint16) {
        uint256 mol = 420;

        // Yul assembly magic happens within assembly{} section
        assembly {
            // stack variables are instantiated with
            // let variable_name := VALßUE
            // instantiate a stack variable that holds the value of mol
            // To return it needs to be stored in memory
            // with command mstore(MEMORY_LOCATION, STACK_VARIABLE)
            let variable_name := mol
            mstore(0x80, variable_name)
            // to return you need to specify address and the size from the starting point
            return(0x80, 32) // return(0x80, mol) doesn't work, need to mstore first
        }
    }
}