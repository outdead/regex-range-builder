#!/usr/bin/env bash

. ./range.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
DEFAULT='\033[0m'

FAIL=$(echo -e "[${RED} fail ${DEFAULT}]")
PASS=$(echo -e "[${GREEN} pass ${DEFAULT}]")

function test_repeat() {
    local test_name="test_repeat"

    local expected="0000"
    local got=$(repeat "0" "4")

    if [ ! "$expected" = "$got" ]; then
        echo -e "$FAIL $test_name \nexpected: $expected\n     got: $got" >&2
        return 1
    fi

    echo -e "$PASS $test_name" >&2
}

function test_parse_start() {
    local test_name="test_parse_start"

    local expected="739 999 1000 7420"
    local got=$(parse_start 739 7420)

    if [ ! "$expected" = "$got" ]; then
        echo -e "$FAIL $test_name \nexpected: $expected\n     got: $got" >&2
        return 1
    fi

    echo -e "$PASS $test_name" >&2
}

function test_create_break_point() {
    local test_name="test_create_break_point"

    local expected="09"
    local got=$(create_break_point 9)

    if [ ! "$expected" = "$got" ]; then
        echo -e "$FAIL $test_name \nexpected: $expected\n     got: $got" >&2
        return 1
    fi

    echo -e "$PASS $test_name" >&2
}

function test_parse_end() {
    local test_name="test_parse_end"

    local expected="739 739 740 799 800 999"
    local got=$(parse_end 739 999)

    if [ ! "$expected" = "$got" ]; then
        echo -e "$FAIL $test_name \nexpected: $expected\n     got: $got" >&2
        return 1
    fi

    echo -e "$PASS $test_name" >&2
}

function test_parse_into_regex() {
    local test_name="test_parse_into_regex"

    local expected="739 7[4-9][0-9] [89][0-9]{2} [1-6][0-9]{3} 7[0-3][0-9]{2} 74[01][0-9] 7420"
    local got=$(parse_into_regex "739 739 740 799 800 999 1000 6999 7000 7399 7400 7419 7420 7420")

    if [ ! "$expected" = "$got" ]; then
        echo -e "$FAIL $test_name \nexpected: $expected\n     got: $got" >&2
        return 1
    fi

    echo -e "$PASS $test_name" >&2
}

function test_parse_into_pattern() {
    local test_name="test_parse_into_pattern"

    local expected="(739|7[4-9][0-9]|[89][0-9]{2}|[1-6][0-9]{3}|7[0-3][0-9]{2}|74[01][0-9]|7420)"
    local got=$(parse_into_pattern "739 7[4-9][0-9] [89][0-9]{2} [1-6][0-9]{3} 7[0-3][0-9]{2} 74[01][0-9] 7420")

    if [ ! "$expected" = "$got" ]; then
        echo -e "$FAIL $test_name \nexpected: $expected\n     got: $got" >&2
        return 1
    fi

    echo -e "$PASS $test_name" >&2
}

function test_combine() {
    local test_name="test_combine"

    local expected="(739|7[4-9][0-9]|[89][0-9]{2}|[1-6][0-9]{3}|7[0-3][0-9]{2}|74[01][0-9]|7420)"
    local got=$(combine "739" "7420")

    if [ ! "$expected" = "$got" ]; then
        echo -e "$FAIL $test_name \nexpected: $expected\n     got: $got" >&2
        return 1
    fi

    echo -e "$PASS $test_name" >&2
}

case "$1" in
    test_repeat)
        test_repeat;;
    test_parse_start)
        test_parse_start;;
    test_create_break_point)
        test_create_break_point;;
    test_parse_end)
        test_parse_end;;
    test_parse_into_regex)
        test_parse_into_regex;;
    test_parse_into_pattern)
        test_parse_into_pattern;;
    test_combine)
        test_combine;;
    *)
        test_repeat
        test_parse_start
        test_create_break_point
        test_parse_end
        test_parse_into_regex
        test_parse_into_pattern
        test_combine
esac
