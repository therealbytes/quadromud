// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Deploy} from "./Deploy.sol";
import "std-contracts/test/MudTest.t.sol";

import {_Component as Component} from "../Component.sol";
import {CoordIndexer, Point, Rect} from "../CoordIndexer.sol";

import {ID as PositionComponentID} from "../ecs/PositionComponent.sol";
import {ComponentDevSystem, ID as ComponentDevSystemID} from "../ecs/ComponentDevSystem.sol";
import {InitSystem, ID as InitSystemID} from "../ecs/InitSystem.sol";

contract CoordIndexerTest is MudTest {
    CoordIndexer coordIndexer;

    constructor() MudTest(new Deploy()) {}

    function setUp() public override {
        super.setUp();
        bytes memory coordIndexerAddrBytes = InitSystem(system(InitSystemID))
            .executeTyped(10, 10);
        coordIndexer = CoordIndexer(
            abi.decode(coordIndexerAddrBytes, (address))
        );
    }

    function testUpdate() public {
        uint256 entity1 = world.getUniqueEntityId();
        uint256 entity2 = entity1 + 1;
        Point memory coord1 = Point(5, 5);
        Point memory coord2 = Point(6, 6);

        console.log("e1 => c1");
        setPosition(entity1, coord1);
        assertTrue(coordIndexer.has(coord1));
        assertTrue(coordIndexer.size() == 1);

        console.log("e1 => c2");
        setPosition(entity1, coord2);
        assertTrue(coordIndexer.has(coord2));
        assertTrue(!coordIndexer.has(coord1));
        assertTrue(coordIndexer.size() == 1);

        console.log("e2 => c1");
        setPosition(entity2, coord1);
        assertTrue(coordIndexer.has(coord1));
        assertTrue(coordIndexer.has(coord2));
        assertTrue(coordIndexer.size() == 2);
    }

    function testRemove() public {
        uint256 entity1 = world.getUniqueEntityId();
        uint256 entity2 = entity1 + 1;
        Point memory coord1 = Point(5, 5);
        setPosition(entity1, coord1);
        setPosition(entity2, coord1);

        console.log("e1 => null");
        removePosition(entity1);
        assertTrue(coordIndexer.has(coord1));
        assertTrue(coordIndexer.size() == 1);

        console.log("e2 => null");
        removePosition(entity2);
        assertTrue(!coordIndexer.has(coord1));
        assertTrue(coordIndexer.size() == 0);
    }

    // TODO: missing tests and test cases

    function testSearchRect() public {
        uint256 entity1 = world.getUniqueEntityId();
        setPosition(entity1, Point(5, 5));
        setPosition(entity1 + 1, Point(6, 6));
        setPosition(entity1 + 2, Point(7, 7));
        setPosition(entity1 + 3, Point(10, 10));
        Rect memory rect = Rect(Point(6, 6), Point(11, 11));
        Point[] memory coords = coordIndexer.searchRect(rect);

        assertTrue(coords.length == 2);
        assertTrue(
            coordEq(coords[0], Point(6, 6)) || coordEq(coords[0], Point(7, 7))
        );
        assertTrue(
            coordEq(coords[1], Point(6, 6)) || coordEq(coords[1], Point(7, 7))
        );
    }

    function testNearest() public {
        Point memory coord;
        bool ok;

        (coord, ok) = coordIndexer.nearest(Point(-1, -1));

        assertTrue(!ok);

        uint256 entity1 = world.getUniqueEntityId();
        setPosition(entity1, Point(5, 5));
        setPosition(entity1 + 1, Point(6, 6));
        setPosition(entity1 + 2, Point(7, 7));
        setPosition(entity1 + 3, Point(10, 10));

        (coord, ok) = coordIndexer.nearest(Point(-1, -1));

        assertTrue(ok);
        assertTrue(coordEq(coord, Point(5, 5)));
    }

    function setPosition(uint256 entity, Point memory value) private {
        ComponentDevSystem(system(ComponentDevSystemID)).executeTyped(
            PositionComponentID,
            entity,
            abi.encode(value)
        );
    }

    function removePosition(uint256 entity) private {
        ComponentDevSystem(system(ComponentDevSystemID)).executeTyped(
            PositionComponentID,
            entity,
            bytes("")
        );
    }

    function coordEq(Point memory a, Point memory b)
        private
        pure
        returns (bool)
    {
        return a.x == b.x && a.y == b.y;
    }
}
