restart -f
force clk 0, 1 50 ns -repeat 100 ns
run 100 ns
force reset '0'
run 100 ns
force reset '1'
run 1 ms
