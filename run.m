close all; clc; clear;

%% Compensator Design for PLL with PM = 50 deg - main compensator

f = 60; % Hz
w0 = 2*pi*f; % 377 rad/s for 60 Hz

Vs_peak = 391; % 391V line-to-neutral, normalized value (simulation)
Vs_peak_LL = 391*sqrt(3); % L2L voltage (not used)

w2 = 2*w0; % second harmonic

H = tf([1,0,4*w0*w0],[1,4*w0,4*w0*w0,0,0]);

% opts = bodeoptions('cstprefs'); opts.PhaseWrapping='on';
figure; bode(H); grid minor;
figure; margin(H); grid minor;

desired_freq = 200; % in rad/s
[base_mag,base_phase, ~] = bode(H, desired_freq);

%% Design of Lead Filter - 2 cascaded filters

wc = 200; % target cut-off frequency
target_PM = 50;

target_phase = -180 + target_PM;
needed_additional_phase = target_phase - base_phase;
delta = needed_additional_phase/2;

alpha = (1+sind(delta))/(1-sind(delta));
filter_pole = wc*sqrt(alpha);
filter_zero = filter_pole/alpha;

F = tf([1,2*filter_zero,filter_zero^2], [1,2*filter_pole, filter_pole^2]);
close all;

%% Solve for Compensator gain

L = H*F;
h0 = 1/bode(L,wc);
L = L*h0;
opts = bodeoptions('cstprefs'); opts.PhaseMatching='on';
figure; margin(L, opts); grid minor;
figure; bode(L, opts); grid minor;

close all;

