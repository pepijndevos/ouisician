% The usage is the same as sin(2*pi*f*t)
function y = triangle(t)
y = abs(mod((t+pi)/pi, 2)-1);