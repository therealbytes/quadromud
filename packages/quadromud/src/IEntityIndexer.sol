// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IEntityContainer} from "solecs/interfaces/IEntityContainer.sol";

interface IEntityIndexer is IEntityContainer {
    function update(
        uint256 entity,
        bytes memory oldValue,
        bytes memory newValue
    ) external;

    function remove(uint256 entity, bytes memory value) external;
}
