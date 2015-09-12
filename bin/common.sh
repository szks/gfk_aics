#!/bin/bash

check_size() {
        ls -lh $1 1>&2
}


RUN() {
        $TIME $@
}


RUN_PERL() {
        $TIME $PERL $@
}


my_time()
{
        echo "$@" 1>&2
        #local TIMEFORMAT="time = %R"
        time $@
}


#fapp_pa_perl()
#{
#        local DIR=`echo "${@##*/}" | sed 's/ /_/g'`/pa$pa_no
#        fapp -C -Ihwm -d $DIR -Hpa=$pa_no env LD_PRELOAD=$GFKDIR/perlpa.so /usr/bin/perl $@
#}


TIME=""
PERL=/usr/bin/perl

if [ "$TIMEFORMAT" != "" ]; then
        TIME="my_time"
fi

#if [ "$pa_no" != "" -a $myrank -eq 0 ]; then
#        PERL=fapp_pa_perl
#fi
