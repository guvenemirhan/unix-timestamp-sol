// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Libraries/DateOperations.sol";

contract DateOperationsTest is Test {
    using DateOperations for DateOperations.Date;
    using DateOperations for uint256;

    function setUp() public {
    }

    function assertEq(DateOperations.Date memory a, DateOperations.Date memory b) internal {
        bool success = true;
        if (a.year != b.year ) {
            success = false;
            emit log_named_uint("      Year Left", a.year);
            emit log_named_uint("     Year Right", b.year);
        }
        if (a.month != b.month ) {
            success = false;
            emit log_named_uint("      Month Left", a.month);
            emit log_named_uint("     Month Right", b.month);
        }
        if (a.day != b.day  ) {
            success = false;
            emit log_named_uint("      Day Left", a.day);
            emit log_named_uint("     Day Right", b.day);
        }
        if (a.hour != b.hour ) {
            success = false;
            emit log_named_uint("      Hour Left", a.hour);
            emit log_named_uint("     Hour Right", b.hour);
        }
        if (a.minute != b.minute) {
            success = false;
            emit log_named_uint("      Minute Left", a.minute);
            emit log_named_uint("     Minute Right", b.minute);
        }
        if (a.second != b.second) {
            success = false;
            emit log_named_uint("      Second Left", a.second);
            emit log_named_uint("     Second Right", b.second);
        }
        if (!success) {
            emit log("Error: a == b not satisfied [DateOperations.Date]");
            fail();
        }

    }


    function testTimestampToDate() public view {
        uint32 timestamp = 4070855522;
        DateOperations.Date memory date = uint256(timestamp).toDate();
        console.log("Day: ", date.day);
        console.log("M: ", date.month);
        console.log("Y: ", date.year);
        console.log("H: ", date.hour);
        console.log("M: ", date.minute);
        console.log("S: ", date.second);

    }


    function testFuzz_DateToTimestamp(DateOperations.Date memory date) public {
        vm.assume(((date.day <= 28 && date.month == 2) || (date.day <= 30 && date.month != 2)) && date.day >= 1 && date.month <= 12 && date.month > 1 && date.year > 1970 && date.year < 2100 && date.hour < 24 && date.minute < 60 && date.second < 60);
        uint256 timestamp = date.toTimestamp();
        DateOperations.Date memory toDate = timestamp.toDate();
        assertEq(date, toDate);

    }


    function testFuzz_TimestampToDate(uint32 timestamp) public {
        DateOperations.Date memory date = uint256(timestamp).toDate();
        uint256 dateToTime = date.toTimestamp();
        assertEq(uint256(timestamp), dateToTime);
    }
}
