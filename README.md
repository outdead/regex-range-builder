# Regex Range Builder
Numeric range regular expression builder written in bash. Inspired by [erwinyusrizal's RegexNumericRangeGenerator](https://github.com/erwinyusrizal/RegexNumericRangeGenerator)
I needed this for command line use, so I did a bash implementation. If this is useful for you too, you are welcome.

## Usage

```text
range.sh [range] [params]

Examples:
  ./range.sh 137 719
  ./range.sh 137 719 1
  ./range.sh 137 719 1 1
  ./range.sh 137 719 0 1
  ./range.sh 137 719 0 0 1

Range:
  Positive integers describing the search range.
  
Params
  Bool integers to set up a regular expression
  first - Matching Whole Lines
  second - Matching Leading Zeroes
  third - Matching Whole Word
```

## Usage with grep

```text
Examples:
  egrep "$(./range.sh 137 719 0 0 1)" README.md
  egrep "\\b$(./range.sh 719 2335)\\b" range_test.sh
```