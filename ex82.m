makeclean

%% Example 8.2 Dynamic Performance of Real-/Reactive Power Controller

L = 200E-6;
R = 2.38e-3;
ron = 0.88e-3;
Vd = 1.0;
VDC = 1250;
fs = 1680;
w0 = 377;
V_LL = 480;
Vsn = 391;
tc = 1e-3;
tc_ff = 8e-6;

% VSC Transfer Function

sys = tf(1,[L, (R+ron)]);


% Compensators

kp = L / tc;
ki = (R+ron)/tc;

% Compensator for both d and q frames
K = tf([kp,ki],[1,0]);

L = (kp/L)*tf([1,(ki/kp)],[1, (R+ron)/L])*tf(1,[1,0]);

G = tf(1,[tc,1]);
figure; bode(G); grid minor;
figure; bode(L); grid minor;

close all;

Vsd = 391;
L = 0.7e-3;

tau = 1.5e-3;

VDC = 1250;
Ps0 = 0;
delta_Ps = 2.5e6;
Qs0 = 0;
delta_Qs = 0;

Vtd_t0 = Vsd + ((2*L*w0)/(3*Vsd))*Qs0 + ((2*L)/(3*tau*Vsd))*delta_Ps;
Vtq_t0 = ((2*L*w0)/(3*Vsd))*Ps0 - ((2*L)/(3*tau*Vsd))*delta_Qs;

Req_VDC_2 = sqrt(Vtq_t0^2 + Vtd_t0^2);
Req_VDC_PWM = 2*Req_VDC_2;
Req_VDC_3rd = 1.74*Req_VDC_2;
