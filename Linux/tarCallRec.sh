#!/bin/bash
for Y in 2015 2016; do
    for M in 01 02 03 04 05 06 07 09 10 11 12; do
        zing="$Y$M" 
        ls -l call_rec/*_$zing*.mp3 && \
            tar -czvf callrec_$zing.tgz call_rec/*_$zing* --remove-files
    done
done