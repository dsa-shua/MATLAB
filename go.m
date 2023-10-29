makeclean;

%% Example 8.4-8.5?

L = 200e-6;
C = 19250e-6 / 2;
R = 2.38e-3;
ron = 0.88e-3;
fs = 1680;
Vsd = 391;
w0 = 377;
Vd = 1.0;
Ps_rated = 2.5e6;
tau = 1.0e-3;

% DC-bus voltage dynamics
Gv = tf(-2/C)*tf([tau,1],[1,0]);


kp = L/tau;
ki = (R+ron)/tau;



Gp = tf(1,[tau, 1]); 
Gi = Gp;

% These values are from Ch6...
F = tf([1,0,1131^2],[1,2262,1131^2]);
K = 0.0007;

% Kv = tf(1868)*tf([1,19],[1,2077])*tf(1,[1,0]);
Kv = tf(1.996)*tf([1,172],[1,0]);

L = tf(-1)*Kv*Gp*Gv;
L1 = tf(-1)*L;

TF = feedback(L,1);
TF_1 = feedback(L1,1);