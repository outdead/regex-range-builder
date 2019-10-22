#!/usr/bin/env bash

function repeat() {
    local str="$1"
    local n="$2"
    if [ -z "${n}" ]; then
       echo "arg n is not set" >&2
       return 1
    fi

    for (( x=0; x < $n; x++ )) do
        printf "${str}"
    done
}

function parse_start() {
    local from=$1
    if [ -z "${from}" ]; then
       echo "arg from is not set" >&2
       return 1
    fi

    local to=$2
    if [ -z "${to}" ]; then
       echo "arg to is not set" >&2;
       return 1
    fi

    if (( "${from}" > "${to}")); then
       echo "arg from can not be greater than arg to" >&2
       return 1
    fi

    if [ "${#from}" -eq "${#to}" ]; then
        local result=(${from} ${to})

        echo "${result[@]}"; return
    fi

    local break_point=$((10**${#from}))

    local injection=$(parse_start "${break_point}" "${to}")

    let break_point--

    local result=(${from} ${break_point} ${injection})

    echo "${result[@]}"
}

function create_break_point() {
    local point=$1
    if [ -z "${point}" ]; then
       echo "arg point is not set" >&2
       return 1
    fi

    declare -i r; let r="${point} + 1"; let r="${#r}"

    local len="${#point}"
    if (( ${len} < ${r} )); then
        let len="$r - $len"
        for (( x=0; x < $len; x++ )) do
            printf "0"
        done
    fi

    echo "${point}"
};

function parse_end() {
    local from=$1
    if [ -z "${from}" ]; then
       echo "arg from is not set" >&2
       return 1
    fi

    local to=$2
    if [ -z "${to}" ]; then
       echo "arg to is not set" >&2
       return 1
    fi

    if (( "${from}" > "${to}")); then
       echo "arg from can not be greater than arg to" >&2
       return 1
    fi

    declare -i len_from; let len_from="${#from}"
    declare -i len_to; let len_to="${#to}"

    if [ ${len_from} -eq 1 ]; then
        local result=(${from} ${to})

        echo ${result[@]}; return
    fi

    local join_from=$(repeat "0" ${len_from})
    if [ "${join_from}" -eq "0${from:1}" ]; then
        local join_to=$(repeat "0" ${len_to})
        if [ "${join_to}" -eq "9${to:1}" ]; then
            local result=(${from} ${to})

            echo ${result[@]}; return
        fi

        if (( "${from:0:1}" < "${to:0:1}" )); then
            local join_to=$(repeat "0" ${len_to}-1)
            declare -i e; let e="${to:0:1}${join_to} - 1"

            local break_point1=$(create_break_point $(($e + 1)))
            local injection=$(parse_end "${break_point1}" "${to}")
            if [ $? -eq 1 ]; then
                return 1
            fi

            local break_point2=$(create_break_point ${e})
            local result=(${from} ${break_point2} ${injection})

            echo ${result[@]}; return
        fi
    fi

    local join_to=$(repeat "9" ${len_to})
    if [ "${join_to}" -eq "9${to:1}" ] && (( "${from:0:1}" < "${to:0:1}" )); then
        let i="${from:0:1} + 1"

        local cut_to="${to:1}"
        local join_to=$(repeat "0" ${#cut_to})
        declare -i e; let e="$i${join_to} - 1"

        local break_point1=$(create_break_point ${e})
        local injection=$(parse_end "${from}" "${break_point1}")
        if [ $? -eq 1 ]; then
            return 1
        fi

        local break_point2=$(create_break_point $(($e + 1)))
        local result=(${injection} ${break_point2} ${to})

        echo ${result[@]}; return
    fi

    if (( "${from:0:1}" < "${to:0:1}" )); then
        let i="${from:0:1} + 1"

        local cut_to="${to:1}"
        local join_to=$(repeat "0" ${#cut_to})
        declare -i e;  let e="$i${join_to} - 1"

        local break_point1=$(create_break_point $e)
        local injection1=$(parse_end "${from}" "${break_point1}")
        if [ $? -eq 1 ]; then
            return 1
        fi

        local break_point2=$(create_break_point $(($e + 1)))
        local injection2=$(parse_end "${break_point2}" "${to}")
        if [ $? -eq 1 ]; then
            return 1
        fi
        local result=(${injection1} ${injection2})

        echo ${result[@]}; return
    fi

    local o=$(parse_end "${from:1}" "${to:1}")
    if [ $? -eq 1 ]; then
        return 1
    fi

    local first_from="${from:0:1}"
    result=()
    IFS=$' ';
    for item in ${o}
    do
        result+=("$first_from$item")
    done

    echo "${result[@]}"
};

function parse_into_regex() {
    local range=$1
    if [ -z "${range}" ]; then
       echo "arg range is not set"
       return 1
    fi

    local result=()

    local i=0
    local prev
    IFS=$' ';
    for item in ${range}
    do
        let i++
        if [ $i -eq 1 ]; then
            prev=${item};
            continue
        fi
        let i=0

        local s=""
        local repeat=0
        local reg=""

        len=${#prev}
        for ((a=0; a<len; a++)); do
            local from=${prev:$a:1};
            local to=${item:$a:1};

            if [ "${from}" -eq "${to}" ]; then
                reg+="${from}"
            else
                declare -i from_p; let from_p="${from} + 1"
                if [ ${from_p} -eq "${to}" ]; then
                    reg+="[${from}${to}]"
                else
                    local from_to="${from}${to}"
                    if [ "${s}" = "${from_to}" ]; then
                        let repeat++
                    fi

                    s="${from_to}";
                    declare -i prev_m; let prev_m="${#prev} - 1"

                    if [ $a -eq ${prev_m} ]; then
                        if [ "${repeat}" -gt 0 ]; then
                            local repeat_p=$(( ${repeat} + 1 ))
                            reg+="{${repeat_p}}"
                        else
                            reg+="[${from}-${to}]"
                        fi
                    else
                        if [ "${repeat}" -eq 0 ]; then
                            reg+="[${from}-${to}]"
                        fi
                    fi
                fi
            fi
        done

        result+=(${reg})
    done

    echo "${result[@]}"
};

function parse_into_pattern() {
    local reg=$1
    if [ -z "${reg}" ]; then
       echo "arg reg is not set"
       return 1
    fi

    local line=$2
    if [ -z "${line}" ]; then
        line=0
    fi

    local zeroes=$3
    if [ -z "${zeroes}" ]; then
        zeroes=0
    fi

    local word=$4
    if [ -z "${word}" ]; then
        word=0
    fi

    reg=${reg// /|}
    if [ "${line}" -eq 1 ] && [ "${zeroes}" -eq 1 ]; then
        echo "^0*(${reg})$"
    else
        if [ "${zeroes}" -eq 1 ]; then
            echo "0*(${reg})"
        else
            if [ "${line}" -eq 1 ]; then
                echo "^(${reg})$"
            else
                if [ "${word}" -eq 1 ]; then
                    echo "\\b(${reg})\\b"
                else
                    echo "(${reg})"
                fi
            fi
        fi
    fi
};

function combine() {
    local from=$1
    local to=$2
    local re='^[0-9]+$'

    if [ -z "${from}" ]; then
       echo "arg from is not set" >&2
       return 1
    fi

    if ! [[ $from =~ $re ]] ; then
       echo "arg from is not a number" >&2;
       return 1
    fi

    if [ -z "${to}" ]; then
       echo "arg to is not set" >&2
       return 1
    fi

    if ! [[ $to =~ $re ]] ; then
       echo "arg to is not a number" >&2;
       return 1
    fi

    if (( "${from}" > "${to}")); then
       echo "arg from can not be greater than arg to" >&2
       return 1
    fi

    local start_range=$(parse_start "${from}" "${to}")
    local end_range=""

    local i=0
    local prev
    IFS=$' ';
    for item in ${start_range}
    do
        let i++
        if [ $i -eq 1 ]; then
            prev=${item}
            continue
        fi
        let i=0

        local middle_range=$(parse_end "${prev}" "${item}")
        if [ "${#end_range}" -ne 0 ]; then
            end_range="$end_range "
        fi
        end_range+="${middle_range}"
    done

    local range=$(parse_into_regex "${end_range}")
    parse_into_pattern "${range}" $3 $4 $5
}

if [ ! -z $1 ] && [ ! -z $2 ]; then
    combine $1 $2 $3 $4 $5
fi
