// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { console } from "forge-std/Console.sol";

import "solecs/System.sol";
import "solecs/utils.sol";

import { IndexerComponent, ID as IndexerComponentID } from "components/IndexerComponent.sol";
import { ColorComponent, ID as ColorComponentID } from "components/ColorComponent.sol";
import { ID as PositionComponentID } from "components/PositionComponent.sol";
import { Rect, Point, CoordIndexer } from "quadromud/CoordIndexer.sol";

uint256 constant ID = uint256(keccak256("system.PaintRect"));

contract PaintRectSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    Rect memory rect = abi.decode(arguments, (Rect));
    ColorComponent colorComponent = ColorComponent(getAddressById(components, ColorComponentID));
    IndexerComponent indexerComponent = IndexerComponent(getAddressById(components, IndexerComponentID));
    CoordIndexer index = CoordIndexer(indexerComponent.getValue(PositionComponentID));
    Point[] memory coords = index.searchRect(rect);

    for (uint256 i = 0; i < coords.length; i++) {
      uint256[] memory entities = index.getEntitiesWithValue(abi.encode(coords[i]));
      // Note: Entity.length is always 1, so this loop is not strictly necessary
      for (uint256 j = 0; j < entities.length; j++) {
        uint256 color = colorComponent.getValue(entities[j]);
        colorComponent.set(entities[j], color == 0x000000 ? 0xffffff : 0x000000);
      }
    }
  }

  function executeTyped(Rect memory rect) public returns (bytes memory) {
    return execute(abi.encode(rect));
  }
}
