// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/System.sol";
import "solecs/utils.sol";

// import { CoordComponent } from "quadromud/CoordComponent.sol";
import { Component, Coord, CoordRect, CoordIndexer } from "quadromud/CoordIndexer.sol";
import { ID as PositionComponentID } from "components/PositionComponent.sol";
import { IndexerComponent, ID as IndexerComponentID } from "components/IndexerComponent.sol";

import { WIDTH, HEIGHT } from "../constants.sol";

uint256 constant ID = uint256(keccak256("system.Init"));

contract InitSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    CoordRect memory rect = CoordRect(Coord(0, 0), Coord(WIDTH, HEIGHT));
    registerCoordIndexer(PositionComponentID, rect);
  }

  function executeTyped() public returns (bytes memory) {
    return execute(new bytes(0));
  }

  function registerCoordIndexer(uint256 component, CoordRect memory rect) internal {
    // Get components
    Component coordComponent = Component(getAddressById(components, component));
    IndexerComponent indexerComponent = IndexerComponent(getAddressById(components, IndexerComponentID));
    // Check requirements
    require(!indexerComponent.has(component), "Indexer already set");
    // Create indexer
    CoordIndexer indexer = new CoordIndexer(coordComponent, rect);
    // Register indexer
    coordComponent.registerIndexer(address(indexer));
    indexerComponent.set(component, address(indexer));
  }
}
