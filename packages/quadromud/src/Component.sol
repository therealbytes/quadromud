// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Component} from "solecs/Component.sol";

import {IEntityIndexer} from "./IEntityIndexer.sol";

abstract contract _Component is Component {
    IEntityIndexer[] internal _indexers;

    constructor(address world, uint256 id) Component(world, id) {}

    function registerIndexer(address indexer)
        external
        virtual
        override
        onlyWriter
    {
        _indexers.push(IEntityIndexer(indexer));
    }

    function _set(uint256 entity, bytes memory value)
        internal
        virtual
        override
    {
        // Store the entity
        entities.add(entity);

        bytes memory oldValue = entityToValue[entity];

        // Remove the entity from the previous reverse mapping if there is one
        valueToEntities.remove(uint256(keccak256(oldValue)), entity);

        // Add the entity to the new reverse mapping
        valueToEntities.add(uint256(keccak256(value)), entity);

        // Store the entity's value; Emit global event
        super._set(entity, value);

        for (uint256 i = 0; i < _indexers.length; i++) {
            _indexers[i].update(entity, oldValue, value);
        }
    }

    function _remove(uint256 entity) internal virtual override {
        bytes memory oldValue = entityToValue[entity];

        // If there is no entity with this value, return
        if (valueToEntities.size(uint256(keccak256(oldValue))) == 0) return;

        // Remove the entity from the reverse mapping
        valueToEntities.remove(uint256(keccak256(oldValue)), entity);

        // Remove the entity from the entity list
        entities.remove(entity);

        // Remove the entity from the mapping; Emit global event
        super._remove(entity);

        for (uint256 i = 0; i < _indexers.length; i++) {
            _indexers[i].remove(entity, oldValue);
        }
    }
}
