// SPDX-License-Identifier: UNLICENSED
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

    uint256 public immutable totalSupply; // cannot be updated
    uint256 public paymentCounter;
    mapping(address => uint256) public balanceOf;
    mapping(address => Payment[]) public payments;
    mapping(address => uint256) public whitelist;
    uint256 constant NUM_ADMINS = 5;
    mapping(address => bool) isAdmin;
    address[NUM_ADMINS] public administrators;
    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }

    History[] paymentHistory; // when a payment was updated

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        bool adminUpdated;
        string recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
        uint256 amount;
    }

    struct History {
        uint256 lastUpdate;
        address updatedBy;
        uint256 blockNumber;
    }
    bool wasLastOdd;
    mapping(address => bool) isOddWhitelistUser;
    struct ImportantStruct {
        uint256 valueA; // max 3 digits
        uint256 bigValue;
        uint256 valueB; // max 3 digits
    }

    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        if(!isAdmin[msg.sender] && msg.sender != owner())
            revert NeitherAdminNorOwner();
        _;
    }

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        string recipient
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        for (uint256 ii = 0; ii < NUM_ADMINS; ii++) {
            if (_admins[ii] != address(0)) {
                administrators[ii] = _admins[ii];
                isAdmin[_admins[ii]] = true;
                uint256 bal = 0;
                if (_admins[ii] == msg.sender) {
                    balanceOf[msg.sender] = _totalSupply;
                    bal = _totalSupply;
                }
                emit supplyChanged(_admins[ii], bal);
            }
        }
        totalSupply = _totalSupply;
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) external returns (bool status_) {
        address senderOfTx = msg.sender;
        uint256 _balanceOf = balanceOf[senderOfTx];
        if(_balanceOf < _amount)
            revert InsufficientBalance();
        if (bytes(_name).length >= 9)
            revert RecipientNameTooLong();
        balanceOf[senderOfTx] = _balanceOf - _amount;
        balanceOf[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        Payment memory payment;
        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = _name;
        payment.paymentID = ++paymentCounter;
        payments[senderOfTx].push(payment);
        return true;
    }

    function checkForAdmin(address _user) internal view returns (bool admin_) {
        return isAdmin[_user];
    }

    function getTradingMode() external pure returns (bool mode_) {
        return true;
    }

    function addHistory(address _updateAddress)
        internal
    {
        History memory history;
        history.blockNumber = block.number;
        history.lastUpdate = block.timestamp;
        history.updatedBy = _updateAddress;
        paymentHistory.push(history);
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

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) external onlyAdminOrOwner {
        if(_ID == 0)
            revert IdMustBeGtZero();
        if(_amount == 0)
            revert AmountMustBeGtZero();
        if(_user == address(0))
            revert AdminMustHaveValidNonZeroAddress();
        address senderOfTx = msg.sender;

        for (uint256 ii = 0; ii < payments[_user].length; ii++) {
            if (payments[_user][ii].paymentID == _ID) {
                payments[_user][ii].adminUpdated = true;
                payments[_user][ii].admin = _user;
                payments[_user][ii].paymentType = _type;
                payments[_user][ii].amount = _amount;
                addHistory(_user);
                emit PaymentUpdated(
                    senderOfTx,
                    _ID,
                    _amount,
                    payments[_user][ii].recipientName
                );
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
        onlyAdminOrOwner
    {
        assert(_tier < 255);
        whitelist[_userAddrs] = _tier;
        bool wasLastAddedOdd = wasLastOdd;
        isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        wasLastOdd = !wasLastAddedOdd;
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        ImportantStruct memory /*_struct*/
    ) external {
        address senderOfTx = msg.sender;
        uint256 _whitelist = whitelist[senderOfTx];
        uint256 _senderBal = balanceOf[senderOfTx];
        assert(_whitelist < 4);
        if(_senderBal < _amount)
            revert InsufficientBalance();
        if(_amount <= 3)
            revert AmountToSendMustBeGt3();
        balanceOf[senderOfTx] = _senderBal - _amount + _whitelist;
        balanceOf[_recipient] += _amount - _whitelist;
        emit WhiteListTransfer(_recipient);
    }
}
