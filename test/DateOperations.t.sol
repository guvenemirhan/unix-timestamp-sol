// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Libraries/DateOperations.sol";

contract DateOperationsTest is Test {
    using DateOperations for DateOperations.Date;
    using DateOperations for uint256;

    function setUp() public {
    }

    function testDateToTimestamp() public {
        DateOperations.Date memory date;
        date.day = 1;
        date.month = 1;
        date.year = 1970;
        date.hour = 0;
        date.minute = 0;
        date.second = 1;
        date.gmt = 0;
        uint256 timestamp = date.toTimestamp();
        assertEq(timestamp, 1);

    }


    function testFuzz_TimestampToDate(uint32 timestamp) public {
        DateOperations.Date memory date = uint256(timestamp).toDate();
        uint256 dateToTime = date.toTimestamp();
        assertEq(uint256(timestamp), dateToTime);
    }
}
