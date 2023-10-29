close all;
clear; 
clc;

h = 391*685.42;
n1 = tf([1,0,568516],1);
n2 = tf([1,166,6889],1);
N = h*n1*n2;

d1 = tf([1,0,0],1);
d2 = tf([1,1508,568516],1);
d3 = tf([1,964,232324],1);
D = d1*d2*d3;

L = N/D;
opts = bodeoptions('cstprefs'); opts.PhaseWrapping='on';
figure; bode(L,opts); grid minor;
figure; margin(L);
grid minor;