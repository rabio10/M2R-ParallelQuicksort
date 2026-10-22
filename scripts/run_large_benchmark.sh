#!/bin/bash
# Same as run_threshold_benchmark.sh but for very large arrays (10M to 200M).
# Peak memory is ~24 bytes/element (2 arrays + qsort buffer), so ~5 GB at 200M.
# Output: long-format CSV (run, size, type, time).

REPS=${REPS:-5}
SIZES=${SIZES:-"10000000 20000000 50000000 100000000 200000000"}
OUTPUT_DIRECTORY=data/`hostname`_`date +%F`
mkdir -p $OUTPUT_DIRECTORY
OUTPUT_FILE=$OUTPUT_DIRECTORY/large_`date +%H%M`.csv

# Shuffled plan (size x rep)
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
