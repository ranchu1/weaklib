function [ eC, dV, R_In, R_Out, N_Eq ] = InitializeNES_Interp...
    ( Model, N_g, E1D, D1D, T1D, Y1D, Eta1D, Op, OpOS, ecmpTable, ecmpOS)

%
%  Energy Bin Centers:
[ eC ] = ReadData1D( '../Data/NES_RATES_EnergyBinCenter.dat', N_g );

%
% Energy Bin Widths:
[ de ] = ReadData1D( '../Data/NES_RATES_EnergyBinWidth.dat', N_g );

%
% Energy Bin Volume:
dV = ( (eC+0.5d0*de).^3 - (eC-0.5d0*de).^3 )/3.0d0;

%
kmev = 8.61733d-11;

switch Model
    case '001'
        rho = 1.1E14; % g/cm^3
        TMeV = 21.0;  % MeV
        Y    = 0.25;
        N_Eq = 1.0 ./ ( exp( (eC-145.254)./20.5399 ) + 1.0 );
        
    case '002'
        rho = 1.1E13; % g/cm^3
        TMeV = 16.0;  % MeV
        Y    = 0.14;
        N_Eq = 1.0 ./ ( exp( (eC-045.835)./15.9751 ) + 1.0 );
    case '003'
        rho = 1.2E12; % g/cm^3
        TMeV = 7.7;  % MeV
        Y    = 0.12;
        N_Eq = 1.0 ./ ( exp( (eC-020.183)./07.7141 ) + 1.0 );
    case '004'
        rho = 1.2E11; % g/cm^3
        TMeV = 7.6;  % MeV
        Y    = 0.15;
        N_Eq = 1.0 ./ ( exp( (eC-009.118)./07.5830 ) + 1.0 );
    case '005'
        rho = 1.2E10; % g/cm^3
        TMeV = 3.1;  % MeV
        Y    = 0.26;
        N_Eq = 1.0 ./ ( exp( (eC-003.886)./03.1448 ) + 1.0 );
    otherwise
        N_Eq = 1.0;
end

% NES in Rates:
R = ComputeNesRate...
    (eC, eC, rho, TMeV/kmev, Y, E1D, D1D, T1D, Y1D,...
    Eta1D, Op, OpOS, ecmpTable, ecmpOS );

R_In  = R;
R_Out = R';

end

