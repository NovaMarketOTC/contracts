// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IExternalContract {
    function read() external view returns (uint256);
}

contract NovaMarketV1 {
    IExternalContract public externalContractInstance;

    function callExternalFunction() public view returns (uint value) {
        return externalContractInstance.read();
    }

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
    mapping(uint => Sale) public salesMap;
    uint public nextSaleId = 1;

    constructor(address _externalContractAddress) {
        externalContractInstance = IExternalContract(_externalContractAddress);
    }

    function createSale(
        string memory _token_name,
        address _token_contract,
        uint _sale_amount,
        uint _sale_price
    ) public {
        IERC20 token = IERC20(_token_contract);
        require(
            token.transferFrom(msg.sender, address(this), _sale_amount),
            "Token transfer failed"
        );
        Sale memory newSale = Sale(
            nextSaleId,
            _token_name,
            _token_contract,
            _sale_amount,
            _sale_price,
            msg.sender,
            false
        );
        sales.push(newSale);
        salesMap[nextSaleId] = newSale;
        nextSaleId++;
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
