% script loadc3d

[datafile,datapath] = uigetfile('*.c3d', 'open C3D file', 40, 40);
  if datafile ~= 0
      [Markers,VideoFrameRate,AnalogSignals,AnalogFrameRate,Event,ParameterGroup,CameraInfo,ResidualError]=...
          readC3d([datapath,datafile]);
  end
  
  