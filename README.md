# TQL: the Terse Query Language
#Please note: TQL has been superseded by Miniquery. Code and features are being ported there as a permanent measure.
TQL is a software library that makes working with relational databases *massively*
easier than writing and running conventional SQL. If you run *lots* of queries
and you don't want to sweat the SQL, then TQL is the query language for you.
TQL is more concise *and* less fussy about query semantics you shouldn't *have to*
think about in the first place! Just write what make sense and let your machine
puzzle it out. (And never sweat the HAVING clause again!) And if you'd love to
ditch your GUI-based DB client in favor of a more integrated workspace, TQL is
for you!

TQL's natural home is at your \*NIX command prompt but it can be embedded anywhere a
command can be typed and run.

TQL is an ambitious project to find the shortcomings of DML SQL (that is,
`SELECT`, `INSERT`, `UPDATE` and `DELETE` statements) and wherever feasible, to
reduce them to more concise, easy-to-use alternatives.  This means less typing
and less thinking for you. Since TQL is TUI-based, you also get a more
integrated workspace: you can do more from the command line and you need that
separate GUI-based database tool less and less.

By default, TQL inflates your queries into valid SQL and runs them against
your RDBMS engine in
a single step. (You can disable automatic execution as described below.) TQL
was originally designed for systems running MySQL; compatibility with other
dialects of SQL is steadily improving and contributions are welcome.

# Using TQL
Perhaps the best way to become fluent with TQL is to watch it unfold through
well-chosen examples. We'll walk you through a detailed presentation
of all the things TQL can do for you, starting with the simplest of them all.
Think of it as a guided tour of TQL's own evolution over time from its very
humble beginnings.

_*The guided tour: Coming soon*_

### Auto-execution mode
To run TQL with query execution turned on (the default behavior), you need the
following:
1. a TUI program capable of submitting SQL queries to your RDBMS. For MySQL
users, this typically means the "mysql" binary bundled with MySQL.
2. a small wrapper script or shell function for item #1 that either knows
or figures out the database connection parameters (user name, password, host,
and database name) so that TQL doesn't have to.
3. two environment variables: `TQL_DB_WRAPPER` to identify your wrapper
script and `TQL_DBNAME` to identify your database.

*Example*: Your wrapper script might look like the following:

    exec /bin/mysql --user=BOB --password=BOBPASS --host=127.0.0.1 "$TQL_DBNAME" "$@"

Corresponding to this script, you would add the following to your shell configs:

    export TQL_DB_WRAPPER=/home/bob/scripts/runTql.sh   (or whatever your script's name)

### Query-only mode
To disable automatic execution of queries, producing only the fully-inflated SQL query
on your standard output, add the '-q' option (long form: '--query') to your
TQL command invocations. Steps (1)-(3) above should not be necessary.

<<<<<<< HEAD
=======
# Plenty of work to be done!
The greatest thing about TQL is how ambitious it is! There is plenty of room
for growth in all directions: 
- expanding the range of query features the system can handle (_e.g._ column-name aliases)
- addressing the shortcomings of popular RDBMS binaries (such as MySQL's "mysql")
- streamlining the process of fitting TQL to the database(s) you work with regularly
- adding other dialects of SQL to the TQL-compatibility family
and of course,
- improving the documentation.
###### (and did I mention upgrading the system to a more suitable language?)

>>>>>>> 355af78c8fcf38123b99d07cdb2cc4d87dc6e907
