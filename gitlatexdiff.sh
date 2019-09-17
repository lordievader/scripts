#!/bin/bash
# Builds a latexdiff based on two branches.
GIT_DIR=$(pwd)
COMPARE='/tmp/gitlatexdiff.git'
REMOTE=$(git remote get-url origin)

clone_temp () {
    git clone "${REMOTE}" "${COMPARE}"
    cd "${COMPARE}"
    make
}

diff () {
    cd "${GIT_DIR}"
    latexdiff --encoding ascii --append-safecmd=subfile "${COMPARE}/main.tex" "${GIT_DIR}/main.tex" --flatten > "${GIT_DIR}/gitlatexdiff.tex"
}

build () {
    cd "${GIT_DIR}"
    latexmk -f -pdf "${GIT_DIR}/gitlatexdiff.tex"
    cp gitlatexdiff.pdf output/gitlatexdiff.pdf
}

cleanup () {
    cd "${GIT_DIR}"
    latexmk -C "${GIT_DIR}/gitlatexdiff.tex"

    rm -fr /tmp/gitlatexdiff.git
    rm "${GIT_DIR}/gitlatexdiff.*"
}

main () {
    clone_temp
    diff
    build
    cleanup
}


main
