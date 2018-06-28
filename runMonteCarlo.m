function runMonteCarlo(name)
%
%   Prepares the illumination beam and runs the Monte Carlo simulation.
%   After finishing, calls lookmcxyz for the display of the result.
%
%   Define the time requested for simulating photons.
%   Define the behaviour of photons that stray outside the tissue cuboid:
%       0 = no boundaries: photons wander freely also outside the tissue
%       cuboid and get killed only if they wander too far (6 times the cuboid
%       size).
%       1 = escape at boundaries: photons that stray outside the tissue
%       cuboid get killed immediately.
%       2 = escape at surface only: photons that hit the top surface get
%       killed immediately, photons hitting other surfaces can wander up to
%       6 times the cuboid size.
%   Define the beam parameters. The following beam types can be requested:
%       0 = top-hat focus, top-hat far field beam
%       1 = Gaussian focus, Gaussian far field beam
%       2 = isotropically emitting point
%       3 = infinite plane wave
%       4 = pencil beam
%       5 = top-hat focus, Gaussian far field beam
%       6 = Gaussian focus, top-hat far field beam
%       7 = Laguerre-Gaussian LG01 focus, LG01 far field beam
%   Depending on the chosen beam type, define the focus position, the beam
%   waist of the focus, the divergence angle and/or the direction of the
%   beam's center axis.
%
%   Input
%       name
%           the basename of the file as specified in makeTissue.m
%
%   Output
%       ./Data/[name]_MCoutput.mat
%           file containing the 3D fluence rate distribution
%
%   Requires
%       deleteDataFiles.m
%       mcxyz.mex (architecture specific)
%       lookmcxyz.m
%

%% Updates
%   2014-01: Mathias Christensen & Rasmus L. Pedersen, DTU Fotonik
%   2017-06: Anders K. Hansen & Dominik Marti, DTU Fotonik
%   2018-04: Anders K. Hansen

%% Check for preexisting files
if(~deleteDataFiles(name)); return; end

%% Load data from makeTissue.m
load(['./Data/' name '.mat']);

%% Define parameters (user-specified)
% Simulation duration
MCinput.simulationTime = 0.1;      % [min] time duration of the simulation

% Boundary type
% 0 = no boundaries
% 1 = escape at boundaries
% 2 = escape at surface only. No x, y, bottom z boundaries
MCinput.boundaryFlag = 1;

% Beam type
% 0 = top-hat focus, top-hat far field beam
% 1 = Gaussian focus, Gaussian far field beam
% 2 = isotropically emitting point
% 3 = infinite plane wave
% 4 = pencil beam
% 5 = top-hat focus, Gaussian far field beam
% 6 = Gaussian focus, top-hat far field beam
% 7 = Laguerre-Gaussian LG01 focus, LG01 far field beam
MCinput.beamtypeFlag = 0;

% Position of focus, only used for beamtypeFlag ~=3 (if beamtypeFlag == 2 this is the source position)
MCinput.xFocus = 0;                % [cm] x position of focus
MCinput.yFocus = 0;                % [cm] y position of focus
MCinput.zFocus = 0;          % [cm] z position of focus

% Direction of beam center axis, only used if beamtypeflag ~= 2:
MCinput.ux0 = 0;                   % trajectory unit vector x composant
MCinput.uy0 = 0;                   % trajectory unit vector y composant
MCinput.uz0 = sqrt(1-MCinput.ux0^2-MCinput.uy0^2); % % trajectory unit vector z composant. Make sure that ux0^2 + uy0^2 + uz0^2 = 1.

% Focus properties and divergence angles, only used if beamtypeflag == 0, 1, 5, 6 or 7
MCinput.waist = 0.03;             % [cm] focus waist 1/e^2 radius
% MCinput.divergence = wavelength*1e-9/(pi*MCinput.waist*1e-2); % [rad] Diffraction limited divergence angle for Gaussian beam
MCinput.divergence = 0/180*pi;         % [rad] divergence 1/e^2 half-angle of beam

%% Determine remaining parameters
% Voxel sizes
MCinput.dx = x(2)-x(1);            % [cm] voxel size in x direction
MCinput.dy = y(2)-y(1);            % [cm] voxel size in y direction
MCinput.dz = z(2)-z(1);            % [cm] voxel size in z direction

% Tissue definition
MCinput.tissueList = tissueList;
MCinput.T = T-1; % The tissue matrix has to be converted from MATLAB's 1-based indexing to C's 0-based indexing
clear T

%% Call Monte Carlo C script (mex file) to get fluence rate (intensity) distribution
F = mcxyz(MCinput);

%% Save output and clear memory
save(['./Data/' name '_MCoutput.mat'],'F','MCinput');
fprintf('./Data/%s_MCoutput.mat saved\n',name);
clear F MCinput

%% Make plots
lookmcxyz(name);

end
