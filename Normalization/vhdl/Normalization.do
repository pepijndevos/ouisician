restart -f
force clk 0, 1 50 ns -repeat 100 ns
run 100 ns
force reset '0'
run 100 ns
force reset '1'
run 52000 ns
force amplification1 100
run 11000 ns

force amplification2 100
run 1000 ns
force amplification3 100
run 1000 ns
force amplification4 100
run 20000 ns

force key0 '0'
run 100 ns
force key0 '1'
run 200 ns
force key1 '0'
run 300 ns
force key1 '1'
force key2 '0'
run 20000 ns
force key2 '1' 
run 500 ns
