// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/System.sol";
import "solecs/utils.sol";

import { Coord } from "quadromud/CoordComponent.sol";
import { PositionComponent, ID as PositionComponentID } from "components/PositionComponent.sol";
import { ColorComponent, ID as ColorComponentID } from "components/ColorComponent.sol";

uint256 constant ID = uint256(keccak256("system.Paint"));

contract PaintSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    Coord memory coord = abi.decode(arguments, (Coord));
    PositionComponent positionComponent = PositionComponent(getAddressById(components, PositionComponentID));
    require(positionComponent.getEntitiesWithValue(abi.encode(coord)).length == 0, "Position already occupied");
    ColorComponent colorComponent = ColorComponent(getAddressById(components, ColorComponentID));
    uint256 entity = world.getUniqueEntityId();
    positionComponent.set(entity, coord);
    colorComponent.set(entity, 0x000000);
  }

  function executeTyped(Coord memory coord) public returns (bytes memory) {
    return execute(abi.encode(coord));
  }
}