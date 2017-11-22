#!/usr/bin/env bash

######################################################################################
#
# Testing infrastructure and specific test cases for the clause-parsing functionality
#
######################################################################################

THIS_SCRIPT=`basename $0`
source parse_functions
tokenDelimiter=$'\n'


###################################################################
# showComparison  <expectedTokens>  <actualTokens>
#
# Pretty-prints a comparison between two token sequences
###################################################################
function showComparison()
{
    declare -a expectedArr actualArr 
    local maxLength=0 i=0 isFailed=$FALSE

    OLDFS=$IFS
    IFS="$tokenDelimiter" expectedArr=($1)
    IFS="$tokenDelimiter" actualArr=($2)
    IFS=$OLDFS

    # Track the length of the longest expected piece for display purposes
    for ((i=0; i<${#expectedArr}; i++)); do
        if ((maxLength < ${#expectedArr[i]})); then
            maxLength=${#expectedArr[i]}
        fi
    done

    # Display line-by-line, leaving enough room for the longest array element(s) and showing which lines differ
    # TODO: To really do justice to this comparison, mimic the longest-common-subsequence algorithm.
    printf "%-*s %s\n" $((maxLength+3)) "EXP'D" "RCV'D"
    i=1
    while [[ -n "${actualArr[i]}" || -n "${expectedArr[i]}" ]]; do
        if [[ -z "${actualArr[i]}" ]]; then
            printf "%-*s <" $maxLength "${expectedArr[i]}"
        elif [[ -z "${expectedArr[i]}" ]]; then
            printf "  > %*s\n" $((maxLength+${#actualArr[i]})) "${actualArr[i]}"   # Parsed column on RHS
        else
            if [[ "${expectedArr[i]}" == "${actualArr[i]}" ]]; then
                comparison='  '
            # Allow some slackness when comparing the NCV terminators
            elif [[ ("${expectedArr[i]}" =~ ^/NCV) && ("${actualArr[i]}" =~ ^/(N?C)?V) ]]; then
                comparison='  '
            else
                comparison='<>'
                isFailed=$TRUE
            fi
            printf "%-*s %2.2s %s\n" $maxLength "${expectedArr[i]}" "$comparison" "${actualArr[i]}"
        fi
        ((i++))
    done

    unset actualArr expectedArr
    echo

    if ((isFailed == FALSE)); then
        echo passed.
    else
        echo "*** FAILED ***"
    fi

    echo
}


###################################################################
# testSubclause  <inputString>  <expected sequence> [...]
#
# Verifies that an input string (comprising any number of NCVs)
# is parsed into the expected sequence of tokens. See testSingle()
# for a simplified version that applies to single-NCV inputs
###################################################################
function testSubclause()
{
    local inputStr=$1
    local NCVcount=0 parenLevel=0 funcLevel=0
    shift

    # Construct the string against which to compare our results
    # The caller must use curly braces to represent NCV delimiters
    local expectedResult=""
    while [[ -n $1 ]]; do
        typeIndicator=""
        token=""

        case $1 in
            '[') typeIndicator=$1
                 token=$((++funcLevel))
                 shift
                 ;;
            ']') typeIndicator=$1
                 token=$((funcLevel--))
                 shift
                 ;;
            '(') typeIndicator=$1
                 token=$((++parenLevel))
                 shift
                 ;;
            ')') typeIndicator=$1
                 token=$((parenLevel--))
                 shift
                 ;;
            '{') ((NCVcount++))
                 token=NCV$NCVcount
                 shift
                 ;;
            '}') token='/'NCV$NCVcount    # Do not try to figure out NCV/CV/V
                 shift
                 ;;
              *) typeIndicator=$1
                 shift
                 if [[ $typeIndicator != "S" ]]; then
                     token=$1
                     shift
                 fi
                 ;;
        esac

        expectedResult+=$tokenDelimiter$typeIndicator$token
    done

    # Exercise the code being tested
    parseWhereArgument "$inputStr"
    actualResult=$g_returnString

    # compare against the expected result
    showComparison "$expectedResult" "$actualResult"
}


###################################################################
# testSingle  <inputString>  [<expectedType> <expectedToken> [...]]
#
# Verifies that a single-NCV input string is parsed
# into the expected sequence of tokens having the expected types
###################################################################
function testSingle()
{
    local inputStr=$1 parenLevel=0 funcLevel=0
    shift
    
    # Construct the string against which to compare our results
    # Curly braces are not used because we assume there is just one NCV
    expectedResult=""
    while [[ -n $1 ]]; do
        token=""
        typeIndicator=$1
        shift

        case $1 in
            '[') token=$((++funcLevel))
                 ;;
            ']') token=$((funcLevel--))
                 ;;
            '(') token=$((++parenLevel))
                 ;;
            ')') token=$((parenLevel--))
                 ;;
              *) if [[ $typeIndicator != "S" ]]; then
                     token=$1
                     shift
                 fi
                 ;;
        esac

        expectedResult+=$tokenDelimiter$typeIndicator$token
    done

    # Exercise the code being tested
    parseWhereArgument "$inputStr"

    [[ $g_returnString =~ ^${tokenDelimiter}"NCV1"(.*)$tokenDelimiter/(N?C)?V1 ]]
    actualResult=${BASH_REMATCH[1]}

    # Compare against the expected result
    showComparison "$expectedResult" "$actualResult"
}


