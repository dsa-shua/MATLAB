clc;
clear;
close all;

%% Ask User for Simulation Options

prompt_3rd = 'Inject 3rd Harmonic Component? [Yes: 1, No: 0]: ';
cond_3rd = input(prompt_3rd,"s");
if cond_3rd == "1"
    third_harmonic_injection = 1;
else
    third_harmonic_injection = 0; 
end

prompt_f = 'Frequency Sweep? [Yes: 1, No: 0]: ';
cond_f = input(prompt_f, "s");
if cond_f == "1"
    frequency_sweep = 1; 
else
    frequency_sweep = 0; 
end

prompt_a ='Amplitude Sweep? [Yes: 1, No: 0]: ';
cond_a = input(prompt_a,"s");
if cond_a == "1"
    amplitude_sweep = 1; 
    amp_init = 220; % starting amplitude of sweep (RMS)
    amp_fin = 720; % final amplitude of sweep (RMS)
else
    amplitude_sweep = 0;
end

%% Simulation Setup
% DC comes from a three-phase DBR connected to 3 ph Voltage Source;
% 220 Vrms
Vdc = sqrt(2)*sqrt(3)*220;
Vdc_2= Vdc/2;

% variable voltage and variable frequency.... 
% Frequency command
f=60;
% Carrier frequency
fs = 3e3;
% This is for plotting. 
Fs = 1e6;
dt = 1/Fs;

% Number of cycles and time duration
if frequency_sweep== 0
    no=4;
else
    no = 6;
end 

T = no*1/f;
t = 0:dt:T-dt;

% Vref provides basically what you want to see from the inveter output. line to line voltage (rms) you
% can measure from the inverter output lines

Vref = 380;


if amplitude_sweep == 0
    Vm = Vref/sqrt(3)*sqrt(2);
else
    sweep_start_amp = amp_init/sqrt(3)*sqrt(2);
    sweep_end_amp = amp_fin/sqrt(3)*sqrt(2);
    Vm = linspace(sweep_start_amp,sweep_end_amp,length(t));
end

% To control your voltage output
ma = Vm/Vdc_2;

% Phase voltage magnitude(Pole Voltage)
if frequency_sweep == 0
   Van= Vm.*sin(2*pi*f*t);
   Vbn= Vm.*sin(2*pi*f*t-120/360*2*pi);
   Vcn= Vm.*sin(2*pi*f*t+120/360*2*pi);
else
   Van= Vm.*chirp(t,60,0.03,120,"linear",-90);
   Vbn= Vm.*chirp(t,60,0.03,120,"linear",-90-120);
   Vcn= Vm.*chirp(t,60,0.03,120,"linear",-90+120);
end

% To inject a 3rd harmonic component
V_3rd = -Vm/6.*sin(2*pi*f*3*t);
V_3rd = third_harmonic_injection*V_3rd; 

%line to line voltage
Vab = Van-Vbn;
Vbc = Vbn-Vcn;
Vca = Vcn-Van;

% triangular waveform (carrier waveform)
Vtri = sawtooth(2*pi*fs*t,1/2)*Vdc_2;

% Reference Voltages used in the modulation
Va_cmd = Van-V_3rd;
Vb_cmd = Vbn-V_3rd;
Vc_cmd = Vcn-V_3rd;  


%% Student Code (starting here):

% First, let us plot the inputs of the 3p-SPWM
figure; sgtitle("Input Details");
subplot(3,1,1);
plot(t,Va_cmd,t,Vb_cmd,t,Vc_cmd);grid on;
xlabel("time (s)");ylabel("Vx_cmd");
subplot(3,1,2);
plot(t,Vtri,t,Va_cmd);grid on;
xlabel("time (s)"); ylabel("Overlay");
subplot(3,1,3);
plot(t,V_3rd);grid on;
xlabel("time (s)"); ylabel("3rd Harmonic Component");


% Modulator Code: 

% As discussed, we can represent the 3p-SPWM mathematically using 
% switching functions. First, pole voltage is as follows:
% 
% Vas = (Vdc/3) * (2*Sa - Sb - Sc) = (1/3) * (2*Van - Vbn - Vcn)
% 
% We choose the first formula in this design.
%
% For the switching mechanism, we set Sa ON if Va_cmd > Vtri,
% that is, if the reference voltage is bigger than the carrier, we
% turn on the switch. The same goes for the two other phases. 


