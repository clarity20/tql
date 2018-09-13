#!/usr/bin/env bash

: ${TQL_HOME:=$HOME/tql}
source $TQL_HOME/db_functions
source $TQL_HOME/parse_functions

# Populate the master column list
TQL_SCHEMA_CACHE=$TQL_HOME/testTableData.dat
loadTableDescription $TQL_SCHEMA_CACHE
#echo "$g_masterColumnList"

_preselects=fa
expandSelections $_preselects
echo "$_preselects" expanded to "$g_returnString"

_preselects=fa,fr
expandSelections $_preselects
echo "$_preselects" expanded to "$g_returnString"

# Test ambiguous input that requires interactive selection.
# Comment this section if "expect" is not available.
#_preselects=fk
#expandSelections $_preselects
#echo "$_preselects" expanded to "$g_returnString"

_preselects=2*fr+ft/3
expandSelections $_preselects
echo "$_preselects" expanded to "$g_returnString"

_preselects=cTI
expandSelections $_preselects
echo "$_preselects" expanded to "$g_returnString"
