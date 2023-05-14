// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/System.sol";
import "solecs/utils.sol"; 

import { Component, Point, Rect, CoordIndexer } from "../CoordIndexer.sol";
import { ID as PositionComponentID } from "components/PositionComponent.sol";

uint256 constant ID = uint256(keccak256("system.Init"));

contract InitSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (uint256 x, uint256 y) = abi.decode(arguments, (uint256, uint256));
    Rect memory rect = Rect(Point(0, 0), Point(int32(int256(x)), int32(int256(y))));
    address indexerAddr = registerCoordIndexer(PositionComponentID, rect);
    return abi.encode(indexerAddr);
  }

  function executeTyped(uint256 x, uint256 y) public returns (bytes memory) {
    return execute(abi.encode(x, y));
  }

  function registerCoordIndexer(uint256 component, Rect memory rect) internal returns (address) {
    // Get components
    Component coordComponent = Component(getAddressById(components, component));
    // Create indexer
    CoordIndexer indexer = new CoordIndexer(coordComponent, rect);
    // Register indexer
    coordComponent.registerIndexer(address(indexer));
    
    return address(indexer);
  }
}
