#!/bin/bash

reset

set boxwidth 0.5
set style fill solid
set xlabel "Probability"
set ylabel "Iterations"
set title "First attempt algorithm; Mixed fault - Omission, Duplication & Reordering"
set yrange [0:220000]
set key off
set style line 1 lc rgb "#E62B17"
set style line 2 lc rgb "#1D4599"
set term png
set output "/home/evert/tinyos-main/apps/SEC/Graphs/MS_ODR.png"
plot "/home/evert/tinyos-main/apps/SEC/Graphs/Input/MS_ODR.dat" every ::0::0 using 1:3:xtic(2) with boxes ls 1, "/home/evert/tinyos-main/apps/SEC/Graphs/Input/MS_ODR.dat" every ::1::7 using 1:3:xtic(2) with boxes ls 2
replot
