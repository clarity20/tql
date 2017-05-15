# TQL: the Terse Query Language
TQL is a software library that makes working with SQL-based RDBMS *massively*
faster and easier.  If you write and execute *tons* of queries in your daily
work and you'd love a *competitive* text-based alternative to popular GUI-based
DB clients, TQL is for you. If you'd love an alternative to SQL that's far more
concise *and* less fussy about the gory syntactical details you don't want to
*have* to think about, TQL is for you! If you'd love to shut down that
GUI-based DB client *for good* in favor of a more integrated workspace, TQL is
for you!

TQL's natural home is at your command prompt but it can be embedded anywhere a
command can be typed and run.

TQL is an ambitious project to find the shortcomings of DML SQL (that is,
`SELECT`, `INSERT`, `UPDATE` and `DELETE` statements) and wherever feasible, to
reduce them to more concise, easy-to-use alternatives.  This means less typing
and less thinking for you. Since TQL is TUI-based, you also get a more
integrated workspace as you start to need that separate GUI-based tool less and
less.

By default, TQL inflates and executes DML queries against your RDBMS engine in
a single step. (You can disable automatic execution as described below.) TQL
was originally designed for MySQL databases; compatibility with other DB
systems is steadily improving and contributions are welcome.

# Using TQL
Perhaps the best way to become familiar with TQL is to watch it unfold through
a well-structured demonstration. We'll walk you through a detailed presentation
of all the things TQL can do for you, starting with the simplest of them all.
Think of it as a guided tour of TQL's own evolution over time from its very
humble beginnings.

_*The guided tour: Coming soon*_

### Auto-execution mode
To run TQL with query execution turned on (the default), you must set up the
following three (3) items. A quick example follows:
1. a TUI program capable of submitting SQL queries to your RDBMS. For MySQL
users, this typically means the "mysql" binary bundled with MySQL.
2. a small wrapper script or shell function for the binary that either knows
or figures out the database connection parameters (user name, password, host,
and database name) so that TQL doesn't have to.
3. two environment variables: `TQL_DB_WRAPPER` to identify your wrapper
script and another, `TQL_DBNAME` to identify your database.

*Example*: Your wrapper script might look like the following:

    exec /bin/mysql --user=BOB --password=BOBPASS --host=127.0.0.1 "$TQL_DBNAME" "$@"

Corresponding to this script, you would add the following to your shell configs:

    export TQL_DB_WRAPPER=/home/bob/scripts/runTql.sh   (your script's name)

### Query-only mode
To disable automatic execution of queries, producing only the inflated query
on your standard output, add the '-q' option (long form: '--query') to your
command invocations.

# Contributions
The greatest thing about TQL is how ambitious it is! There is plenty of room
for growth in all directions: Expanding the main engine to handle more
subtleties and query types (for example, SELECT clauses containing aliases),
overcoming various challenges of working with the bare-naked binary provided
by your RDBMS package (such as the "mysql" that ships with MySQL), streamlining
the process of fitting TQL to the database(s) you work with regularly,
improving cross-compatibility with other major relational database systems, and
of course, improving the documentation.
###### (and did I mention rewriting the system in python?)

