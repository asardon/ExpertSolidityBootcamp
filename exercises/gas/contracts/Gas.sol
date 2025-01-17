// SPDX-License-Identifier: UNLICENSED
<<<<<<< HEAD
pragma solidity 0.8.4;

import "./Ownable.sol";

contract GasContract is Ownable {
    error InsufficientBalance();
    error RecipientNameTooLong();
    error NeitherAdminNorOwner();
    error UserMustHaveValidNonZeroAddress();
    error IdMustBeGtZero();
    error AmountMustBeGtZero();
    error AdminMustHaveValidNonZeroAddress();
    error AmountToSendMustBeGt3();
    error UserNotWhiteListed();

    bool wasLastOdd;
    uint256 constant NUM_ADMINS = 5;
    uint256 public immutable totalSupply; // cannot be updated
    uint256 public paymentCounter;
    mapping(address => uint256) public balanceOf;
    mapping(address => Payment[]) payments;
    mapping(address => uint256) public whitelist;
    mapping(address => bool) isAdmin;
    address[NUM_ADMINS] public administrators;
=======
pragma solidity 0.8.0;

import "./Ownable.sol";

contract Constants {
    uint256 public tradeFlag = 1;
    uint256 public basicFlag = 0;
    uint256 public dividendFlag = 1;
}

contract GasContract is Ownable, Constants {
    uint256 public totalSupply = 0; // cannot be updated
    uint256 public paymentCounter = 0;
    mapping(address => uint256) public balances;
    uint256 public tradePercent = 12;
    address public contractOwner;
    uint256 public tradeMode = 0;
    mapping(address => Payment[]) public payments;
    mapping(address => uint256) public whitelist;
    address[5] public administrators;
    bool public isReady = false;
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }
<<<<<<< HEAD

    History[] paymentHistory; // when a payment was updated

    struct Payment {
        uint8 paymentType;
        bool adminUpdated;
        address recipient;
        address admin; // administrators address
        uint256 paymentID;
        bytes32 recipientName; // max 8 characters
=======
    PaymentType constant defaultPayment = PaymentType.Unknown;

    History[] public paymentHistory; // when a payment was updated

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        bool adminUpdated;
        string recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
        uint256 amount;
    }

    struct History {
        uint256 lastUpdate;
        address updatedBy;
        uint256 blockNumber;
    }
<<<<<<< HEAD
    mapping(address => bool) isOddWhitelistUser;
=======
    uint256 wasLastOdd = 1;
    mapping(address => uint256) public isOddWhitelistUser;
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
    struct ImportantStruct {
        uint256 valueA; // max 3 digits
        uint256 bigValue;
        uint256 valueB; // max 3 digits
    }

<<<<<<< HEAD
    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        if(!isAdmin[msg.sender] && msg.sender != owner())
            revert NeitherAdminNorOwner();
=======
    mapping(address => ImportantStruct) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        address senderOfTx = msg.sender;
        if (checkForAdmin(senderOfTx)) {
            require(
                checkForAdmin(senderOfTx),
                "Gas Contract Only Admin Check-  Caller not admin"
            );
            _;
        } else if (senderOfTx == contractOwner) {
            _;
        } else {
            revert(
                "Error in Gas contract - onlyAdminOrOwner modifier : revert happened because the originator of the transaction was not the admin, and furthermore he wasn't the owner of the contract, so he cannot run this function"
            );
        }
    }

    modifier checkIfWhiteListed(address sender) {
        address senderOfTx = msg.sender;
        require(
            senderOfTx == sender,
            "Gas Contract CheckIfWhiteListed modifier : revert happened because the originator of the transaction was not the sender"
        );
        uint256 usersTier = whitelist[senderOfTx];
        require(
            usersTier > 0,
            "Gas Contract CheckIfWhiteListed modifier : revert happened because the user is not whitelisted"
        );
        require(
            usersTier < 4,
            "Gas Contract CheckIfWhiteListed modifier : revert happened because the user's tier is incorrect, it cannot be over 4 as the only tier we have are: 1, 2, 3; therfore 4 is an invalid tier for the whitlist of this contract. make sure whitlist tiers were set correctly"
        );
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
        _;
    }

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
<<<<<<< HEAD
        bytes32 recipient
