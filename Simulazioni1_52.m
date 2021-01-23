%% SIMULAZIONI per tir 52

% Aggiornato al 19/01/2021 e funzionante!

% Lo script carica tabelle di dati in uscita da tiretest di vigrade. Da queste
% vengono estratti gli array di interesse FX FY MZ SA SL. Vengono poi caricati 
% i file tir e creati input mfeval corrispondenti.

clear all
clc

%% IMPORTARE TABELLE
% SENZA ISTERESI da vigrade, le tabelle devono essere in formato excel .csv
% e organizzate su più colonne

TVY5 = readtable('C:\Users\giovanni\Desktop\TireFitting\Script\Simulazione Tir 52\t52_lat_500');
TVY10 = readtable('C:\Users\giovanni\Desktop\TireFitting\Script\Simulazione Tir 52\t52_lat_1000');
TVY15 = readtable('C:\Users\giovanni\Desktop\TireFitting\Script\Simulazione Tir 52\t52_lat_1500');

TX5 = readtable('C:\Users\giovanni\Desktop\TireFitting\Script\Simulazione Tir 52\t52_long_500N');
TX10 = readtable('C:\Users\giovanni\Desktop\TireFitting\Script\Simulazione Tir 52\t52_long_1000N');
TX15 = readtable('C:\Users\giovanni\Desktop\TireFitting\Script\Simulazione Tir 52\t52_long_1500N');

%% VETTORI DI FX, FY, MZ, SA, SL
% vengono importati da vigrade i vettori di interesse

%VIGRADE
SAV5 = TVY5.til_wheel_tire_kinematics_lateral_slip;
SAV5 = SAV5.*(180/3.14159);
FYV5 = TVY5.til_wheel_tire_forces_lateral; 

SAV10 = TVY10.til_wheel_tire_kinematics_lateral_slip;
SAV10 = SAV10.*(180/3.14159);
FYV10 = TVY10.til_wheel_tire_forces_lateral; 

SAV15 = TVY15.til_wheel_tire_kinematics_lateral_slip;
SAV15 = SAV15.*(180/3.14159);
FYV15 = TVY15.til_wheel_tire_forces_lateral; 

MZV5 = TVY5.til_wheel_tire_forces_aligning_torque;
MZV10 = TVY10.til_wheel_tire_forces_aligning_torque;
MZV15 = TVY15.til_wheel_tire_forces_aligning_torque;

FX5 = TX5.til_wheel_tire_forces_longitudinal;
FX10 = TX10.til_wheel_tire_forces_longitudinal;
FX15 = TX15.til_wheel_tire_forces_longitudinal;

SL5 = TX5.til_wheel_tire_kinematics_longitudinal_slip/100;
SL10 = TX10.til_wheel_tire_kinematics_longitudinal_slip/100;
SL15 = TX15.til_wheel_tire_kinematics_longitudinal_slip/100;

%% CLEANING 
% la simulaione di vigrade compie almeno 4 sweep di slip angle, allora i dati
% che abbiamo importato vengono opportunamente tagliati dopo due periodi di sa

%V5

j = 0;
for i = 1:length(SAV5)
    if SAV5(i) == 0
        j = j +1;
    end
    if j == 3
        SAV5 = SAV5(1:i);
        FYV5 = FYV5(1:i);
        MZV5 = MZV5(1:i);
%         FX5 = FX5(1:i);
        break
    end  
end

%V10

j = 0;
for i = 1:length(SAV10)
    if SAV10(i) == 0
        j = j +1;
    end
    if j == 3
        SAV10 = SAV10(1:i);
        FYV10 = FYV10(1:i);
        MZV10 = MZV10(1:i);
%         FX10 = FX10(1:i);
        break
    end  
end

%V15

j = 0;
for i = 1:length(SAV15)
    if SAV15(i) == 0
        j = j +1;
    end
    if j == 3
        SAV15 = SAV15(1:i);
        FYV15 = FYV15(1:i);
        MZV15 = MZV15(1:i);
