#!/bin/bash
# Distribution of the run times: REPS runs of each algorithm at each size,
# each in its own process, all in random order (replication + randomization).
# Sizes: SIZES="100 1000" (several) or SIZE=5000000 (one).
# Output: long-format CSV (run, size, type, time), run = execution order.

REPS=${REPS:-30}
SIZES=${SIZES:-${SIZE:-5000000}}
OUTPUT_DIRECTORY=data/`hostname`_`date +%F`
mkdir -p $OUTPUT_DIRECTORY
NOW=`date +%H%M`
OUTPUT_FILE=$OUTPUT_DIRECTORY/distribution_$NOW.csv

# How the experiment ran
{
    lscpu | grep -E "^Model name|^CPU\(s\)|^Thread|^Core"
    free -g
    uname -r
    gcc --version | head -1
    echo "git commit: `git rev-parse --short HEAD`"
    git status --short src scripts
    uptime
} > $OUTPUT_DIRECTORY/environment_$NOW.txt

# Shuffled plan (size x algorithm x rep), one "size,algorithm" per line
PLAN=$(for s in $SIZES; do for a in sequential parallelQuicksort qsort; do for r in `seq 1 $REPS`; do echo "$s,$a"; done; done; done | shuf)

echo "run,size,type,time" > $OUTPUT_FILE
run=0
for p in $PLAN; do
    run=$((run+1))
    s=${p%,*}
    a=${p#*,}
    ./src/parallelQuicksort_order_diff $s $a | awk -v run=$run -v size=$s '
        / took: /      {print run "," size "," $1 "," $(NF-1)}
        /Oops|Unknown/ {print "ERROR: " $0 > "/dev/stderr"}' >> $OUTPUT_FILE
done
echo $OUTPUT_FILE
