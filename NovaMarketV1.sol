// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NovaMarketV1 {
    struct Sale {
        uint id;
        string token_name;
        address token_contract;
        uint sale_amount;
        uint sale_price;
        address owner;
        bool already_sold;
    }

    Sale[] public sales;
    mapping(uint => Sale) public salesMapping;

    function createSale(
        uint _id,
        string memory _token_name,
        address _token_contract,
        uint _sale_amount,
        uint _sale_price,
        address _owner
    ) public {
        require(msg.sender == _owner, "Only the token owner can create sales");
        IERC20 token = IERC20(_token_contract);
        require(
            token.transferFrom(msg.sender, address(this), _sale_amount),
            "Token transfer failed"
        );
        Sale memory newSale = Sale(
            _id,
            _token_name,
            _token_contract,
            _sale_amount,
            _sale_price,
            _owner,
            false
        );
        sales.push(newSale);
        salesMapping[_id] = newSale;
    }

    function getNumberOfSales() public view returns (uint) {
        return sales.length;
    }

    function buySale(uint _saleId) public payable {
        Sale storage sale = salesMapping[_saleId];
        require(!sale.already_sold, "Sale already completed");
        require(
            msg.value >= sale.sale_price,
            "Insufficient funds to purchase the sale"
        );
        payable(sale.owner).transfer(sale.sale_price);
        IERC20 token = IERC20(sale.token_contract);
        require(
            token.transfer(msg.sender, sale.sale_amount),
            "Token transfer to buyer failed"
        );
        sale.already_sold = true;
    }
}