%         FX15 = FX15(1:i);
        break
    end  
end
    
%% MFEVAL INPUTS
% input per mfeval

T52set = readTIR('C:\Users\giovanni\Desktop\TireFitting\Script\Simulazione Tir 52\MagicFormula52_Paramerters.tir');

%n punti: 1000 / 10002 / 2000 / 958
evalFz1 = ones(958,1)*500;
evalFz2 = ones(958,1)*1000;
evalFz3 = ones(958,1)*1500;
evalNull = zeros(958, 1);

% NUOVO SLIP ANGLE 11.95 deg = 0.20856685 rad / 12 deg = 0.20944
evalSA1 = linspace(0,-0.20944,240);
evalSA2 = linspace(-0.20856685,0.20856685,478);
evalSA3 = linspace(0.20944,0,240);
evalSA = (horzcat(evalSA1,evalSA2,evalSA3))';

evalVx = ones(958, 1)*10; 
evalSL = ones(958,1)*0.1;


% LATERALE
MFinputlaterale5 = [evalFz1 evalNull evalSA evalNull evalNull evalVx];
MFinputlaterale10 = [evalFz2 evalNull evalSA evalNull evalNull evalVx];
MFinputlaterale15 = [evalFz3 evalNull evalSA evalNull evalNull evalVx];

% LONGITUDINALE
evalSAX = zeros(958, 1);
evalSLX = linspace(-1,1,958)';
MFinputlongitudinale5 = [evalFz1 evalSLX evalNull evalNull evalNull evalVx];
MFinputlongitudinale10 = [evalFz2 evalSLX evalNull evalNull evalNull evalVx];
MFinputlongitudinale15 = [evalFz3 evalSLX evalNull evalNull evalNull evalVx];

%% MFEVAL - FY PLOT LATERALE
MFoutputVYF5 = mfeval(T52set,MFinputlaterale5,111);
MFoutputVYF5(:,8) = MFoutputVYF5(:,8).*(180/3.14159);
MFoutputVYF10 = mfeval(T52set,MFinputlaterale10,111);
MFoutputVYF10(:,8) = MFoutputVYF10(:,8).*(180/3.14159);
MFoutputVYF15 = mfeval(T52set,MFinputlaterale15,111);
MFoutputVYF15(:,8) = MFoutputVYF15(:,8).*(180/3.14159);

figure
set(0,'defaultfigurecolor',[1 1 1])
hold on 
grid on
grid minor
title('FY vs SA (T52 mfeval)')
xlabel('SA [deg]')
ylabel('FY [N]')
plot(SAV5,FYV5,'r','linewidth', 2)
plot(SAV10,FYV10,'b','linewidth', 2)
plot(SAV15,FYV15,'g','linewidth', 2)
plot(MFoutputVYF5(:,8), MFoutputVYF5(:,2),'-.r','linewidth', 2)
plot(MFoutputVYF10(:,8), MFoutputVYF10(:,2),'-.b','linewidth', 2)
plot(MFoutputVYF15(:,8), MFoutputVYF15(:,2),'-.g','linewidth', 2)
legend('VIGRADE 5','MFEVAL 5')
legend('500N','1000N','1500N')

%% MFEVAL - MZ PLOT LATERALE
MFoutputVYM5 = mfeval(T52set,MFinputlaterale5,111);
MFoutputVYM5(:,8) = MFoutputVYM5(:,8).*(180/3.14159);
MFoutputVYM10 = mfeval(T52set,MFinputlaterale10,111);
MFoutputVYM10(:,8) = MFoutputVYM10(:,8).*(180/3.14159);
MFoutputVYM15 = mfeval(T52set,MFinputlaterale15,111);
MFoutputVYM15(:,8) = MFoutputVYM15(:,8).*(180/3.14159);

