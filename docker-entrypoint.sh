#!/usr/bin/env bash

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

_main() {
    chown -R postgres:postgres ${PGDATAOLD}
    chown -R postgres:postgres ${PGDATANEW}
    chmod -R 0700 ${PGDATAOLD}
    chmod -R 0700 ${PGDATANEW}
}

if ! _is_sourced; then
	_main "$@"
fi
