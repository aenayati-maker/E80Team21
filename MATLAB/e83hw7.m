syms r T J;

x = -r*T/J;

s = [ 0 0 x
      0 0 0
      x 0 0];

eig(s)

e=[0.01 0.02 0
    0.02 -0.03 0
    0 0 -0.01];

eig(e)