restart -f
force clk 0, 1 5 ms -repeat 10 ms
run 100 ms
force reset '0'
run 100 ms
force reset '1'
run 52000 ms
force amplification1 100
run 11000 ms

force amplification2 100
run 1000 ms
force amplification3 100
run 1000 ms
force amplification4 100
run 20000 ms

force KEY "1010"

run 20000 ms
force KEY "1111"
run 500 ms


force reset '0'
run 100 ms
force reset '1'
run 52000 ms