figure
set(0,'defaultfigurecolor',[1 1 1])
hold on 
grid on
grid minor
title('Mz vs SA (T52 mfeval)')
xlabel('SA [deg]')
ylabel('Mz [Nm]')
plot(SAV5,MZV5,'r','linewidth', 2)
plot(SAV10,MZV10,'b','linewidth', 2)
plot(SAV15,MZV15,'g','linewidth', 2)
plot(MFoutputVYM5(:,8), MFoutputVYM5(:,6),'-.r','linewidth', 2)
plot(MFoutputVYM10(:,8), MFoutputVYM10(:,6),'-.b','linewidth', 2)
plot(MFoutputVYM15(:,8), MFoutputVYM15(:,6),'-.g','linewidth', 2)
% legend('VIGRADE 5','MFEVAL 5')
legend('500N','1000N','1500N')

%% MFEVAL - FX PLOT LATERALE 
MFoutputV5 = mfeval(T52set,MFinputlongitudinale5,111);
MFoutputV10 = mfeval(T52set,MFinputlongitudinale10,111);
MFoutputV15 = mfeval(T52set,MFinputlongitudinale15,111);

figure
set(0,'defaultfigurecolor',[1 1 1])
hold on 
grid on
grid minor
title('FX vs SL (T52mfeval)')
xlabel('SL')
ylabel('FX [N]')
plot(SL5,FX5,'r','linewidth', 2)
plot(SL10,FX10,'b','linewidth', 2)
plot(SL15,FX15,'g','linewidth', 2)
plot(MFoutputV5(:,7), MFoutputV5(:,1),'-.r','linewidth', 2)
plot(MFoutputV10(:,7), MFoutputV10(:,1),'-.b','linewidth', 2)
plot(MFoutputV15(:,7), MFoutputV15(:,1),'-.g','linewidth', 2)
% legend('VIGRADE 5','MFEVAL 5')
legend('Fz = 500N','Fz = 1000N','Fz = 1500N')

%% ERRORE SUI GRAFICI - FY T52    
% FY 500
e = 0.009;
j = 1;
clear E
for i = 1:length(MFoutputVYF5)
    while j <= length(SAV5)
        if SAV5(j) <= MFoutputVYF5(i,8) + e && SAV5(j) >= MFoutputVYF5(i,8) - e
            E(i,1) = abs(FYV5(j)-MFoutputVYF5(i,2))/abs(FYV5(j));
            E(i,2) = SAV5(j);
            E(i,3) = i; %debug 
            break
        end
        j = j + 1;
    end
end
% 
% figure
% plot(E(:,2),E(:,1),'.')

etotFY5 = mean(E(:,1));

% FY 1000
e = 0.009;
j = 1;
clear E
for i = 1:length(MFoutputVYF10)
    while j <= length(SAV10)
        if SAV10(j) <= MFoutputVYF10(i,8) + e && SAV10(j) >= MFoutputVYF10(i,8) - e
            E(i,1) = abs(FYV10(j)-MFoutputVYF10(i,2))/abs(FYV10(j));
            E(i,2) = SAV10(j);
            E(i,3) = i; %debug 
            break
        end
        j = j + 1;
    end
end

% figure
% plot(E(:,2),E(:,1),'.')

etotFY10 = mean(E(:,1));

% FY 1500
e = 0.009;
j = 1;
clear E
for i = 2:length(MFoutputVYF15)
    while j <= length(SAV15)
        if SAV15(j) <= MFoutputVYF15(i,8) + e && SAV15(j) >= MFoutputVYF15(i,8) - e
            E(i,1) = abs(FYV15(j)-MFoutputVYF15(i,2))/abs(FYV15(j));
            E(i,2) = SAV15(j);
            E(i,3) = i; %debug 
            break
        end
        j = j + 1;
    end
end

% figure
% plot(E(:,2),E(:,1),'.')

etotFY15 = mean(E(:,1));

