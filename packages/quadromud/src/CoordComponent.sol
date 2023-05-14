// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {LibTypes} from "solecs/LibTypes.sol";
import {Point} from "quadrosol/geo/Index.sol";
import {_Component as Component} from "./Component.sol";

contract CoordComponent is Component {
    constructor(address world, uint256 id) Component(world, id) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "x";
        values[0] = LibTypes.SchemaValue.INT32;

        keys[1] = "y";
        values[1] = LibTypes.SchemaValue.INT32;
    }

    function set(uint256 entity, Point calldata value) public virtual {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity)
        public
        view
        virtual
        returns (Point memory)
    {
        (int32 x, int32 y) = abi.decode(getRawValue(entity), (int32, int32));
        return Point(x, y);
    }

    function getEntitiesWithValue(Point calldata coord)
        public
        view
        virtual
        returns (uint256[] memory)
    {
        return getEntitiesWithValue(abi.encode(coord));
    }
}
