makeclean;

L = 200E-6;
C = 19250/2;
Vsd = 391;

figure;
vals = linspace(2.5, -2.5, abs((2.5 + 2.5) / -0.1) + 1);
unstables = [];
for P = 1:length(vals)
    Ps0 = vals(P)*1E6;
    tau = (2*L*Ps0)/(3*Vsd^2);


    Gv = tf(-1/C,1)*tf(1,[1,0]);
    Kv = tf(-1.996)*tf([1,172],[1,0]);
    Gp = tf(1,[tau,1]);
    
    OL = Gv*Kv*Gp;
    CL = feedback(OL,1);

    if ~isstable(CL)
        pzplot(CL); hold on;
        unstables = [unstables, vals(P)];
    end
end