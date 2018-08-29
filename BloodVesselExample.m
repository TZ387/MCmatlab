addpath('./helperfuncs'); % Enables running each section individually for the rest of the MATLAB session using the "Run Section" button or ctrl+enter

%% Geometry definition
clear Ginput
Ginput.silentMode = true;
Ginput.assumeMatchedInterfaces = true;
Ginput.boundaryType = 1;

Ginput.wavelength  = 532;		% [nm] Wavelength of the Monte Carlo simulation

Ginput.nx = 100;				% number of bins in the x direction
Ginput.ny = 100;				% number of bins in the y direction
Ginput.nz = 100;				% number of bins in the z direction
Ginput.Lx = .1;				% [cm] x size of simulation area
Ginput.Ly = .1;				% [cm] y size of simulation area
Ginput.Lz = .1;				% [cm] z size of simulation area

Ginput.GeomFunc = @GeometryDefinition_BloodVessel; % Specify which function (defined at the end of this m file) to use for defining the distribution of media in the cuboid

% Execution, do not modify the next line:
Goutput = defineGeometry(Ginput);

%% Monte Carlo simulation
clear MCinput
MCinput.silentMode = true;
MCinput.useAllCPUs = true;
MCinput.simulationTime = .1;      % [min] time duration of the simulation

MCinput.Beam.beamType = 6;
MCinput.Beam.xFocus = 0;                % [cm] x position of focus
MCinput.Beam.yFocus = 0;                % [cm] y position of focus
MCinput.Beam.zFocus = Ginput.Lz/2;      % [cm] z position of focus
MCinput.Beam.theta = 0; % [rad]
MCinput.Beam.phi   = 0; % [rad]
MCinput.Beam.waist = 0.03;                  % [cm] focus waist 1/e^2 radius
MCinput.Beam.divergence = 0/180*pi;         % [rad] divergence 1/e^2 half-angle of beam (for a diffraction limited Gaussian beam, this is G.wavelength*1e-9/(pi*MCinput.Beam.waist*1e-2))

% Execution, do not modify the next two lines:
MCinput.G = Goutput;
MCoutput = runMonteCarlo(MCinput);

%% Heat simulation
HSinput.silentMode = false;
HSinput.useAllCPUs = true;
HSinput.makemovie  = true; % Requires silentMode = false.

HSinput.heatBoundaryType = 0; % 0: Insulating boundaries, 1: Constant-temperature boundaries (heat-sinked)
HSinput.P                = 4; % [W] Incident pulse peak power (in case of infinite plane waves, only the power incident upon the cuboid's top surface)
HSinput.durationOn       = 0.001; % [s] Pulse on-duration
HSinput.durationOff      = 0.004; % [s] Pulse off-duration
HSinput.durationEnd      = 0.02; % [s] Non-illuminated relaxation time to add to the end of the simulation to let temperature diffuse after the pulse train
HSinput.initialTemp      = 37; % [deg C] Initial temperature

HSinput.nPulses          = 5; % Number of consecutive pulses, each with an illumination phase and a diffusion phase. If simulating only illumination or only diffusion, use n_pulses = 1.

HSinput.plotTempLimits   = [37 100]; % [deg C], the expected range of temperatures, used only for setting the color scale in the plot
HSinput.nUpdates         = 100; % Number of times data is extracted for plots during each pulse. A minimum of 1 update is performed in each phase (2 for each pulse consisting of an illumination phase and a diffusion phase)
HSinput.slicePositions   = [.5 0.6 1];
HSinput.tempSensorPositions = [0 0 0.038
                              0 0 0.04
                              0 0 0.042
                              0 0 0.044];

% Execution, do not modify the next three lines:
HSinput.G = Goutput;
HSinput.MCoutput = MCoutput;
HSoutput = simulateHeatDistribution(HSinput);

%% Post-processing

%% Explanations
% silentMode = true disables overwrite prompt,
% command window text, progress indication and plot generation

% If assumeMatchedInterfaces = true, all refractive indices
% are assumed to be 1 and there is no Fresnel reflection or refraction.
% Otherwise, refractive indices from getMediaProperties are used. Note that
% non-matched interfaces must be normal to the z axis, so each xy-slice
% must have a constant refractive index. 

% Boundary type
% 0: No boundaries. Photons are allowed to leave the cuboid and are still
%    tracked outside, including absorption and scattering events. They get
%    terminated only if they wander too far (6 times the cuboid size).
% 1: Cuboid boundaries. All 6 cuboid surfaces are considered photon boundaries.
% 2: Top boundary only. Only the top surface (z = 0) is a photon boundary.
% Regardless of the boundary type, photons that wander 6 times the cuboid
% size will be terminated. When a photon hits a photon boundary at a position
% where the refractive index is 1, it escapes and may contribute to the
% signal of the light collector depending on its trajectory. Otherwise, the
% photon is just terminated, meaning that it cannot contribute to the light
% collector.

% If useAllCPUs = true, MCmatlab will use all available processors on Windows. Otherwise,
% one will be left unused. Useful for doing other work on the PC
% while simulations are running.

% Beam type
% 0: Pencil beam
% 1: Isotropically emitting point source
% 2: Infinite plane wave
% 3: Gaussian focus, Gaussian far field beam
% 4: Gaussian focus, top-hat far field beam
% 5: Top-hat focus, Gaussian far field beam
% 6: Top-hat focus, top-hat far field beam
% 7: Laguerre-Gaussian LG01 beam

% xFocus, yFocus, zFocus: Position of focus in the absence of any refraction, only used for beamType ~=2 (if beamType == 1 this is the source position)

% theta and phi define the direction of beam center axis, only used if beamtypeflag ~= 1:
% Given in terms of the spherical coordinates theta and phi measured in radians, using the ISO
% convention illustrated at https://en.wikipedia.org/wiki/Spherical_coordinate_system
% Keep in mind that the z-axis in the volumetric plots is shown pointing down, so you want to satisfy 0<=theta<pi/2.
% Examples: theta = 0, phi = 0 means a beam going straight down (positive z direction)
%           theta = pi/4, phi = 0 means a beam going halfway between the positive x and positive z directions.
%           theta = pi/4, phi = -pi/2 means a beam going halfway between the negative y and positive z directions

% For the thermal simulations, slicePositions sets the starting relative slice positions [x y z] for the 3D plots on a
% scale from 0 to 1. Especially relevant for movie generation. As an
% example, [0 1 0.5] puts slices at the lowest x value, the highest y value
% and the halfway z value.

% tempSensorPositions is a matrix where each row shows
% a temperature sensor's absolute [x y z] coordinates. Leave the matrix
% empty ([]) to disable temperature sensors.

function M = GeometryDefinition_BloodVessel(X,Y,Z,parameters)
% Blood vessel example:
zsurf = 0.01;
epd_thick = 0.006;
vesselradius  = 0.0100;
vesseldepth = 0.04;
M = 2*ones(size(X)); % fill background with water (gel)
M(Z > zsurf) = 4; % epidermis
M(Z > zsurf + epd_thick) = 5; % dermis
M(X.^2 + (Z - (zsurf + vesseldepth)).^2 < vesselradius^2) = 6; % blood
end
