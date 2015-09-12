#!/bin/bash

CONF_FILE=$1
DIST_DIR=$2

n_error=0

while read line
do
        file=`eval "readlink -e $line"`
        if [ $? -ne 0 ]; then
                echo "*** error: file not exist: $line"
                n_error=`expr $n_error + 1`
        else
                ln -sf $file $DIST_DIR
        fi
done < $CONF_FILE

exit $n_error
