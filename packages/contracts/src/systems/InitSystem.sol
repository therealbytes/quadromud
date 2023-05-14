// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/System.sol";
import "solecs/utils.sol";

import { Component, Point, Rect, CoordIndexer } from "quadromud/CoordIndexer.sol";
import { ID as PositionComponentID } from "components/PositionComponent.sol";
import { IndexerComponent, ID as IndexerComponentID } from "components/IndexerComponent.sol";

import { WIDTH, HEIGHT } from "../constants.sol";

uint256 constant ID = uint256(keccak256("system.Init"));

contract InitSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    Rect memory rect = Rect(Point(0, 0), Point(WIDTH, HEIGHT));
    registerCoordIndexer(PositionComponentID, rect);
    return new bytes(0);
  }

  function executeTyped() public returns (bytes memory) {
    return execute(new bytes(0));
  }

  function registerCoordIndexer(uint256 component, Rect memory rect) internal {
    // Get components
    Component coordComponent = Component(getAddressById(components, component));
    IndexerComponent indexerComponent = IndexerComponent(getAddressById(components, IndexerComponentID));
    // Check requirements
    require(!indexerComponent.has(component), "Indexer already set");
    // Create indexer
    address indexerAddr = address(new CoordIndexer(coordComponent, rect));
    // Register indexer
    coordComponent.registerIndexer(indexerAddr);
    indexerComponent.set(component, indexerAddr);
  }
}