=======
        string recipient
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
<<<<<<< HEAD
        for (uint256 ii = 0; ii < NUM_ADMINS;) {
            if (_admins[ii] != address(0)) {
                administrators[ii] = _admins[ii];
                isAdmin[_admins[ii]] = true;
                uint256 bal;
                if (_admins[ii] == msg.sender) {
                    balanceOf[msg.sender] = _totalSupply;
                    bal = _totalSupply;
                }
                emit supplyChanged(_admins[ii], bal);
            }
            unchecked {
                ii++;
            }
        }
        totalSupply = _totalSupply;
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) external returns (bool status_) {
        uint256 _balanceOf = balanceOf[msg.sender];
        if(_balanceOf < _amount)
            revert InsufficientBalance();
        if(bytes(_name).length > 8)
            revert RecipientNameTooLong();
        balanceOf[msg.sender] = _balanceOf - _amount;
        balanceOf[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        Payment memory payment;
        payment.paymentType = 1;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = stringToBytes32(_name);
        payment.paymentID = ++paymentCounter;
        payments[msg.sender].push(payment);
        return true;
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

    function checkForAdmin(address _user) internal view returns (bool admin_) {
        return isAdmin[_user];
    }

    function getTradingMode() external pure returns (bool mode_) {
        return true;
    }

    function addHistory(address _updateAddress)
        internal
=======
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (_admins[ii] != address(0)) {
                administrators[ii] = _admins[ii];
                if (_admins[ii] == contractOwner) {
                    balances[contractOwner] = totalSupply;
                } else {
                    balances[_admins[ii]] = 0;
                }
                if (_admins[ii] == contractOwner) {
                    emit supplyChanged(_admins[ii], totalSupply);
                } else if (_admins[ii] != contractOwner) {
                    emit supplyChanged(_admins[ii], 0);
                }
            }
        }
    }

    function getPaymentHistory()
        public
        payable
        returns (History[] memory paymentHistory_)
    {
        return paymentHistory;
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        bool admin = false;
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                admin = true;
            }
        }
        return admin;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }

    function getTradingMode() public view returns (bool mode_) {
        bool mode = false;
        if (tradeFlag == 1 || dividendFlag == 1) {
            mode = true;
        } else {
            mode = false;
        }
        return mode;
    }

    function addHistory(address _updateAddress, bool _tradeMode)
        public
        returns (bool status_, bool tradeMode_)
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
    {
        History memory history;
        history.blockNumber = block.number;
        history.lastUpdate = block.timestamp;
        history.updatedBy = _updateAddress;
        paymentHistory.push(history);
<<<<<<< HEAD
    }

    function getPayments(address _user)
        external
        view
        returns (Payment[] memory payments_)
    {
        if(_user == address(0))
            revert UserMustHaveValidNonZeroAddress();
        return payments[_user];
    }

=======
        bool[] memory status = new bool[](tradePercent);
        for (uint256 i = 0; i < tradePercent; i++) {
            status[i] = true;
        }
        return ((status[0] == true), _tradeMode);
    }

    function getPayments(address _user)
        public
        view
        returns (Payment[] memory payments_)
    {
        require(
            _user != address(0),
            "Gas Contract - getPayments function - User must have a valid non zero address"
        );
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool status_) {
        address senderOfTx = msg.sender;
        require(
            balances[senderOfTx] >= _amount,
            "Gas Contract - Transfer function - Sender has insufficient Balance"
        );
        require(
            bytes(_name).length < 9,
            "Gas Contract - Transfer function -  The recipient name is too long, there is a max length of 8 characters"
        );
        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        Payment memory payment;
        payment.admin = address(0);
        payment.adminUpdated = false;
        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = _name;
        payment.paymentID = ++paymentCounter;
        payments[senderOfTx].push(payment);
        bool[] memory status = new bool[](tradePercent);
        for (uint256 i = 0; i < tradePercent; i++) {
            status[i] = true;
        }
        return (status[0] == true);
    }

