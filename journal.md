## 2026-10-18

**Author:** Rabii Abouaissa

- Ran the benchmark from `journal.org` on WSL2 (Ubuntu 24.04, Intel i5-12450H, 12 CPUs): sizes 100 to 1M, 5 runs each. Results in `data/Rabii_2026-10-18/`.
- Analysed the results in a Jupyter notebook (`analysis.ipynb`) instead of R/gnuplot, because of familiarity with Python. Plotted on log-log axes, so small sizes don't collapse near zero as in the `journal.org` plot.
- Extended the benchmark to 2M, 5M and 10M (`scripts/run_benchmarking.sh`) and ran it twice. Results in `data/Rabii_2026-10-19/`.

Conclusions:

- Parallel is slower than sequential up to 1M, contrary to `journal.org` (faster above ~400k), maybe because of hardware/software differences. It only catches up at 5M.
- Each run had one aberrant measurement, at a different size each time, so the experiment is hard to reproduce.
- and the parallel algorithm doesn't seem to be the best after the 1M threshold. Not sure if there's an issue with the implementation of the experimental setup (WSL). needs more investigation.


## 2026-10-18: Sequential vs parallel threshold

**Author** Yassine OUAHMANE

**Goal:** find the array size from which the parallel quicksort beats the sequential one on my laptop (i7-1185G7, 4 cores / 8 threads).

**What I did**
- Installed the missing tools (`build-essential`, `python3-venv`) and built `src/parallelQuicksort` with the existing Makefile (`-O0`).
- Wrote `scripts/run_threshold_benchmark.sh`. It runs 26 log-spaced sizes from 1e2 to 1e7, 20 repetitions each, in shuffled order, and writes a CSV.
- Ran it once (~6.5 min). Data and machine info are in `data/yassine-HP-EliteBook-840-G8-Notebook-PC_2026-10-18/`.
- Analysed the results in `analysis_yassine.ipynb` (Python venv in `.venv/`): time vs size, paired speed-up seq/par with bootstrap CI, and a Wilcoxon test per size.

**Results**
- Sequential is much faster for small arrays, because the parallel version always creates ~2000 threads.
- Break-even is around **400k–600k elements** (interpolated median crossing ≈ 440k).
- Parallel is reliably faster from **1M elements** on, but the gain stays small (≈1.3× at 1e7).

**To try next:** compile with `-O2`, vary `THREAD_LEVEL`, and replace `rand()` in `partition` (global lock) to see how the threshold moves.

## 2026-10-21: meeting and discussion
**Author:** Rabii Abouaissa

after a meeting with Yassine, we discussed the results of the threshold benchmark. We agreed that the parallel algorithm is not as efficient as expected for small input sizes, but the break-even point is different for each one of us.

so the next step for us is expanding the analysis in two directions : 
1. expand the comparison between the algorithms to larger input sizes, to see if the parallel algorithm starts to outperform the sequential one at even larger input sizes.
2. add another dimension to the analysis, by comparing the performance of the algorithmsin terms of memory usage, to see if the parallel algorithm is more memory efficient than the sequential one.  

## 2026-10-21: one algorithm per process, memory usage
**Author:** Rabii Abouaissa

- Checked if running the three algorithms one after the other in the same process biases the times: made a copy of the program (`src/parallelQuicksort_order_diff.c`) that runs only the algorithm given as 2nd argument, and ran each one in its own process, with 1 s of sleep between runs (`scripts/run_benchmarking_one_at_a_time.sh`).
- Measured the peak memory (max RSS, with `/usr/bin/time`) of each algorithm run alone, same sizes, 5 runs each (`scripts/run_memory_benchmark.sh`).
- Results in `data/Rabii_2026-10-21/`, analysis in `analysis_rabii.ipynb`.

Conclusions:

- Running each algorithm alone gives the same times as before, so we continue with the original program.
- One run printed a negative time: the clock went backwards during the run (the program uses `gettimeofday`, the wall clock, which WSL can adjust). The aberrant points are all too short, so they might come from this.
- Memory is very stable from one run to another, unlike the times.
- Sequential uses nothing more than the two arrays. Parallel adds ~6–8 MB for the threads whatever the size (a lot for small arrays, +4% at 10M). Built-in adds one more copy of the array (~76 MB at 10M).
- So the parallel algorithm is not more memory efficient than the sequential one, but its extra memory doesn't grow with the size.
