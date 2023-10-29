makeclean;

damping_ratio = 1;
f = 60;
settling_time = 1/f; % one period of 60 Hz grid

wn = 4.6/(damping_ratio*settling_time);

Kp = 2*damping_ratio*wn;
Ti = (2*damping_ratio)/wn;

Ki = sqrt(Kp/Ti);

disp("Ki: "); Ki
disp("Kp: "); Kp