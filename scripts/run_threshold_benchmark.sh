#!/bin/bash
# Benchmark sequential vs parallel quicksort to find the size threshold
# where the parallel version becomes faster.
# Sizes are log-spaced between 1e2 and 1e7; runs are executed in random
# order to avoid temporal bias (thermal throttling, background load...).
# Output: long-format CSV (run, size, type, time).

REPS=${REPS:-20}
OUTPUT_DIRECTORY=data/`hostname`_`date +%F`
mkdir -p $OUTPUT_DIRECTORY
OUTPUT_FILE=$OUTPUT_DIRECTORY/threshold_`date +%H%M`.csv

SIZES=$(python3 -c "import math; print(' '.join(str(round(10**(2+5*i/25))) for i in range(26)))")

# Build the experimental plan (size x rep) and shuffle it.
PLAN=$(for s in $SIZES; do for r in `seq 1 $REPS`; do echo $s; done; done | shuf)

echo "run,size,type,time" > $OUTPUT_FILE
run=0
for s in $PLAN; do
    run=$((run+1))
    ./src/parallelQuicksort $s | awk -v run=$run -v size=$s '
        /^Sequential/ {print run "," size ",Sequential," $(NF-1)}
        /^Parallel/   {print run "," size ",Parallel,"   $(NF-1)}
        /^Built-in/   {print run "," size ",Built-in,"   $(NF-1)}
        /Oops/        {print "ERROR: " $0 > "/dev/stderr"}' >> $OUTPUT_FILE
done
echo $OUTPUT_FILE
