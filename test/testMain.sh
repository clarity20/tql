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
setInput "ft=1,4,8"; generateWhereClause "$in"    # WHERE foot IN (1,4,8)
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

