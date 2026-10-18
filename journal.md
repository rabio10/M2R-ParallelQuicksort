# 2026-10-18

**Author:** Rabii Abouaissa

- Ran the benchmark from `journal.org` on WSL2 (Ubuntu 24.04, Intel i5-12450H, 12 CPUs): sizes 100 to 1M, 5 runs each. Results in `data/Rabii_2026-10-18/`.
- Analysed the results in a Jupyter notebook (`analysis.ipynb`) instead of R/gnuplot, because of familiarity with Python. Plotted on log-log axes, so small sizes don't collapse near zero as in the `journal.org` plot.
- Extended the benchmark to 2M, 5M and 10M (`scripts/run_benchmarking.sh`) and ran it twice. Results in `data/Rabii_2026-10-19/`.

Conclusions:

- Parallel is slower than sequential up to 1M, contrary to `journal.org` (faster above ~400k), maybe because of hardware/software differences. It only catches up at 5M.
- Each run had one aberrant measurement, at a different size each time, so the experiment is hard to reproduce.
- and the parallel algorithm doesn't seem to be the best after the 1M threshold. Not sure if there's an issue with the implementation of the experimental setup (WSL). needs more investigation.