%% ERRORE SUI GRAFICI - MZ T52
% mz 500
e = 0.009;
j = 1;
clear E
for i = 1:length(MFoutputVYM5)
    while j <= length(SAV5)
        if SAV5(j) <= MFoutputVYM5(i,8) + e && SAV5(j) >= MFoutputVYM5(i,8) - e
            E(i,1) = abs(MZV5(j)-MFoutputVYM5(i,6))/abs(MZV5(j));
            E(i,2) = SAV5(j);
            E(i,3) = i; %debug 
            break
        end
        j = j + 1;
    end
end
i = 1;
while i <= length(E)
    if E(i,1) > 200 
        E(i,:) = [];
    end
    i = i+1;
end
etotMZV5 = mean(E(:,1));

% figure
% plot(E(:,2),E(:,1),'.')


% mz 1000
e = 0.009;
j = 1;
clear E
for i = 1:length(MFoutputVYM10)
    while j <= length(SAV10)
        if SAV10(j) <= MFoutputVYM10(i,8) + e && SAV10(j) >= MFoutputVYM10(i,8) - e
            E(i,1) = abs(MZV10(j)-MFoutputVYM10(i,6))/abs(MZV10(j));
            E(i,2) = SAV10(j);
            E(i,3) = i; %debug 
            break
        end
        j = j + 1;
    end
end
etotMZV10 = mean(E(:,1));
% 
% figure
% plot(E(:,2),E(:,1),'.')

% mz 1500
e = 0.009;
j = 1;
clear E
for i = 1:length(MFoutputVYM15)
    while j <= length(SAV15)
        if SAV15(j) <= MFoutputVYM15(i,8) + e && SAV15(j) >= MFoutputVYM15(i,8) - e
            E(i,1) = abs(MZV15(j)-MFoutputVYM15(i,6))/abs(MZV15(j));
            E(i,2) = SAV15(j);
            E(i,3) = i; %debug 
            break
        end
        j = j + 1;
    end
end
etotMZV15 = mean(E(:,1));

% figure
% plot(E(:,2),E(:,1),'.')

%% ERRORE SUI GRAFICI - FX T52
e = 0.0005;
j = 1;
clear E
for i = 2:length(MFoutputV5)
    while j <= length(SL5)
        if SL5(j) <= MFoutputV5(i,7) + e && SL5(j) >= MFoutputV5(i,7) - e
            E(i,1) = abs(FX5(j)-MFoutputV5(i,1))/abs(FX5(j));
            E(i,2) = SL5(j);
            E(i,3) = i; %debug 
            break
        end
        j = j + 1;
    end
end

% figure
% plot(E(:,2),E(:,1),'.')

etotFX5 = mean(E(:,1));

% FX 1000
e = 0.0005;
j = 1;
clear E
for i = 2:length(MFoutputV10)
    while j <= length(SL10)
        if SL10(j) <= MFoutputV10(i,7) + e && SL10(j) >= MFoutputV10(i,7) - e
            E(i,1) = abs(FX10(j)-MFoutputV10(i,1))/abs(FX10(j));
            E(i,2) = SL10(j);
            E(i,3) = i; %debug 
            break
        end
        j = j + 1;
    end
end

% figure
% plot(E(:,2),E(:,1),'.')

etotFX10 = mean(E(:,1));

% FX 1500
e = 0.0005;
j = 1;
clear E
for i = 2:length(MFoutputV15)
    while j <= length(SL15)
        if SL15(j) <= MFoutputV15(i,7) + e && SL15(j) >= MFoutputV15(i,7) - e
            E(i,1) = abs(FX15(j)-MFoutputV15(i,1))/abs(FX15(j));
            E(i,2) = SL15(j);
            E(i,3) = i; %debug 
            break
        end
        j = j + 1;
    end
end
% 
% figure
% plot(E(:,2),E(:,1),'.')

etotFX15 = mean(E(:,1));