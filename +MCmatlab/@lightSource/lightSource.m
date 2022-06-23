classdef lightSource
  %BEAM This class includes all properties and methods
  %related to a beam in an MCmatlab.model.monteCarloSimulation.

  % Rename to lightSource
  % use focalPlaneIntensityDistribution
  % use angularIntensityDistribution

  properties
    %% Input properties
    sourceType (1,1) double {mustBeInteger, mustBeInRange(sourceType,0,5)} = 0 % 0: Pencil beam, 1: Isotropically emitting line or point source, 2: Infinite plane wave, 3: Laguerre-Gaussian LG01 beam, 4: Radial-factorizable beam (e.g., a Gaussian beam), 5: X/Y factorizable beam (e.g., a rectangular LED emitter)

    xFocus (1,1) double {mustBeFinite} = 0
    yFocus (1,1) double {mustBeFinite} = 0
    zFocus (1,1) double {mustBeFinite} = 0

    theta (1,1) double {mustBeFinite} = 0 % [rad] Polar angle of beam center axis
    phi (1,1) double {mustBeFinite} = 0 % [rad] Azimuthal angle of beam center axis
    psi (1,1) double {mustBeFinite} = 0 % [rad] Axial rotation angle of beam, relevant only for XY distributed beams

    emitterLength (1,1) double {mustBeNonnegative} = 0                       % [cm] Length of isotropic emitter (line or point)

    focalPlaneIntensityDistribution (1,1) MCmatlab.sourceIntensityDistribution
    angularIntensityDistribution (1,1) MCmatlab.sourceIntensityDistribution

    %% Calculated properties
    sourceDistribution = NaN
  end

  properties (Hidden)
    beamType
    NF
    FF
  end

  methods
    function x = get.beamType(obj)
      warning('beamType has been renamed sourceType. The ability to reference sourceType through beamType will be deprecated in a future version.');
      x = obj.sourceType;
    end
    function obj = set.beamType(obj,x)
      warning('beamType has been renamed sourceType. The ability to reference sourceType through beamType will be deprecated in a future version.');
      obj.sourceType = x; %#ok<MCSUP> 
    end
    function x = get.NF(obj)
      warning('NF has been renamed focalPlaneIntensityDistribution. The ability to reference focalPlaneIntensityDistribution through NF will be deprecated in a future version.');
      x = obj.focalPlaneIntensityDistribution;
    end
    function obj = set.NF(obj,x)
      warning('NF has been renamed focalPlaneIntensityDistribution. The ability to reference focalPlaneIntensityDistribution through NF will be deprecated in a future version.');
      obj.focalPlaneIntensityDistribution = x; %#ok<MCSUP> 
    end
    function x = get.FF(obj)
      warning('FF has been renamed angularIntensityDistribution. The ability to reference angularIntensityDistribution through FF will be deprecated in a future version.');
      x = obj.angularIntensityDistribution;
    end
    function obj = set.FF(obj,x)
      warning('FF has been renamed angularIntensityDistribution. The ability to reference angularIntensityDistribution through FF will be deprecated in a future version.');
      obj.angularIntensityDistribution = x; %#ok<MCSUP> 
    end
  end
end
