function MCinput = checkMCinputFields(MCinput)
if ~isfield(MCinput,'wavelength')
  error('Error: No wavelength defined');
end
if ~isfield(MCinput,'matchedInterfaces')
  MCinput.matchedInterfaces = true;
end
if ~isfield(MCinput,'silentMode')
  MCinput.silentMode = false;
end
if ~isfield(MCinput,'useAllCPUs')
  MCinput.useAllCPUs = false;
end
if ~isfield(MCinput,'calcF')
  MCinput.calcF = true;
end
if ~isfield(MCinput,'calcFdet')
  MCinput.calcFdet = false;
end
if ~isfield(MCinput,'nExamplePaths')
  MCinput.nExamplePaths = 0;
end
if ~isfield(MCinput,'farfieldRes')
  MCinput.farfieldRes = 0;
end

if isfield(MCinput,'LightCollector')
  %% Check to ensure that the light collector is not inside the cuboid and set res to 1 if using fiber
  MCinput.useLightCollector = true;
  if MCinput.boundaryType == 0
    error('Error: If boundaryType == 0, no photons can escape to be registered on the light collector. Disable light collector or change boundaryType.');
  end
  if isfinite(MCinput.LightCollector.f)
    xLCC = MCinput.LightCollector.x - MCinput.LightCollector.f*sin(MCinput.LightCollector.theta)*cos(MCinput.LightCollector.phi); % x position of Light Collector Center
    yLCC = MCinput.LightCollector.y - MCinput.LightCollector.f*sin(MCinput.LightCollector.theta)*sin(MCinput.LightCollector.phi); % y position
    zLCC = MCinput.LightCollector.z - MCinput.LightCollector.f*cos(MCinput.LightCollector.theta);                                 % z position
  else
    xLCC = MCinput.LightCollector.x;
    yLCC = MCinput.LightCollector.y;
    zLCC = MCinput.LightCollector.z;
    if MCinput.LightCollector.res ~= 1
      error('Error: LightCollector.res must be 1 when LightCollector.f is Inf');
    end
  end

  if (abs(xLCC)               < G.nx*G.dx/2 && ...
      abs(yLCC)               < G.ny*G.dy/2 && ...
      abs(zLCC - G.nz*G.dz/2) < G.nz*G.dz/2)
    error('Error: Light collector center (%.4f,%.4f,%.4f) is inside cuboid',xLCC,yLCC,zLCC);
  end

  %% If no time tagging bins are defined, assume no time tagging is to be performed
  if ~isfield(MCinput.LightCollector,'nTimeBins')
    MCinput.LightCollector.tStart = 0;
    MCinput.LightCollector.tEnd = 0;
    MCinput.LightCollector.nTimeBins = 0;
  end
else
  %% Assume no light collector is present
  MCinput.useLightCollector = false;
  MCinput.LightCollector.x = 0;
  MCinput.LightCollector.y = 0;
  MCinput.LightCollector.z = 0;
  MCinput.LightCollector.theta = 0;
  MCinput.LightCollector.phi = 0;
  MCinput.LightCollector.f = 0;
  MCinput.LightCollector.diam = 0;
  MCinput.LightCollector.FieldSize = 0;
  MCinput.LightCollector.NA = 0;
  MCinput.LightCollector.res = 0;
  MCinput.LightCollector.tStart = 0;
  MCinput.LightCollector.tEnd = 0;
  MCinput.LightCollector.nTimeBins = 0;
end

if xor(isfield(MCinput.Beam,'nearFieldType'), isfield(MCinput.Beam,'farFieldType'))
  error('Error: nearFieldType and farFieldType must either both be specified, or neither');
end
if isfield(MCinput,'simulationTime') && isfield(MCinput,'nPhotons')
  error('Error: simulationTime and nPhotons may not both be specified');
end
if isfield(MCinput.Beam,'nearFieldType') && isfield(MCinput.Beam,'beamType')
  error('Error: nearFieldType and beamType may not both be specified');
end
if ~MCinput.calcF && ~MCinput.useLightCollector
  error('Error: calcF is false, but no light collector is defined');
end
if MCinput.calcFdet && ~MCinput.useLightCollector
  error('Error: calcFdet is true, but no light collector is defined');
end
if MCinput.farfieldRes && MCinput.boundaryType == 0
  error('Error: If boundaryType == 0, no photons can escape to be registered in the far field. Set farfieldRes to zero or change boundaryType.');
end

if isfield(MCinput.Beam,'nearFieldType')
  MCinput.Beam.beamType = -1;
else
  MCinput.Beam.nearFieldType = -1;
  MCinput.Beam.farFieldType = -1;
end
end