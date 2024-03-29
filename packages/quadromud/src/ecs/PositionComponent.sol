// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {CoordComponent} from "../CoordComponent.sol";

uint256 constant ID = uint256(keccak256("component.Position"));

contract PositionComponent is CoordComponent {
  constructor(address world) CoordComponent(world, ID) {}
}