>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
<<<<<<< HEAD
    ) external onlyAdminOrOwner {
        if(_ID == 0)
            revert IdMustBeGtZero();
        if(_amount == 0)
            revert AmountMustBeGtZero();
        if(_user == address(0))
            revert AdminMustHaveValidNonZeroAddress();

        uint256 arrayLen = payments[_user].length;
        for (uint256 ii = 0; ii < arrayLen;) {
            if (payments[_user][ii].paymentID == _ID) {
                payments[_user][ii].adminUpdated = true;
                payments[_user][ii].admin = _user;
                payments[_user][ii].paymentType = uint8(_type);
                payments[_user][ii].amount = _amount;
                addHistory(_user);
                emit PaymentUpdated(
                    msg.sender,
=======
    ) public onlyAdminOrOwner {
        require(
            _ID > 0,
            "Gas Contract - Update Payment function - ID must be greater than 0"
        );
        require(
            _amount > 0,
            "Gas Contract - Update Payment function - Amount must be greater than 0"
        );
        require(
            _user != address(0),
            "Gas Contract - Update Payment function - Administrator must have a valid non zero address"
        );

        address senderOfTx = msg.sender;

        for (uint256 ii = 0; ii < payments[_user].length; ii++) {
            if (payments[_user][ii].paymentID == _ID) {
                payments[_user][ii].adminUpdated = true;
                payments[_user][ii].admin = _user;
                payments[_user][ii].paymentType = _type;
                payments[_user][ii].amount = _amount;
                bool tradingMode = getTradingMode();
                addHistory(_user, tradingMode);
                emit PaymentUpdated(
                    senderOfTx,
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
                    _ID,
                    _amount,
                    payments[_user][ii].recipientName
                );
<<<<<<< HEAD
                break;
            }
            unchecked{
                 ii++;
=======
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
<<<<<<< HEAD
        external
        onlyAdminOrOwner
    {
        assert(_tier < 255);
        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier;
        bool wasLastAddedOdd = wasLastOdd;
        isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        wasLastOdd = !wasLastAddedOdd;
=======
        public
        onlyAdminOrOwner
    {
        require(
            _tier < 255,
            "Gas Contract - addToWhitelist function -  tier level should not be greater than 255"
        );
        whitelist[_userAddrs] = _tier;
        if (_tier > 3) {
            whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 3;
        } else if (_tier == 1) {
            whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 1;
        } else if (_tier > 0 && _tier < 3) {
            whitelist[_userAddrs] -= _tier;
            whitelist[_userAddrs] = 2;
        }
        uint256 wasLastAddedOdd = wasLastOdd;
        if (wasLastAddedOdd == 1) {
            wasLastOdd = 0;
            isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        } else if (wasLastAddedOdd == 0) {
            wasLastOdd = 1;
            isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        } else {
            revert("Contract hacked, imposible, call help");
        }
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
<<<<<<< HEAD
        ImportantStruct memory /*_struct*/
    ) external {
        uint256 _whitelist = whitelist[msg.sender];
        uint256 _senderBal = balanceOf[msg.sender];
        assert(_whitelist < 4);
        if(_whitelist == 0)
            revert UserNotWhiteListed();
        if(_senderBal < _amount)
            revert InsufficientBalance();
        if(_amount <= 3)
            revert AmountToSendMustBeGt3();
        balanceOf[msg.sender] = _senderBal - _amount + _whitelist;
        balanceOf[_recipient] += _amount - _whitelist;
=======
        ImportantStruct memory _struct
    ) public checkIfWhiteListed(msg.sender) {
        address senderOfTx = msg.sender;
        require(
            balances[senderOfTx] >= _amount,
            "Gas Contract - whiteTransfers function - Sender has insufficient Balance"
        );
        require(
            _amount > 3,
            "Gas Contract - whiteTransfers function - amount to send have to be bigger than 3"
        );
        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;
        balances[senderOfTx] += whitelist[senderOfTx];
        balances[_recipient] -= whitelist[senderOfTx];

        whiteListStruct[senderOfTx] = ImportantStruct(0, 0, 0);
        ImportantStruct storage newImportantStruct = whiteListStruct[
            senderOfTx
        ];
        newImportantStruct.valueA = _struct.valueA;
        newImportantStruct.bigValue = _struct.bigValue;
        newImportantStruct.valueB = _struct.valueB;
>>>>>>> 1636735a02cbd44304e3eed635e36d816db4f8eb
        emit WhiteListTransfer(_recipient);
    }
}
