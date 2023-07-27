# Unix-timestamp-sol

## DateOperations

_This library performs conversion operations between Unix timestamp and human readable time._

### Date

```solidity
struct Date {
  uint8 day;
  uint8 month;
  uint16 year;
  uint8 hour;
  uint8 minute;
  uint8 second;
  int8 gmt;
}
```

### InvalidGmtValue

```solidity
error InvalidGmtValue(int256 value, string dateType)
```

### InvalidDateValue

```solidity
error InvalidDateValue(uint256 value, string dateType)
```

### paramsCheck

```solidity
modifier paramsCheck(struct DateOperations.Date date)
```

It checks whether the parameters exceed the specified limits or not.

### toTimestamp

```solidity
function toTimestamp(struct DateOperations.Date date) internal pure returns (uint256 unixTimestamp)
```

It converts the given date parameter to a Unix timestamp value.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| date | struct DateOperations.Date | The date that will be converted to a Unix timestamp value. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| unixTimestamp | uint256 | The unix timestamp value of the given date. |

### toDate

```solidity
function toDate(uint256 unixTimestamp) internal pure returns (struct DateOperations.Date dates)
```

