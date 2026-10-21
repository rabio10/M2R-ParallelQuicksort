
OUTPUT_DIRECTORY=data/`hostname`_`date +%F`
mkdir -p $OUTPUT_DIRECTORY
NOW=`date +%R`

for i in 100 1000 10000 100000 1000000 2000000 5000000 10000000; do
    for rep in `seq 1 5`; do
        for a in sequential parallelQuicksort qsort; do
            OUTPUT_FILE=$OUTPUT_DIRECTORY/measurements_${NOW}_$a.txt
            echo "Size: $i" >> $OUTPUT_FILE
            ./src/parallelQuicksort_order_diff $i $a >> $OUTPUT_FILE
            sleep 1
        done
    done ;
done

for a in sequential parallelQuicksort qsort; do
    OUTPUT_FILE=$OUTPUT_DIRECTORY/measurements_${NOW}_$a
    perl scripts/csv_quicksort_extractor.pl < $OUTPUT_FILE.txt > $OUTPUT_FILE.csv
done
