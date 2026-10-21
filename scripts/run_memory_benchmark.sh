

OUTPUT_DIRECTORY=data/`hostname`_`date +%F`
mkdir -p $OUTPUT_DIRECTORY
OUTPUT_FILE=$OUTPUT_DIRECTORY/memory_`date +%R`.csv

echo "Size, Type, MaxRSS" > $OUTPUT_FILE
for i in 100 1000 10000 100000 1000000 2000000 5000000 10000000; do
    for rep in `seq 1 5`; do
        for a in sequential parallelQuicksort qsort; do
            /usr/bin/time -a -o $OUTPUT_FILE -f "$i, $a, %M" ./src/parallelQuicksort_order_diff $i $a > /dev/null
        done
    done ;
done
