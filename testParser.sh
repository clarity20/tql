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
    i=0
    while [[ -n "${actualArr[i]}" || -n "${expectedArr[i]}" ]]; do
        if [[ -z "${actualArr[i]}" ]]; then
            printf "%-*s <\n" $maxLength "${expectedArr[i]}"
            isFailed=$TRUE
        elif [[ -z "${expectedArr[i]}" ]]; then
            printf "  > %*s\n" $((maxLength+${#actualArr[i]})) "${actualArr[i]}"   # Parsed column on RHS
            isFailed=$TRUE
        else
            if [[ "${expectedArr[i]}" == "${actualArr[i]}" ]]; then
                comparison='  '
            # Allow some slackness when comparing NCV and function call terminators
            elif [[ ("${expectedArr[i]}" =~ ^${tt[END_NCV]}NCV)
                 && ("${actualArr[i]}" =~ ^${tt[END_NCV]}(N?C)?V) ]]; then
                comparison='  '
            elif [[ ("${expectedArr[i]}" =~ ^${tt[END_FUNCTION]}[0-9]+${tt[FUNCTION_ARITY]}$)
                 && ("${actualArr[i]}" =~ ^${tt[END_FUNCTION]}[0-9]+${tt[FUNCTION_ARITY]}[0-9]+$) ]]; then
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
        returnValue=$FALSE
    else
        echo "*** FAILED ***"
        returnValue=$TRUE
    fi

    echo
    return $returnValue
}


###################################################################
# testSubclause  <inputString>  <expected types and tokens ...>
#
# Verifies that an input string comprised of any number of NCVs
# is parsed into the expected sequence of type-and-token pairs.
# You should omit the extra bookkeeping information (nesting levels, function
# arities and NCV counts) from your sequence of expected types and tokens
# since this routine figures them out for you. Just list the types and tokens.
# See testSingle() for a simpler version that applies to single-NCV inputs
###################################################################
function testSubclause()
{
    local inputStr=$1
    local NCVcount=0 parenLevel=0
    shift

    # Construct the string against which to compare our results
    # The caller must use curly braces to represent NCV delimiters
    local expectedResult="" tokenCount="" doBeginNCV=$FALSE
    while [[ -n $1 ]]; do
        typeIndicator=""
        token=""

        case $1 in
            '[') typeIndicator=$1
                 token=$((++parenLevel))
                 shift
                 ;;
            ']') typeIndicator=$1
                 token=$((parenLevel--))${tt[FUNCTION_ARITY]}
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
                 token=${tt[BEGIN_NCV]}$NCVcount
                 doBeginNCV=$TRUE
                 shift
                 ;;
            '}') token=${tt[END_NCV]}NCV$NCVcount    # Do not try to figure out NCV/CV/V
                 tokenCount=""
                 shift
                 ;;
              ,) typeIndicator=$1
                 token=$parenLevel
                 shift
                 ;;
 [-+*/%^\&\|]|'<<'|'>>') typeIndicator=${tt[OPERATOR]}
                 token=$1
                 shift
                 ;;
      '&&'|'||') typeIndicator=${tt[BOOLEAN]}
                 token=${1:1}
                 shift
                 ;;
              *) typeIndicator=$1
                 shift
                 if [[ $typeIndicator != ${tt[SPACE]} ]]; then
                     token=$1
                     shift
                 fi
                 ;;
        esac

        expectedResult+=$tokenDelimiter$tokenCount$typeIndicator$token

        # Update the token count for the next token (if there is one)
        if [[ $doBeginNCV == $TRUE ]]; then
            tokenCount=0
            doBeginNCV=$FALSE
        elif [[ -n $tokenCount ]]; then
            ((tokenCount++))
        fi
    done

    # Exercise the code being tested
    parseQueryClause "$inputStr" $TRUE
    actualResult=$g_returnString

    # compare against the expected result
    showComparison "$expectedResult" "$actualResult"
    return $?
}


###################################################################
# testSingle  <inputString>  [<expectedType> <expectedToken> [...]]
#
# Verifies that a single-NCV input string is parsed
# into the expected sequence of tokens having the expected types.
# See the testSubclause() comment header for further information.
###################################################################
function testSingle()
{
    local inputStr=$1 parenLevel=0
    declare -ir NCVcount=1
    shift

    # Construct the string against which to compare our results
    # Curly braces are not used because we assume there is just one NCV
    local expectedResult="" tokenCount=0
    while [[ -n $1 ]]; do
        token=""
        typeIndicator=""

        case $1 in
            '[') typeIndicator=$1
                 token=$((++parenLevel))
                 shift
                 ;;
            ']') typeIndicator=$1
                 token=$((parenLevel--))${tt[FUNCTION_ARITY]}
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
              ,) typeIndicator=$1
                 token=$parenLevel
                 shift
                 ;;
 [-+*/%^\&\|]|'<<'|'>>') typeIndicator=${tt[OPERATOR]}
                 token=$1
                 shift
                 ;;
      '&&'|'||') typeIndicator=${tt[BOOLEAN]}
                 token=${1:1}
                 shift
                 ;;
              *) typeIndicator=$1
                 shift
                 if [[ $typeIndicator != ${tt[SPACE]} ]]; then
                     token=$1
                     shift
                 fi
                 ;;
        esac

        expectedResult+=$tokenDelimiter$tokenCount$typeIndicator$token

        ((tokenCount++))
    done

    # Exercise the code being tested
    parseQueryClause "$inputStr" $TRUE

    [[ $g_returnString =~ ^${tokenDelimiter}${tt[BEGIN_NCV]}$NCVcount(.*)$tokenDelimiter${tt[END_NCV]}(N?C)?V$NCVcount ]]
    actualResult=${BASH_REMATCH[1]}

    # Compare against the expected result
    showComparison "$expectedResult" "$actualResult"
    return $?
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

