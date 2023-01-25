// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Deploy } from "../Deploy.sol";
import "std-contracts/test/MudTest.t.sol";

import { InitSystem, ID as InitSystemID } from "systems/InitSystem.sol";
import { IndexerComponent, ID as IndexerComponentID } from "components/IndexerComponent.sol";
import { ID as PositionComponentID } from "components/PositionComponent.sol";

contract PaintSystemTest is MudTest {
  constructor() MudTest(new Deploy()) {}

  function testInit() public {
    InitSystem(system(InitSystemID)).executeTyped();
    IndexerComponent indexerComponent = IndexerComponent(component(IndexerComponentID));

    uint256[] memory entities = indexerComponent.getEntities();
    assertEq(entities.length, 1);
    uint256 entity = entities[0];
    assertEq(entity, PositionComponentID);
    address value = indexerComponent.getValue(entity);
    assertTrue(value != address(0));

    console.log("value: %s", value);
  }
}
