// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title  Unix timestamp library
/// @dev This library performs conversion operations between Unix timestamp and human readable time.
library DateOperations {
   /// @dev Using uint8 for the maximum values reduces the number of operations and ensures gas savings during the process. Also it is restrictive for the user.
   struct Date {
      uint8 day;
      uint8 month;
      uint16 year;
      uint8 hour;
      uint8 minute;
      uint8 second;
      int8 gmt;
   }

   error InvalidGmtValue(int256 value, string dateType);
   error InvalidDateValue(uint256 value, string dateType);

   /// @notice It checks whether the parameters exceed the specified limits or not.
   modifier paramsCheck(Date memory date) {
      if (date.day > 31) revert InvalidDateValue(date.day, "Day");
      if (date.month > 12) revert InvalidDateValue(date.month, "Month");
      if (date.year < 1970) revert InvalidDateValue(date.year, "Year");
      if (date.hour > 24) revert InvalidDateValue(date.hour, "Day");
      if (date.minute > 60) revert InvalidDateValue(date.minute, "Minute");
      if (date.second > 60) revert InvalidDateValue(date.second, "Second");
      if (
         date.gmt > 12 ||
         date.gmt < -12 ||
         (date.year == 1970 && date.month == 1 && date.day == 1 && (date.gmt > 0 && int(uint(date.hour)) < date.gmt))
      ) revert InvalidGmtValue(date.gmt, "GMT");
      _;
   }

   /// @notice It converts the given date parameter to a Unix timestamp value.
   /// @param date The date that will be converted to a Unix timestamp value.
   /// @return unixTimestamp The unix timestamp value of the given date.
   function toTimestamp(Date memory date) internal pure returns (uint256 unixTimestamp) {
      //The epoch of unix timestamp is 1970.
      int256 unixEpoch = 1970;

      // how many days have passed in the year until the first day of each month.
      uint16[13] memory monthPastDays;
      monthPastDays = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];

      assembly {
         // We need to add an offset of 32 bytes to read the array data.
         let daysArray := add(monthPastDays, 0x20)

         // Creating references for frequently used values from the date object.
         let year := mload(add(date, 0x40))
         let month := mload(add(date, 0x20))


         // Calculating the total number of days from the UNIX epoch to the given date.
         // The calculation takes into account leap years and the current day of the month.
         let totalDays := sub(
            add(
               add(
                  sub(add(mul(sub(year, unixEpoch), 365), sdiv(sub(year, 1969), 4)), sdiv(sub(year, 1901), 100)),
                  sdiv(sub(year, 1601), 400)
               ),
               mload(date)
            ),
            1
         )

         // Determines if the given year is a leap year. As a general rule, leap years are years that are divisible by 4.
         // However, there is an exception: among the years that are multiples of 100, only those that can be evenly divided by 400 are considered leap years.
         let isLeap := and(eq(mod(year, 4), 0), or(iszero(eq(mod(year, 100), 0)), eq(mod(year, 400), 0)))

         // If it's a leap year, adds a day to the total value.
         if and(gt(month, 2), isLeap) {
            totalDays := add(totalDays, 1)
         }

         // Converts the calculated total number of days to seconds and adds to the total value.
         unixTimestamp := mul(totalDays, 86400)
         //Then adds hour, minute, and second values in seconds to the total value.
         unixTimestamp := add(
            unixTimestamp,
            add(add(mul(mload(add(date, 0x60)), 3600), mul(mload(add(date, 0x80)), 60)), mload(add(date, 0xA0)))
         )
      }
   }

   // @dev Converts a unix timestamp into a Date structure.
   //
   // @param unixTimestamp The timestamp to be converted into a date structure.
   //
   // @return dates A Date struct representing the date information extracted from the unix timestamp.
   function toDate(uint256 unixTimestamp) internal pure returns (Date memory dates) {
      // Ensure that the given unix timestamp is within the range of a uint32.
      // Realistic timestamp values are within this range.
      // As the value increases, the number of operations to perform increases as well, leading to more gas consumption.
      require(unixTimestamp <= type(uint32).max, "The input timestamp value exceeds the maximum limit for uint32.");

      //The epoch of unix timestamp is 1970.
      uint256 unixEpoch = 1970;

      // how many days have passed in the year until the first day of each month.
      uint8[13] memory daysOfMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31];

      uint256 currYear;
      uint256 pastDays;
      uint256 extraTime;
      uint256 leapDays;
      uint256 index;
      uint256 month;
      uint256 isLeapYear;

      assembly {
         // calculates the total number of days.
         pastDays := sdiv(unixTimestamp, 86400)

         // calculates the extra time to compute hours, minutes, and seconds values.
         extraTime := smod(unixTimestamp, 86400)

         // takes the Unix epoch as a reference to calculate the year.
         currYear := unixEpoch

         // Used for controlling loop termination.
         let flag := 0

         // We need to add an offset of 32 bytes to read the array data.
         let daysArray := add(daysOfMonth, 0x20)

         // Calculating current year
         for {

         } eq(flag, 1) {

         } {
            // Determines if the given year is a leap year. As a general rule, leap years are years that are divisible by 4.
            // However, there is an exception: among the years that are multiples of 100, only those that can be evenly divided by 400 are considered leap years.
            let isLeap := and(eq(mod(currYear, 4), 0), or(iszero(eq(mod(currYear, 100), 0)), eq(mod(currYear, 400), 0)))

            // If the year is a leap year, subtract 366 from pastDays.
            if isLeap {
               if slt(pastDays, 366) {
                  flag := 1
               }
               pastDays := sub(pastDays, 366)
            }

            // If the year is not a leap year, subtract 365 from pastDays.
            if iszero(isLeap) {
               if slt(pastDays, 365) {
                  flag := 1
               }
               pastDays := sub(pastDays, 365)
            }

            // Increase the current year by one.
            currYear := add(currYear, 1)
         }

         // Updating leapDays because it will give days till previous day and we have include current day
         leapDays := add(pastDays, 1)

         // Leap year is recalculated
         if and(eq(mod(currYear, 4), 0), or(iszero(eq(mod(currYear, 100), 0)), eq(mod(currYear, 400), 0))) {
            isLeapYear := 1
         }

         // value is reset for the new loop
         flag := 0

         // Calculating month and day
         if eq(isLeapYear, 1) {
            for {

            } eq(flag, 1) {

            } {
               // if the month is february
               if eq(index, 1) {
                  // if extra days less than 29 -> break
                  if slt(sub(leapDays, 29), 0) {
                     flag := 1
                  }
                  // If it's a leap year and the index is 1 (representing February),
                  // and the extra days are equal to or more than 29, then 1 is added
                  // to the month and 29 is subtracted from the extra days.
                  month := add(month, 1)
                  leapDays := sub(leapDays, 29)
               }
               // else
               if iszero(eq(index, 1)) {
                  let currMonth := mload(add(daysArray, mul(index, 0x20)))
                  if slt(sub(leapDays, currMonth), 0) {
                     flag := 1
                  }
                  month := add(month, 1)
                  leapDays := currMonth
               }
               index := add(index, 1)
            }
         }

         // if the year is not a leap year
         if iszero(eq(isLeapYear, 1)) {
            for {

            } eq(flag, 1) {

            } {
               let currMonth := mload(add(daysArray, mul(index, 0x20)))
               if slt(sub(leapDays, currMonth), 0) {
                  flag := 1
               }
               month := add(month, 1)
               leapDays := sub(leapDays, currMonth)
               index := add(index, 1)
            }
         }

         // Current Month
         if sgt(leapDays, 0) {
            month := add(month, 1)
            mstore(dates, leapDays)
         }
         if iszero(sgt(leapDays, 0)) {
            // february
            if and(eq(month, 2), eq(isLeapYear, 1)) {
               mstore(dates, 29)
            }
            if iszero(and(eq(month, 2), eq(isLeapYear, 1))) {
               let currMonth := mload(add(daysArray, mul(sub(month, 1), 0x20)))
               mstore(dates, currMonth)
            }
         }

         // Constructs the return value.
         mstore(add(dates, 0x20), month)
         mstore(add(dates, 0x40), currYear)
         mstore(add(dates, 0x60), sdiv(extraTime, 3600))
         mstore(add(dates, 0x80), sdiv(smod(extraTime, 3600), 60))
         mstore(add(dates, 0xA0), smod(mod(extraTime, 3600), 60))
      }
   }
}
