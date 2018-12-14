#!/usr/bin/env bash

: ${TQL_HOME:=$HOME/tql}
source $TQL_HOME/db_functions
source $TQL_HOME/parse_functions

# Populate the master column list
TQL_SCHEMA_CACHE=$TQL_HOME/testTableData.dat
loadTableDescription $TQL_SCHEMA_CACHE
#echo "$g_masterColumnList"

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

