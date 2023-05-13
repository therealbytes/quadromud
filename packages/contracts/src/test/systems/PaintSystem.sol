// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Deploy } from "../Deploy.sol";
import "std-contracts/test/MudTest.t.sol";

import { Point } from "quadromud/CoordIndexer.sol";
import { PaintSystem, ID as PaintSystemID } from "systems/PaintSystem.sol";
import { PositionComponent, ID as PositionComponentID } from "components/PositionComponent.sol";

contract PaintSystemTest is MudTest {

  constructor() MudTest(new Deploy()) {}

  function testPaint() public {
    Point memory coord = Point(0, 0);
    PaintSystem(system(PaintSystemID)).executeTyped(coord);
    uint256[] memory entities = PositionComponent(component(PositionComponentID)).getEntitiesWithValue(coord);
    assertEq(entities.length, 1);
  }
}
