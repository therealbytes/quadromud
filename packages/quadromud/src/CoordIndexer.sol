// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {QuadTree, QuadTreeLib, Point, PointLib, PointsLib, Rect, RectLib} from "quadrosol/QuadTree.sol";
import {IIndexRead} from "quadrosol/interfaces/IIndex.sol";

import {_Component as Component} from "./Component.sol";
import {IEntityIndexer} from "./IEntityIndexer.sol";

contract CoordIndexer is IEntityIndexer, IIndexRead {
    using QuadTreeLib for QuadTree;
    using RectLib for Rect;
    using PointLib for Point;
    using PointsLib for Point[];

    Component component;
    QuadTree tree;

    constructor(Component _component, Rect memory rect) {
        component = _component;
        tree.init(rect);
    }

    modifier onlyComponent() {
        require(msg.sender == address(component), "Unauthorized");
        _;
    }

    // ================ IEntityIndexer ================

    function update(
        uint256 entity,
        bytes memory oldValue,
        bytes memory newValue
    ) public onlyComponent {
        Point memory newPoint = _decodePoint(newValue);
        if (oldValue.length > 0) {
            Point memory oldPoint = _decodePoint(oldValue);
            if (oldPoint.eq(newPoint)) {
                return;
            }
            if (component.getEntitiesWithValue(oldValue).length == 0) {
                tree.remove(oldPoint);
            }
        }
        tree.add(newPoint);
    }

    function remove(uint256 entity, bytes memory value) public onlyComponent {
        if (component.getEntitiesWithValue(value).length == 0) {
            tree.remove(_decodePoint(value));
        }
    }

    function getEntities() public view returns (uint256[] memory) {
        return component.getEntities();
    }

    function getEntitiesWithValue(bytes memory value)
        public
        view
        returns (uint256[] memory)
    {
        return component.getEntitiesWithValue(value);
    }

    function has(uint256 entity) public view returns (bool) {
        return component.has(entity);
    }

    // ================ IEntityIndexer ================

    function size() public view returns (uint256) {
        return tree.size();
    }

    function has(Point memory coord) public view returns (bool) {
        return component.getEntitiesWithValue(abi.encode(coord)).length > 0;
    }

    function searchRect(Rect memory rect)
        public
        view
        returns (Point[] memory)
    {
        return _searchRect(rect);
    }

    function nearest(Point memory coord)
        public
        view
        returns (Point memory, bool)
    {
        return _nearest(coord);
    }

    // ================ Internal ================

    function _decodePoint(bytes memory value)
        internal
        pure
        returns (Point memory)
    {
        (int32 x, int32 y) = abi.decode(value, (int32, int32));
        return Point(x, y);
    }

    function _has(Point memory point) internal view returns (bool) {
        return component.getEntitiesWithValue(abi.encode(point)).length > 0;
    }

    function _searchRect(Rect memory rect)
        internal
        view
        returns (Point[] memory)
    {
        rect = tree.rect.overlap(rect);
        if (rect.area() < 50) {
            // Search set
            uint256 count;
            uint256 consCountGuess = (2 * tree.size() * rect.area()) /
                tree.rect.area();
            Point[] memory points = new Point[](consCountGuess);
            for (int32 x = rect.min.x; x < rect.max.x; x++) {
                for (int32 y = rect.min.y; y < rect.max.y; y++) {
                    Point memory point = Point(x, y);
                    if (_has(point)) {
                        if (count == points.length) {
                            points = points.expand();
                        }
                        points[count] = point;
                        count++;
                    }
                }
            }
            assembly {
                mstore(points, count)
            }
            return points;
        } else {
            // Search tree
            return tree.searchRect(rect);
        }
    }

    function _nearest(Point memory point)
        internal
        view
        returns (Point memory, bool)
    {
        return tree.nearest(point);
    }
}
