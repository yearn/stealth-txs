// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@lbertenasco/contract-utils/contracts/utils/Governable.sol";
import "@lbertenasco/contract-utils/contracts/utils/CollectableDust.sol";
import "@lbertenasco/contract-utils/contracts/utils/StealthTx.sol";

import '../interfaces/stealth/IStealthRelayer.sol';

/*
 * StealthRelayer
 */
contract StealthRelayer is Governable, CollectableDust, StealthTx, IStealthRelayer {
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal _jobs;

    constructor(address _stealthVault) Governable(msg.sender) StealthTx(_stealthVault) {}

    function execute(
        address _job,
        bytes memory _callData,
        bytes32 _stealthHash,
        uint256 _blockNumber
    ) external payable override onlyValidJob(_job) validateStealthTxAndBlock(_stealthHash, _blockNumber) returns (bytes memory _returnData) {
        return _job.functionCallWithValue(_callData, msg.value, "StealthRelayer::execute:call-reverted");
    }

    // Setup trusted contracts to call (jobs)
    function addJobs(address[] calldata _jobsList) external override onlyGovernor {
         for (uint i = 0; i < _jobsList.length; i++) {
            _addJob(_jobsList[i]);
        }
    }
    function addJob(address _job) external override onlyGovernor {
        _addJob(_job);
    }
    function _addJob(address _job) internal {
        require(_jobs.add(_job), 'StealthRelayer::addJob:job-already-added'); 
    }

    function removeJobs(address[] calldata _jobsList) external override onlyGovernor {
         for (uint i = 0; i < _jobsList.length; i++) {
            _removeJob(_jobsList[i]);
        }
    }
    function removeJob(address _job) external override onlyGovernor {
        _removeJob(_job);
    }
    function _removeJob(address _job) internal {
        require(_jobs.remove(_job), 'StealthRelayer::removeJob:invalid-job'); 
    }

    modifier onlyValidJob(address _job) {
        require(_jobs.contains(_job), 'StealthRelayer::onlyValidJob:invalid-job');
        _;
    }

    // StealthTx: restricted-access
    function setPenalty(uint256 _penalty) external override onlyGovernor {
        _setPenalty(_penalty);
    }

    function migrateStealthVault() external override onlyGovernor {
        _migrateStealthVault();
    }

    // Governable: restricted-access
    function setPendingGovernor(address _pendingGovernor) external override onlyGovernor {
        _setPendingGovernor(_pendingGovernor);
    }

    function acceptGovernor() external override onlyPendingGovernor {
        _acceptGovernor();
    }

    // Collectable Dust: restricted-access
    function sendDust(
        address _to,
        address _token,
        uint256 _amount
    ) external override onlyGovernor {
        _sendDust(_to, _token, _amount);
    }
}