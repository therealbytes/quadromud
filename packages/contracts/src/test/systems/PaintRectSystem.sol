// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Deploy } from "../Deploy.sol";
import "std-contracts/test/MudTest.t.sol";

import { WIDTH, HEIGHT } from "../../constants.sol";

// TODO: unify coord struct [?]
import { Coord, CoordRect } from "quadromud/CoordIndexer.sol";

import { InitSystem, ID as InitSystemID } from "systems/InitSystem.sol";
import { PaintSystem, ID as PaintSystemID } from "systems/PaintSystem.sol";
import { PaintRectSystem, ID as PaintRectSystemID } from "systems/PaintRectSystem.sol";
import { ColorComponent, ID as ColorComponentID } from "components/ColorComponent.sol";
import { PositionComponent, ID as PositionComponentID } from "components/PositionComponent.sol";

contract PaintRectSystemTest is MudTest {
  constructor() MudTest(new Deploy()) {}

  // function setUp() public override {
  //   super.setUp();
  //   InitSystem(system(InitSystemID)).executeTyped();
  // }

  function testPaintRect() public {
    InitSystem(system(InitSystemID)).executeTyped();

    CoordRect memory indexRect = CoordRect(Coord(0, 0), Coord(WIDTH, HEIGHT));

    Coord[5] memory coords = [Coord(-6, -6), Coord(-5, -5), Coord(5, 5), Coord(10, 10), Coord(11, 11)];
    CoordRect memory coordRect = CoordRect(Coord(-6, -6), Coord(10, 10));

    for (uint256 i = 0; i < coords.length; i++) {
      PaintSystem(system(PaintSystemID)).executeTyped(coords[i]);
    }

    PaintRectSystem(system(PaintRectSystemID)).executeTyped(coordRect);

    for (uint256 i = 0; i < coords.length; i++) {
      uint256 expectedColor = contains(indexRect, coords[i]) && contains(coordRect, coords[i]) ? 0xFFFFFF : 0x000000;
      uint256[] memory entities = PositionComponent(component(PositionComponentID)).getEntitiesWithValue(coords[i]);
      for (uint256 j = 0; j < entities.length; j++) {
        uint256 color = ColorComponent(component(ColorComponentID)).getValue(entities[j]);
        assertEq(color, expectedColor);
      }
    }
  }

  function contains(CoordRect memory rect, Coord memory coord) internal pure returns (bool) {
    return rect.min.x <= coord.x && coord.x < rect.max.x && rect.min.y <= coord.y && coord.y < rect.max.y;
  }
}
