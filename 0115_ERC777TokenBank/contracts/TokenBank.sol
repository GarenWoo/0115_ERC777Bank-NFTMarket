// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Bank.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IERC20TokenGTT {
    function transferFrom(address, address, uint256) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function safeTransferFrom(IERC20, address, address, uint256 value) external;

    function safeTransfer(IERC20, address, uint256) external;
}

contract TokenBank is Bank {
    mapping(address => uint) internal tokenBalance;
    address[3] internal tokenRank;
    address public immutable tokenAddr;
    IERC20TokenGTT public immutable iGTT;
    IERC20 public immutable iERC20Token;
    using SafeERC20 for IERC20;
    event tokenReceived(address sender, uint amount);
    error WrongTokenReceived(address inputAddr, address validAddr);

    constructor(address _tokenAddr) {
        owner = msg.sender;
        tokenAddr = _tokenAddr;
        iGTT = IERC20TokenGTT(_tokenAddr);
        iERC20Token = IERC20(_tokenAddr);
    }

    function depositToken(uint _tokenAmount) public {
        iERC20Token.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenAmount
        );
        tokenBalance[msg.sender] += _tokenAmount;
        _handleRankWhenDepositToken();
    }

    function withdrawToken() public onlyOwner {
        iERC20Token.safeTransfer(owner, iGTT.balanceOf(address(this)));
    }

    function tokensReceived(
        address _from,
        uint _amount
    ) external returns (bool) {
        if (msg.sender != address(tokenAddr)) {
            revert WrongTokenReceived(msg.sender, tokenAddr);
        }
        tokenBalance[_from] += _amount;
        emit tokenReceived(_from, _amount);
        return true;
    }

    function getTokenBalance(address _account) public view returns (uint) {
        return tokenBalance[_account];
    }

    function getTokenTopThreeAccount()
        public
        view
        returns (address, address, address)
    {
        return (tokenRank[0], tokenRank[1], tokenRank[2]);
    }

    function _handleRankWhenDepositToken() internal {
        uint membershipIndex = _checkTokenRankMembership();
        uint convertedIndex;
        uint indexRecord = 777;
        if (membershipIndex != 999) {
            // Case 1: msg.sender is already inside the top3 rank.
            convertedIndex = membershipIndex + 4;
            for (uint i = convertedIndex - 3; i > 1; i--) {
                if (membershipIndex != 0) {
                    if (
                        tokenBalance[msg.sender] >
                        tokenBalance[tokenRank[i - 2]]
                    ) {
                        indexRecord = i - 2;
                        for (uint j = 2; j > i - 2; j--) {
                            tokenRank[j] = tokenRank[j - 1];
                        }
                        // Boundry condition
                        if (indexRecord == 0) {
                            tokenRank[indexRecord] = msg.sender;
                        }
                    } else {
                        if (indexRecord != 777) {
                            tokenRank[indexRecord] = msg.sender;
                        }
                    }
                }
            }
        } else {
            // Case 2: msg.sender is not inside the top3 rank.
            for (uint i = 3; i > 0; i--) {
                if (tokenBalance[msg.sender] > tokenBalance[tokenRank[i - 1]]) {
                    indexRecord = i - 1;
                    // move backward the element(s) which is(/are) right at the index and also behind the index
                    for (uint j = 2; j > i - 1; j--) {
                        tokenRank[j] = tokenRank[j - 1];
                    }
                    // Boundry condition
                    if (indexRecord == 0) {
                        tokenRank[indexRecord] = msg.sender;
                    }
                } else {
                    if (indexRecord != 777) {
                        tokenRank[indexRecord] = msg.sender;
                    }
                }
            }
        }
    }

    function _checkTokenRankMembership() internal view returns (uint) {
        uint index = 999;
        for (uint i = 0; i < 3; i++) {
            if (tokenRank[i] == msg.sender) {
                index = i;
                break;
            }
        }
        return index;
    }
}
