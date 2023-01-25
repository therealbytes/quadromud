// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Deploy } from "../Deploy.sol";
import "std-contracts/test/MudTest.t.sol";

import { InitSystem, ID as InitSystemID } from "systems/InitSystem.sol";
import { Coord, PaintSystem, ID as PaintSystemID } from "systems/PaintSystem.sol";
import { PositionComponent, ID as PositionComponentID } from "components/PositionComponent.sol";

contract PaintSystemTest is MudTest {

  Coord coord = Coord(0, 0);

  constructor() MudTest(new Deploy()) {}

  // function setUp() public override {
  //   super.setUp();
  //   InitSystem(system(InitSystemID)).executeTyped();
  // }

  function testPaint() public {
    InitSystem(system(InitSystemID)).executeTyped();
    PaintSystem(system(PaintSystemID)).executeTyped(coord);
    uint256[] memory entities = PositionComponent(component(PositionComponentID)).getEntitiesWithValue(coord);
    assertEq(entities.length, 1);
  }
}