# Parser should only accept one or two arguments
if parseQueryClause lots of args >/dev/null; then
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
arg="w+rd";     testSingle "$arg" W "w" "+" W "rd"    # operators recognized when unescaped
arg="w + rd";   testSingle "$arg" W "w" S "+" S W "rd"    # spaces have no effect except to delimit
arg="w'+^'r'%+'d"; testSingle "$arg" V 'w+^r%+d'    # quotes turn special characters into literals and can appear multiple times

#####################
# Boolean logic and parenthetical grouping for multiple-NCV arguments
#####################
arg="this || that"    # Two simple words
testSubclause "$arg" { W this } S '||' S { W that }

arg="First Street East || 123 Second Ave"   # Two kinds of compound string values
testSubclause "$arg" { V "First Street East" } S '||' S { V "123 Second Ave" }

# Grouping parentheses
arg="(12&&3)||((4&&999)||200)"
testSubclause "$arg" "(" { N 12 } '&&' { N 3 } ")" '||' "(" "(" { N 4 } '&&' { N 999 } ")" '||' { N 200 } ")"
# Play well with NCV delimiters in complex situations
arg='(a+b)'; testSingle "$arg" "(" W a '+' W b ")"
arg='(((a+b)))'; testSingle "$arg" "(" "(" "(" W a '+' W b ")" ")" ")"
arg='(((a+b)+c)+d)+e'; testSingle "$arg" "(" "(" "(" W a '+' W b ")" '+' W c ")" '+' W d ")" '+' W e
arg='a*(b+c)'; testSingle "$arg" W a '*' "(" W b '+' W c ")"
arg='(a+b)*c'; testSingle "$arg" "(" W a '+' W b ")" '*' W c

arg='(a+b)&&(c+d)'; testSubclause "$arg" "(" W a '+' W b ")" '&&' "(" W c '+' W d ")"

#####################
# Function calls
#####################
# 0/1/multiple parameters
arg="func()";  testSingle $arg F func [ ]
arg="func(val)"; testSingle $arg F func [ W val ]
arg="func(val,123,99)"; testSingle $arg F func [ W val , N 123 , N 99 ]
# Chained
arg="foo(88)-foo(baz)"; testSingle $arg F foo [ N 88 ] - F foo [ W baz ]
# Nested
arg="5+floor(sqrt(n))"; testSingle $arg N 5 "+" F floor [ F sqrt [ W n ] ]
arg="concat(hello, concat(concat(world, now), str))"
testSingle "$arg" F concat [ W hello , S F concat [ F concat [ W world , S W now ] , S W str ] ]

# TODO: Mix function calls and grouping parentheses
#arg="f(a*(b+c))"

arg="(12&&3)||((4&&999)||200)"
testSubclause "$arg" "(" { N 12 } '&&' { N 3 } ")" '||' "(" "(" { N 4 } '&&' { N 999 } ")" '||' { N 200 } ")"
arg='((a+b)&&(c-d))||(e/f)'
testSubclause "$arg" "(" "(" W a '+' W b ")" B '&' "(" W c - W d ")" ")" B '|' "(" W e '/' W f ")"

# Comparators
arg="a=b";      testSingle $arg ${tt[EXPANDABLE_WORD]} a ${tt[COMPARATOR]} "=" ${tt[EXPANDABLE_WORD]} b

# Comparators, multiple NCVs with token counting
arg="(a=2)&&(zeta=10)"; testSubclause "$arg" "(" { W a C "=" N 2 } ")" '&&' "(" { W zeta C "=" N "10" } ")"

# Preprocessor-phase NCV detection
input="(d=5)&&(<=7||(a&&b))"
expected="(${tokenDelimiter}\
${tt[BEGIN_NCV]}1d=5${tokenDelimiter}\
${tt[END_NCV]}1)&&(${tokenDelimiter}\
${tt[BEGIN_NCV]}2<=7${tokenDelimiter}\
${tt[END_CV]}2||(${tokenDelimiter}\
${tt[BEGIN_NCV]}3a${tokenDelimiter}\
${tt[END_V]}3&&${tokenDelimiter}\
${tt[BEGIN_NCV]}4b${tokenDelimiter}\
${tt[END_V]}4))"

delimitNCVsInString "$input"
if [[ "$g_returnString" != "$expected" ]]; then
    echo Error in NCV detection.
    exit 1
fi

# Percent sign as glob and as modulus
arg="street=123%St"
testSingle "$arg" ${tt[EXPANDABLE_WORD]} street ${tt[COMPARATOR]} "=" ${tt[STRING_CONSTANT]} "123%St"
arg="123%st=2"
testSingle "$arg" ${tt[INTEGER]} 123 ${tt[OPERATOR]} "%" ${tt[EXPANDABLE_WORD]} st

# TODO Add a percent-initial regex test

# Different types of numeric and date values
arg="123";     testSingle $arg ${tt[INTEGER]} 123    # integer
arg="123.45";     testSingle $arg ${tt[DECIMAL]} 123.45    # decimal

##############
##############
##############
fi  # if ((0/1)) guard
##############
##############
##############

arg="100-x"
testSingle $arg ${tt[DECIMAL]} 100 ${tt[OPERATOR]} "-" ${tt[EXPANDABLE_WORD]} x

exit $?

# Different types of lists: regex, alnum, numeric


# Old stuff. Integrate it whenever ready.

#input="(test=9 && best(1,2)) || zest<10"
#: ${input:="test=9*ans && best(1,2)+*guess"}
#input="test=9 && best(1,worst(2,3))"
#: ${input:="best(1,worst(2,3,4*bad(6)),good())"}