for i = 1:length(t)
    if Va_cmd(i) >= Vtri(i)
        Sa = 1; % switch is on, same goes for other phases
    else
        Sa = 0; % switch is off, same goes for other phases
    end

    if Vb_cmd(i) >= Vtri(i)
        Sb = 1;
    else
        Sb = 0;
    end

    if Vc_cmd(i) >= Vtri(i)
        Sc = 1;
    else
        Sc = 0;
    end


    Van_pwm(i) = Vdc/2*(2*Sa-1);
    Vbn_pwm(i) = Vdc/2*(2*Sb-1);
    Vcn_pwm(i) = Vdc/2*(2*Sc-1);

    % phase voltages can be represented in terms of switching functions
    % and pole voltage
    Vas(i) = Vdc/3*(2*Sa-Sb-Sc);
    Vbs(i) = Vdc/3*(2*Sb-Sc-Sa);
    Vcs(i) = Vdc/3*(2*Sc-Sa-Sb);
    
    % Line to line voltage (Vab = Vas- Vbs = Van - Vbn)
    Vab_pwm(i) = Vas(i) - Vbs(i);
    Vbc_pwm(i) = Vbs(i) - Vcs(i);
    Vca_pwm(i) = Vcs(i) - Vas(i);


    % With the output, we take extract the fundamental using a low
    % pass filter. We use the indicated filter from above.

    % low pass filter
    if i < 3
        if i == 1
            Vabf(i) = Vab_pwm(i);
            Vbcf(i) = Vbc_pwm(i);
            Vcaf(i) = Vca_pwm(i);
        else
            Vabf(2) = Vab_pwm(1);
            Vbcf(2) = Vbc_pwm(1);
            Vcaf(2) = Vca_pwm(1);
        end
    else
        % IIR Filter
        Vabf(i)= 0.999*Vabf(i-1)+0.001*Vab_pwm(i);  
        Vbcf(i)= 0.999*Vbcf(i-1)+0.001*Vbc_pwm(i);  
        Vcaf(i)= 0.999*Vcaf(i-1)+0.001*Vca_pwm(i);  
    end
end

%% Plot Modulation Results

figure; sgtitle("Brief Summary of Modulation Results");
subplot(3,1,1); plot(t,Van_pwm); grid on;
xlabel("time (s)"); ylabel("Van");
subplot(3,1,2); plot(t,Vas); grid on;
xlabel('time (s)'); ylabel("Vas");
subplot(3,1,3); plot(t,Vab_pwm); grid on;
xlabel("time (s)"); ylabel("Vab");

% Pole Voltages
figure; sgtitle("Full Modulation Results");
subplot(3,3,1); plot(t,Van_pwm); grid on;
xlabel("time (s)"); ylabel("Van");
subplot(3,3,2); plot(t,Vbn_pwm); grid on;
xlabel("time (s)"); ylabel("Vbn");
subplot(3,3,3); plot(t,Vcn_pwm); grid on;
xlabel("time (s)"); ylabel("Vcn");


% Line to Line PWM

subplot(3,3,7); plot(t,Vab_pwm); grid on;
xlabel("time (s)"); ylabel("Vab");
subplot(3,3,8); plot(t,Vbc_pwm); grid on;
xlabel("time (s)"); ylabel("Vbc");
subplot(3,3,9); plot(t,Vca_pwm); grid on;
xlabel("time (s)"); ylabel("Vca");

% Phase Voltages

subplot(3,3,4); plot(t,Vas); grid on;
xlabel("time (s)"); ylabel("Vas");
subplot(3,3,5); plot(t,Vbs); grid on;
xlabel("time (s)"); ylabel("Vbs");
subplot(3,3,6); plot(t,Vcs); grid on;
xlabel("time (s)"); ylabel("Vcs");


%% Plot PWM Result
figure; sgtitle(" Brief PWM Result");
plot(t, Vab_pwm, t, Vabf); grid on;
xlabel("time(s)");
ylabel("Vab and Vab\_LPF");

figure; sgtitle("PWM Results");
subplot(3,1,1); plot(t, Vab_pwm, t, Vabf); grid on;
xlabel("time(s)"); ylabel("Vab and Vab\_LPF");
subplot(3,1,2); plot(t, Vbc_pwm, t, Vbcf); grid on;
xlabel("time(s)"); ylabel("Vbc and Vbc\_LPF");
subplot(3,1,3); plot(t, Vca_pwm, t, Vcaf); grid on;
xlabel("time(s)"); ylabel("Vca and Vca\_LPF");

figure; sgtitle("Output of 3\phi-phase Inverter");
plot(t,Vabf,t,Vbcf,t,Vcaf); grid on;
xlabel("time(s)"); ylabel("Magnitude");

%% Check Harmonics
x = Vab_pwm; % check harmonics on Vab line to line voltage
% x = Van_pwm;

f = 60;
Fs = 1e6;

L = length(t);
T = 1/Fs;
t = (0:L-1)*T; 

Y = fft(x);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

figure;
f = Fs*(0:(L/2))/L;
plot(f,P1); grid minor; 
ylabel("Amplitude"); xlabel("frequency f");
title("Single-Sided Amplitude Spectrum of Vab\_pwm");