############################################################
# trace  [-]  <command(s) ...>
# Turns on shell tracing for a single command.
# Use the "-" option to invert (i.e. turn off then back on.)
# Intended as a debugging aid, not for permanent use in scripts.
############################################################
function trace()
{
    if [[ "$1" == "-" ]]; then
        invert=$TRUE
        shift
    fi

    local v t

    # Strong quote the command name and each of the arguments 
    for ((i=1; i<=$#; i++));
    do
        eval t=\${$i}
        # Use a transformation that will preserve single quotes embedded in the argument
        v[i]="'"${t//\'/\'\"\'\"\'}"'"
    done
    
    # Toggle shell tracing for the duration of the command
    if ((invert)); then set +xv; else set -xv; fi
    eval "${v[@]:1}"
    if ((invert)); then set -xv; else set +xv; fi
}


################################################
#
# TEST CASES
#
################################################

##############
##############
##############
if ((0)); then
##############
##############
##############

# Parser should only accept one argument
if parseWhereArgument multiple args >/dev/null; then
    echo FAIL: Multiple args accepted.
else
    echo pass: Multiple args rejected.
fi
echo

####################
# Word-versus-value distinction and protected character/string literals in simple cases.
####################
arg="word";     testSingle $arg W $arg    # lowercase --> word
arg="Word";     testSingle $arg V $arg    # capital --> value
arg="wo4rd";    testSingle $arg W $arg    # internal digits --> word
arg="1word";    testSingle $arg V $arg    # leading digits --> value
arg="'w'o'r'd"; testSingle $arg V ${arg//\'/}    # protected characters --> value without protective marks
arg="w\\o\\rd"; testSingle "$arg" V "wo"$'\r'"d"    # escaped characters --> converted if special, else protected
arg="w\\+\\rd"; testSingle "$arg" V "w+"$'\r'"d"    # escaped characters --> converted if special, else protected
arg="w+rd";     testSingle "$arg" W "w" O "+" W "rd"    # operators recognized when unescaped
arg="w + rd";   testSingle "$arg" W "w" S O "+" S W "rd"    # spaces have no effect except to delimit
arg="w'+^'r'%+'d"; testSingle "$arg" V 'w+^r%+d'    # quotes turn special characters into literals and can appear multiple times

#####################
# Boolean logic and grouping for multiple-NCV arguments
#####################
arg="this && that"    # Two simple words
testSubclause "$arg" { W this } S B '&' S { W that }

arg="First Street East || 123 Second Ave"   # Two kinds of compound values
testSubclause "$arg" { V "First Street East" } S B '|' S { V "123 Second Ave" }

##############
##############
##############
fi  # if ((0/1)) guard
##############
##############
##############

# Grouping parentheses
arg="(12&&3)||((4&&999)||200)"
testSubclause "$arg" "(" { N 12 } B '&' { N 3 } ")" B '|' "(" "(" { N 4 } B '&' { N 999 } ")" B '|' { N 200 } ")"

exit 10

# TODO: Detect unbalanced parens.

# Function calls. 0/1/multiple parameters. Singular, chained, nested.
arg="func()";  testSingle $arg F func "(" ")"
#arg="func(val)"
#arg="func(val,123,99)"
#arg="func(88)-func(baz)"
#arg="5+floor(sqrt(n))"
#arg="concat(hello, concat(concat(world, now), s))"

exit 10

# TODO:

# Comparators; need to test CV- and NCV-type NCVs.

# Different types of numeric and date values
arg="123";     testSingle $arg N $arg    # integer
arg="123.45";     testSingle $arg D $arg    # decimal

# Different types of lists: regex, alnum, numeric


# TODO:
# percent-initial regexes, both simple and compound



# Old stuff. Integrate it whenever ready.

#: ${input:='(10||<>20)&&30'}
#input="foo=bar&&biz||=baz"
#input="(test=9 && best(1,2)) || zest<10"
#: ${input:="test=9*ans && best(1,2)+*guess"}
#input="test=9 && best(1,worst(2,3))"
#: ${input:="best(1,worst(2,3,4*bad(6)),good())"}

