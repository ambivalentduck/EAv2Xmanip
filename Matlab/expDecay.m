function f=expDecay(p,xdata)

f = p(1)+p(2)*exp(-xdata/p(3));