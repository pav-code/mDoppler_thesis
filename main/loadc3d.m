function  [Markers,VideoFrameRate,AnalogSignals,AnalogFrameRate,Event, ...
           ParameterGroup,CameraInfo,ResidualError] = loadc3d(fUser,sFile,sPath)
% wrapper script loadc3d
% fUser - if 0 then take from user, else go through the list
if fUser == 0
  [datafile,datapath] = uigetfile('./data/*.c3d', 'open C3D file', 40, 40); 
else
  datafile = sFile;
  datapath = sPath;
end
  if datafile ~= 0

      [Markers,VideoFrameRate,AnalogSignals,AnalogFrameRate,Event,ParameterGroup,CameraInfo,ResidualError]=...
          readC3D([datapath,datafile]);

end  