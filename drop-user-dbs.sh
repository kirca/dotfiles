#!/usr/bin/env bash
# Drop all PostgreSQL databases owned by a given role.
#
# Usage: drop-user-dbs.sh [-y] [-n] <owner>
#   -y  don't ask for confirmation
#   -n  dry run: only list the databases that would be dropped
#
# Connection settings come from the usual libpq env vars (PGHOST, PGPORT,
# PGUSER, PGPASSWORD). E.g. run as the postgres superuser:
#   sudo -u postgres ./drop-user-dbs.sh myuser

set -euo pipefail

usage() {
    echo "Usage: $0 [-y] [-n] <owner>" >&2
    exit 1
}

assume_yes=0
dry_run=0
while getopts "yn" opt; do
    case $opt in
        y) assume_yes=1 ;;
        n) dry_run=1 ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))
[ $# -eq 1 ] || usage
owner=$1

psql_cmd=(psql -X -q -v ON_ERROR_STOP=1 -d postgres)

# Pass the owner as a psql variable (via stdin, so it gets interpolated and
# properly quoted) instead of splicing it into the SQL string.
mapfile -t dbs < <("${psql_cmd[@]}" -At -v owner="$owner" <<'SQL'
SELECT d.datname
FROM pg_database d
JOIN pg_roles r ON r.oid = d.datdba
WHERE r.rolname = :'owner'
  AND NOT d.datistemplate
ORDER BY d.datname;
SQL
)

if [ ${#dbs[@]} -eq 0 ]; then
    echo "No databases owned by '$owner'."
    exit 0
fi

echo "Databases owned by '$owner':"
printf '  %s\n' "${dbs[@]}"

if [ $dry_run -eq 1 ]; then
    exit 0
fi

if [ $assume_yes -eq 0 ]; then
    read -r -p "Drop these ${#dbs[@]} database(s)? [y/N] " answer
    [[ $answer =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

for db in "${dbs[@]}"; do
    echo "Dropping $db"
    # WITH (FORCE) terminates open connections (PostgreSQL 13+).
    "${psql_cmd[@]}" -v db="$db" <<'SQL'
DROP DATABASE :"db" WITH (FORCE);
SQL
done
