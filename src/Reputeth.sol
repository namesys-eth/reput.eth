//SPDX-License-Identifier: WTFPL.ETH
pragma solidity 0.8.29;

abstract contract ERC165 {
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(ERC165).interfaceId || iERC173.owner.selector == interfaceId
            || type(ERC173).interfaceId == interfaceId;
    }
}

interface iERC173 {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}

abstract contract ERC173 is iERC173 {
    address public owner;

    error OnlyOwner();

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, OnlyOwner());
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, OnlyOwner());
        _;
    }
}

interface iToken {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function safeTransfer(address from, address to, uint256 amount) external;
}

abstract contract Rescue is ERC173 {
    function withdraw(address token, uint256 amount) external onlyOwner {
        iToken(token).transfer(owner, amount);
    }

    function safeWithdraw(address token, uint256 amount) external onlyOwner {
        iToken(token).safeTransfer(address(this), owner, amount);
    }

    function withdraw() external {
        payable(owner).transfer(address(this).balance);
    }
}

interface iReputeth {
    function balanceOf(address account) external view returns (uint256);
    function plus(address account) external view returns (uint256);
    function minus(address account) external view returns (uint256);
    function reputation(address account) external view returns (int256);
    function transfer(address to, uint256 amount) external returns (bool);
    function airdrop(address[] calldata accounts) external;
}

contract Reputeth is ERC165, ERC173, Rescue, iReputeth {
    string public constant name = "REPUT.ETH";
    string public constant symbol = "RPT";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = type(uint256).max;
    uint256 public constant initBal = 1e9 * 1e18;
    uint256 public constant limit = 1e5 * 1e18;

    // mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public plus;
    mapping(address => uint256) public minus;

    event Transfer(address indexed from, address indexed to, uint256 value);

    error OverLimit();
    error InactiveAddress();
    // error NotPermitted();
    // event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _owner) {
        owner = _owner;
    }

    function balanceOf(address account) external view returns (uint256) {
        if (minus[account] > initBal) return 0;
        return (initBal - minus[account]) + plus[account];
    }

    function reputation(address account) external view returns (int256) {
        return int256(plus[account]) - int256(minus[account]);
    }

    error SelfTransfer();

    function transfer(address to, uint256 amount) external returns (bool) {
        require(amount <= limit, OverLimit());
        require(to.balance > 0, InactiveAddress());
        require(msg.sender != to, SelfTransfer());
        unchecked {
            plus[msg.sender] += amount / 3;
            minus[to] += amount;
            emit Transfer(to, address(this), amount);
            emit Transfer(address(this), msg.sender, amount / 3);
        }
        return true;
    }
    /*
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        unchecked {
            uint sub = amount / 2;
            require(amount <= sub, OverLimit());
            require(to.balance > 0, InactiveAddress());
            require(from )
            if(allowance[from][msg.sender] != type(uint256).max) {
                require(allowance[from][msg.sender] >= amount, NotPermitted());
                allowance[from][msg.sender] -= amount;
            }
            sub = sub / 5;
            plus[msg.sender] += sub;
            plus[from] += sub;
            minus[to] += amount / 2;
            emit Transfer(to, address(this), amount);
            emit Transfer(address(this), msg.sender, amount / 3);
        }
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    */

    function airdrop(address[] calldata accounts) external onlyOwner {
        uint256 len = accounts.length;
        uint256 _bal = initBal;
        unchecked {
            for (uint256 i = 0; i < len; ++i) {
                emit Transfer(address(this), accounts[i], _bal);
            }
        }
    }
}
