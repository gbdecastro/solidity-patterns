pragma solidity >=0.8.0 <0.9.0;

import "./Oracle.sol";

contract BurgerShop is Oracle {
    uint256 normalCost = 0.2 ether;
    uint256 deluxCost = 0.4 ether;

    event BoughtBurguer(address indexed _from, uint256 _cost);

    enum Stage {
        READY_TO_ORDER,
        MAKE_BURGER,
        DELIVER_BURGER
    }

    Stage public burgerShopStage = Stage.READY_TO_ORDER;

    modifier shouldPay(uint256 _cost) {
        require(
            msg.value >= _cost,
            "The burger costs more! YOU DONT HAVE MONEY"
        );
        _;
    }

    modifier isAtStage(Stage _stage) {
        require(_stage == burgerShopStage, "Not at correct stage");
        _;
    }

    function buyNormalBurguer()
        public
        payable
        shouldPay(normalCost)
        isAtStage(burgerShopStage)
    {
        updateStage(Stage.MAKE_BURGER);
        emit BoughtBurguer(msg.sender, normalCost);
    }

    function buyDeluxBurger()
        public
        payable
        shouldPay(deluxCost)
        isAtStage(burgerShopStage)
    {
        updateStage(Stage.MAKE_BURGER);
        emit BoughtBurguer(msg.sender, normalCost);
    }

    function refund(address _to, uint256 _cost) public {
        require(
            _cost == normalCost || _cost == deluxCost,
            "You are trying to refund the wrong amount"
        );

        uint256 balanceBeforeTransfer = address(this).balance;

        if (balanceBeforeTransfer < _cost) {
            revert("Not enough funds!");
        }

        (bool success, ) = payable(_to).call{value: _cost}("");
        require(success);

        assert(address(this).balance == balanceBeforeTransfer - _cost);
    }

    function getFunds() public view returns (uint256) {
        return address(this).balance;
    }

    function madeBurger() public isAtStage(Stage.MAKE_BURGER) {
        updateStage(Stage.DELIVER_BURGER);
    }

    function pickUpBurger() public isAtStage(Stage.DELIVER_BURGER) {
        updateStage(Stage.READY_TO_ORDER);
    }

    function updateStage(Stage _stage) public {
        burgerShopStage = _stage;
    }
}
