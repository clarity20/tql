# TQL
Terse Query Language

# Using TQL
By default, TQL inflates and executes DML queries against your RDBMS engine in
a single step. TQL was originally designed specifically for MySQL databases.
Compatibility with other DB systems is limited but improvements along this line
are welcome.

## Auto-execution mode
To automatically run submitted queries, you must provide TQL with the following:
1. a TUI program capable of submitting SQL queries to your RDBMS. For MySQL
users, the "mysql" binary bundled with MySQL is fine.
2. a small wrapper script or shell function for the binary that either knows
or figures out the database connection parameters (user name, password, host,
and database name) so that TQL doesn't have to.
3. an environment variable, TQL_DB_WRAPPER that identifies your wrapper script

Here is a simple example of a wrapper script called `/home/bob/scripts/runTql.sh`:
    ```sh
    exec /bin/mysql --user=BOB --password=BOBPASS --host=127.0.0.1 "$@"
    ```
Corresponding to this script, you would add the following to your shell configs:
`export TQL_DB_WRAPPER=/home/bob/scripts/runTql.sh`.

## Query-only mode
To disable automatic execution of queries, producing only the inflated query
on your standard output, add the '-q' option (long form: '--query') to your command
invocations.

