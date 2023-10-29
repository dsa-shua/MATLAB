clear; clc;
% this program computes variables of RLC circuit
% and plots the phasor diagram
R = 5; % ohms
L = 20e-3; % H
C = 400e-6; % F
us_max = 100; % V
us_ang = 20; % angle in degrees
w = 314;
% complex representation of the source voltage
Us=us_max*exp(j*us_ang*pi/180);
% complex impedances
ZR=R; ZL=j*w*L; ZC=1/(j*w*C); Z=ZR+ZL+ZC;
% current and voltages
I=Us/Z; UR=ZR*I; UL=ZL*I; UC=ZC*I;
% RMS phasors
U_RMS=Us/sqrt(2); I_RMS=I/sqrt(2);
disp('The complex power is'); S=U_RMS*conj(I_RMS)
disp('The average power is'); P=real(S)
disp('The reactive power is'); Q=imag(S)
disp('The power factor is'); pf=cos(angle(S))
% phasor diagram
line([0 real(UR)],[0 imag(UR)],'marker','>');
text(1.05*real(UR),1.05*imag(UR),'UR');
line([0 real(UL)],[0 imag(UL)],'marker','>');
text(1.05*real(UL),1.05*imag(UL),'UL');
line([0 real(UC)],[0 imag(UC)],'marker','>');
text(1.05*real(UC),1.05*imag(UC),'UC');
line([0 real(Us)],[0 imag(Us)],'marker','>');
text(1.05*real(Us),1.05*imag(Us),'Us');
line([0 real(I)],[0 imag(I)],'marker','+','color','red');
text(real(I),2*imag(I),'I');
axis(1.5*us_max*[-1 1 -1 1]);
xlabel('Re'); ylabel('Im');
grid on; axis square; 