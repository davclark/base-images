#!/bin/bash
if [ -z "$1" ]; then
    /opt/conda/bin/conda3
elif [ "$1" = 'info' ]; then
    /opt/conda/bin/conda3 $*
else
    /opt/conda/bin/conda3 $1 -n ipykernel_py2 ${*:2}
fi
