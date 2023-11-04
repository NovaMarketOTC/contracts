// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NovaMarketV1 {
    struct Sale {
        uint id;
        uint sale_amount;
        uint sale_price;
        address token_contract;
        address owner;
        string token_name;
        bool already_sold;
    }

    Sale[] public sales;
    mapping(uint => Sale) public salesMap;
    uint public nextSaleId = 1;

    function createSale(
        string memory _token_name,
        address _token_contract,
        uint _sale_amount,
        uint _sale_price
    ) public {
        IERC20 token = IERC20(_token_contract);
        uint currID = nextSaleId;
        require(
            token.transferFrom(msg.sender, address(this), _sale_amount),
            "Token transfer failed"
        );
        Sale memory newSale = Sale(
            currID,
            _sale_amount,
            _sale_price,
            _token_contract,
            msg.sender,
            _token_name,
            false
        );
        sales.push(newSale);
        salesMap[currID] = newSale;
        nextSaleId = currID + 1;
    }

    function getNumberOfSales() public view returns (uint) {
        return sales.length;
    }

    function buySale(uint _saleId) public payable {
        Sale storage sale = salesMap[_saleId];
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

    function getSalePrice(uint _saleId) public view returns (uint) {
        Sale storage sale = salesMap[_saleId];
        return sale.sale_price;
    }

    function getSaleAmount(uint _saleId) public view returns (uint) {
        Sale storage sale = salesMap[_saleId];
        return sale.sale_amount;
    }

    function getTokenContract(uint _saleId) public view returns (address) {
        Sale storage sale = salesMap[_saleId];
        return sale.token_contract;
    }

    function getOwner(uint _saleId) public view returns (address) {
        Sale storage sale = salesMap[_saleId];
        return sale.owner;
    }

    function isSold(uint _saleId) public view returns (bool) {
        Sale storage sale = salesMap[_saleId];
        return sale.already_sold;
    }

    function getAllSales() public view returns (Sale[] memory) {
        return sales;
    }
}
