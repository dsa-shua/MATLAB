clc;

%% PART 1
figure(1);
plot(out.PV_voltage0, out.PV_power0);
xlabel('PV Voltage(V)');
ylabel('PV Power(W)');
title("PV P-V Characteristic Curve");

figure(2);
plot(out.PV_voltage0, out.PV_current0);
xlabel('PV Voltage (V)');
ylabel('PV Current (A)');
title("PV I-V Characteristic Curve");


% %% PART 2
% close all;
% clc;
% 
% figure(1);
% plot(out.voltage_o, (out.I_PV.*out.V_PV));
% xlabel('PV Voltage(V)');
% ylabel('PV Power(W)');
% title("PV P-V Characteristic Curve");
% 
% figure(2);
% plot(out.voltage_o, out.current_o);
% xlabel('PV Voltage (V)');
% ylabel('PV Current (A)');
% title("PV I-V Characteristic Curve");
