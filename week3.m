%% Example 3.6

%First method
clear;
clc;
close all;
w0 = 377; % 60 Hz
L = 690e-6;
R = 5e-3;
r_on = 0.88e-3;

K = tf(1, [1,0,w0*w0]); % controller
G = tf(1,[L,(R + r_on)]);
TF = K*G;
figure; bode(TF); grid minor; title("Initial Controller");
bw = bandwidth(TF); % rad/s
[gpeak,fpeak] = getPeakGain(TF);
fprintf("Bandwidth %f Hz\n", bw);
fprintf("Resonance frequency: %f Hz\n", fpeak);
figure; margin(TF); grid; title("Base Phase Margin");

[Gm, Pm, Wcg, Wcp] = margin(TF);

% Pole cancelling to eliminate low F dominant pole
K_pc = tf([1, 8.52],1) * K;
TF_pc = K_pc * G;
figure; bode(TF, TF_pc); grid minor; legend; 
title("Pole Cancelling Controller");

% Lead filter building
[Gm_pc, Pm_pc, Wcg_pc, Wcp_pc] = margin(TF_pc);
figure; margin(TF_pc); grid; title("Pole Cancelling Phase Margin");
pm_desire = 45; %deg
delta_m = pm_desire - Pm_pc;
alpha = (-sind(delta_m)-1)/(sind(delta_m)-1); 
w_c = 2333; %rad/s
p_lead1 = w_c * sqrt(alpha);
z_lead1 = p_lead1/alpha; % rad/s
h = 8680;
% K_pc_lead = h*K_pc*tf([1,z_lead1],[1,p_lead1]);
K_pc_lead = h*tf([1, 8.52], [1, 0, 377*377])*tf([1,z_lead1],[1,p_lead1]);
figure; 
TF_pc_lead = K_pc_lead*G;
bode(TF_pc_lead); grid minor; title("Controller with Lead Filter");
[Gm_pc_lead, Pm_pc_lead, Wcg_pc_lead, Wcp_pc_lead] = margin(TF_pc_lead);
figure; margin(TF_pc_lead); grid; title("With Lead Filter Phase Margin");


% Add a lag filter
F_lag = tf([1 2],[1 0.05]);
K_final = F_lag*K_pc_lead;
% K_1 = h*tf([1, 8.52], [1, 0, 377*377])*tf([1,z_lead1],[1,p_lead1])*tf([1,2],[1, 0.05]);
TF_final = K_final*G;
opts = bodeoptions('cstprefs'); opts.PhaseWrapping='on';
figure; bode(TF_final, opts); grid; title("Final Controller Design");
hold on; bode(TF_pc_lead); legend;

figure; margin(TF_final, opts); grid minor;

% Closed Loop Transfer Function
G_cl = TF_final/(1 + TF_final);
figure; bode(G_cl,opts); grid minor;
title("Bode Plot of the Closed Loop Transfer Function");

figure; margin(G_cl,opts); grid minor;


