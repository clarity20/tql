#!/usr/bin/env bash

setInput() { in="$1"; echo in: "$in"; }

: ${TQL_HOME:=$HOME/tql}
TQL_TEST_DIR=$TQL_HOME/test
source $TQL_HOME/db_functions
source $TQL_HOME/parse_functions

# Populate the master column list
#loadColumnNameList $TQL_SCHEMA_CACHE/$TQL_DBNAME/table1.columns
#loadConfigForTable $TQL_CONFIG_DIR/${TQL_DBNAME}.cfg table1

loadColumnNameList $TQL_TEST_DIR/testTableData.dat
loadTableNameList $TQL_TEST_DIR/testTableList.dat
loadConfigForTable $TQL_CONFIG_DIR/${TQL_DBNAME}.cfg table1

#echo tables:
#echo "$g_masterTableList"
#echo columns:
#echo "$g_masterColumnList"

# The following commands rely on the other sample schema
#setInput "ft=-"; generateWhereClause "$in"; getReturnValue whereClause # AND foot IS NULL
#echo return code $?, where clause is $whereClause
#setInput "ft=?"; generateWhereClause "$in"; getReturnValue whereClause # AND foot = ?
#echo return code $?, where clause is $whereClause

#setInput "ft=2"; generateWhereClause "$in"    # WHERE (foot = 2)
#setInput "ft<>2"; generateWhereClause "$in" && getReturnValue whereClause  # AND ( NOT ( foot = 2 ) )
#useIntuitiveNulls "$whereClause"   # AND ( NOT ( foot = 2 ) OR foot IS NULL )
#setInput "ft=1,4,8"; generateWhereClause "$in"    # WHERE foot IN (1,4,8)
#setInput "ft=1000-7"; generateWhereClause "$in"    # WHERE foot BETWEEN 1000 AND 1007
#setInput "ft=100:0,3,6,7"; generateWhereClause "$in"    # WHERE foot IN (1000,1003,1006,1007)
# Grammar check - deliberate type mismatch:
#setInput "ft=10:03"; generateWhereClause "$in"    # Illegal grammar / no feasible interpretation for 'ft=10:03'.
setInput "acT=10:03"; generateWhereClause "$in"    # WHERE activationTime = '10:03:00'
#setInput "acT=10:03:46.7"; generateWhereClause "$in"    # WHERE foot = '10:03:46.7'
#setInput "ft=@test/testNumbers1.in@"; generateWhereClause "$in"    # WHERE foot IN (1000,2000,3000,4000,5000)
#setInput "ft=@@"; generateWhereClause "$in"    # WHERE foot IN (1000,2000,3000,4000,5000)
#setInput "acD=@@"; generateWhereClause "$in"    # WHERE actionDate IN ('2019-01-10','2019-02-1#5')
#setInput "acD=2009-6-20"; generateWhereClause "$in"    # WHERE actionDate = '2009-6-20'
#setInput "acD=2009/6/20"; generateWhereClause "$in"    # WHERE actionDate = '2009-6-20'
#setInput "acD=2009/6/20-2011/4/30"; generateWhereClause "$in"    # WHERE actionDate BETWEEN '2009-6-20' AND '2011-4-30'
#setInput "acD=2009/6/20-30"; generateWhereClause "$in"    # WHERE actionDate BETWEEN '2009-6-20' AND '2009-6-30'
#setInput "acD=2009/6/20-7/30"; generateWhereClause "$in"    # WHERE actionDate BETWEEN '2009-6-20' AND '2009-7-30'
#setInput "acD=2009/6-7"; generateWhereClause "$in"    # WHERE actionDate BETWEEN '2009-6-1' AND '2009-7-31'
doExit


type=${tt[TYPE_NCV]}
where="fo=cTI+mS"
generateWhereClause "$where"
#normalizePredicate "$type" "$ret"  # strip ncv markup first

_preselects=fa
expandSelections $_preselects; getReturnValue result
echo "$_preselects" expanded to "$result"

_preselects=fa,fr
expandSelections $_preselects; getReturnValue result
echo "$_preselects" expanded to "$result"

# Test ambiguous input that requires interactive selection.
# Comment this section if "expect" is not available.
#_preselects=fk
#expandSelections $_preselects; getReturnValue result
#echo "$_preselects" expanded to "$result"

_preselects=2*fr+ft/3
expandSelections $_preselects; getReturnValue result
echo "$_preselects" expanded to "$result"

_preselects=cTI
expandSelections $_preselects; getReturnValue result
echo "$_preselects" expanded to "$result"

