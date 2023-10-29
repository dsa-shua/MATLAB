clear; close all; clc;

f = @(x,y) 2*x.^2 + y.^2;
z = @(x,y) 4*x + 2*y - 3;
[X,Y] = meshgrid(-5:0.25:5);

figure; 
surf(X,Y,z(X,Y), 'FaceAlpha','0.5', 'FaceColor','red');
hold on;
surf(X,Y,f(X,Y), 'FaceColor','flat');
plot3(1,1, f(1,1), 'r*', 'MarkerSize', 10, 'LineWidth', 10);
hold on;
plot3(1,1,z(1,1),'y*','LineWidth',10);
grid minor;
title("Tangent Plane to Graph of f(x_1,x_2)");
legend('tangent plane', 'f(x_1,x_2)','f(x_0)', 'z(x_0)');

