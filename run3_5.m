% example 3.5 bode plotting
clear;clc; close all;
L = 690e-6;
R = 5e-3;
r_on = 0.88e-3;

K = tf([0.345, 2.94], [1 0]); % integrator
G = tf(1, [L, (R+r_on)]);

loop_gain = K*G;
figure; bode(loop_gain); grid; title("Loop Gain Bode Plot");

TF = loop_gain/(1+loop_gain);
figure; bode(TF); grid; title("Closed Loop Bode Plot");

figure; margin(TF); grid;