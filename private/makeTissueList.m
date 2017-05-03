function tissueList = makeTissueList(nm)
%function tissueProps = makeTissueList(nm)
%   Returns the tissue optical properties at the wavelength nm: and the
%   thermal properties, note that the data for skull and brainmatter are
%   not correct, they are simply placeholders
%       tissueProps = [mua; mus; g; VHC; TC]'; VHC is volumetric heat capacity
%       [J/cm^3/K], D is density kg/cm^3, TC is thermal conductivity W/cm/K
%   Uses 
%       SpectralLIB.mat

%% Load spectral library
load spectralLIB.mat
%   muadeoxy      701x1              5608  double              
%   muamel        701x1              5608  double              
%   muaoxy        701x1              5608  double              
%   muawater      701x1              5608  double              
%   musp          701x1              5608  double              
%   nmLIB         701x1              5608  double              
MU(:,1) = interp1(nmLIB,muaoxy,nm);
MU(:,2) = interp1(nmLIB,muadeoxy,nm);
MU(:,3) = interp1(nmLIB,muawater,nm);
MU(:,4) = interp1(nmLIB,muamel,nm);

%% Create tissueList

j=1;
tissueList(j).name  = 'dentin';
tissueList(j).mua   = 0.04; %in cm ^ -1 
tissueList(j).mus   = 270; %range between 260-280
tissueList(j).g     = 0.93;
tissueList(j).VHC    = 1260*2.2e-3; % Volumetric Heat Capacity [J/(cm^3*K)]
tissueList(j).D     = 2.200e-3; % Density, [kg/cm^3]
tissueList(j).TC    = 6e-3; % Thermal Conductivity [W/(cm*K)]

j=2;
tissueList(j).name = 'enamel';
tissueList(j).mua   = 0.01; %in cm ^ -1 
tissueList(j).mus   = 40;
tissueList(j).g     = 0.96;
tissueList(j).VHC   = 750*2.9e-3;
tissueList(j).D     = 2.900e-3;
tissueList(j).TC    = 9e-3;

j=3;
tissueList(j).name  = 'air';
tissueList(j).mua   = 0.001;
tissueList(j).mus   = 10;
tissueList(j).g     = 1.0;
tissueList(j).VHC   = 1e8; % Real value is 1.2e-3, but this value would limit dt and is unimportant for the simulation anyway
tissueList(j).D     = 1.2e-6;
tissueList(j).TC    = 0; % Real value is 2.6e-4, but we set it to zero to neglect the heat transport to air

j=4;
tissueList(j).name  = 'water';
tissueList(j).mua   = 0.001;
tissueList(j).mus   = 10;
tissueList(j).g     = 1.0;
tissueList(j).VHC   = 4.19;
tissueList(j).D     = 1e-3;
tissueList(j).TC    = 5.8e-3;

j=5;
tissueList(j).name  = 'blood';
B       = 1.00;
S       = 0.75;
W       = 0.95;
M       = 0;
musp500 = 10;
fray    = 0.0;
bmie    = 1.0;
gg      = 0.90;
musp = musp500*(fray*(nm/500).^-4 + (1-fray)*(nm/500).^-bmie);
X = [B*S B*(1-S) W M]';
tissueList(j).mua = MU*X;
tissueList(j).mus = musp/(1-gg);
tissueList(j).g   = gg;
tissueList(j).VHC    = 3617*1050e-6;
tissueList(j).D     = 1050e-6;
tissueList(j).TC    = 0.52e-2;

j=6;
tissueList(j).name  = 'testheatconductor';
tissueList(j).mua   = 1;
tissueList(j).mus   = 1e-8;
tissueList(j).g     = 0;
tissueList(j).VHC    = pi;
tissueList(j).D     = 1;
tissueList(j).TC    = exp(1);

j=7;
tissueList(j).name  = 'testinsulator';
tissueList(j).mua   = 1e-8;
tissueList(j).mus   = 1e-8;
tissueList(j).g     = 0;
tissueList(j).VHC    = 1;
tissueList(j).D     = 1;
tissueList(j).TC    = 1e-8;

j=8;
tissueList(j).name  = 'testheatsink';
tissueList(j).mua   = 1e-8;
tissueList(j).mus   = 1e-8;
tissueList(j).g     = 0;
tissueList(j).VHC    = 1e8;
tissueList(j).D     = 1;
tissueList(j).TC    = 1;

j=9;
tissueList(j).name  = 'testscatterer';
tissueList(j).mua   = 1e-8;
tissueList(j).mus   = 1;
tissueList(j).g     = 0;
tissueList(j).VHC    = 1e-8;
tissueList(j).D     = 1;
tissueList(j).TC    = 1;

%{
fprintf('---- tissueList ------ \tmua   \tmus  \tg  \tmusp\n')
for i=1:length(tissueList)
    fprintf('%d\t%15s\t%0.4f\t%0.1f\t%0.3f\t%0.1f\n\n',...
        i,tissueList(i).name, tissueList(i).mua,tissueList(i).mus,tissueList(i).g,...
        tissueList(i).mus*(1-tissueList(i).g))
end
%}
