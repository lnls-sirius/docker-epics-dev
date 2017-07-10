#!/bin/sh

. ./env-vars.sh

EPICS_TEMP_REPO="$(mktemp -d)/epics-dev"

git clone --depth=1 --branch="$EPICS_DEV_VERSION" https://github.com/lnls-sirius/epics-dev.git "$EPICS_TEMP_REPO"

sed -n "$EPICS_TEMP_REPO/bash.bashrc.local" -e '
1 {
    x
    s/.*/ENV /
    x
}

/^ *[^#]/ {
    H
    x
    s/\n//

    t reset_condition_flag
    : reset_condition_flag
    s/^ENV export /ENV /
    s/^export /    /
    t exported_var

    s/^ENV /&/
    t first_var

    s/^/    /

    : first_var
    : exported_var
    s/$/ \\/p
    s/.*//
    h
}' > "$EPICS_TEMP_REPO/expected-docker-env-vars.txt"

sed -i -e '/=[$](/d' "$EPICS_TEMP_REPO/expected-docker-env-vars.txt"
sed -i -e '$ s/ \\/$/' "$EPICS_TEMP_REPO/expected-docker-env-vars.txt"

cat > "$EPICS_TEMP_REPO/check-docker-env-vars.sed" << EOF
#/bin/sed -nf

/^[#] Environment variables from installed bash\\.bashrc\\.local$/ {
    t reset_condition_flag
    : reset_condition_flag
EOF

sed "$EPICS_TEMP_REPO/expected-docker-env-vars.txt" -e '
    h
    s|.*|    n|p

    g
    s|\\|\\\\|g
    s|[/*.]|\\&|g
    s|^|    s/|
    s|$|//|
    p

    g
    s|[E ][N ][V ] ||
    s|=.*|_OK|
    h

    s|^|    t |p
    s|.*|    h|p

    g
    s|^|    s/.*/Error checking environment variable: |
    s|_OK$|/p|p

    s|.*|    g|p
    s|.*|    s/^/    while checking: /p|p
    s|.*|    q|p

    g
    s|^|    : |p
    s|.*||p
' >> "$EPICS_TEMP_REPO/check-docker-env-vars.sed"

cat >> "$EPICS_TEMP_REPO/check-docker-env-vars.sed" << EOF

    s/.*/SUCCESS/
    p
    q
}
EOF

RESULT="$(sed -n -f "$EPICS_TEMP_REPO/check-docker-env-vars.sed" Dockerfile)"

rm -rf "$EPICS_TEMP_REPO"

if [ "$RESULT" != "SUCCESS" ]; then
    echo "$RESULT" >&2
    exit 1
fi
