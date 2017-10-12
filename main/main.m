% main:	Backbone of the program 

clear all;
close all;

sEq1 = 'false';   % Boolean for turing on/off equation
sGraph = 'true'; % Graphs boolean
sSTFT = 'true';   % STFT toggle
sMW = 'true';     % Morlet Wavelet toggle
sWV = 'true';     % Wigner-Ville toggle

%% Data Loading
sPath = './data/walk/';
sFile = dir(strcat(sPath,'*.c3d'));
bUser = 1; % User selection: Doesn't work with output. 0 for User, 1 for Auto
addpath('./../tfr_pkg/mfiles');
addpath('./../c3d_matlab')

% Magic Constants
MagicNumber = 1.85;
iFrameRate = 120;
iInterFactor = 80;
iMoUpsamp = iFrameRate*iInterFactor;
iSizeX = 110;
iSizeY = 146;
vPts = [5 31 38 13 16 19 ]; % Good Sensors
deltaT = 1/(iInterFactor*iFrameRate);
sAppend = 'W_'; % naming convention for file type (run, walk, ...)
vTimer = []; % Timing array
iTimeCnt = 1;

% Radar Constants
fc = 77e9;
c0 = 2.99e8;
G = 6;                    % Antenna Gain
Pt = 0.01;                % Transmit Power
sigmaN = 1;               % Noise Standard Deviation
sigma = [2 2 1 1 1 1 1];    % Target RCS
La = 1;                   % Atmospheric loss
Ls = 1;                   % System Losses
lambda = c0/fc;           % Transmited Wavelength
Tsys = 290;               % System Temperature
BW = 850e6;               % Bandwidth
tau = 5e-3;               % Pulse Width

for iFileCount=1:size(sFile,1)
[Markers,VideoFrameRate,AnalogSignals,AnalogFrameRate,Event, ...
           ParameterGroup,CameraInfo,ResidualError] = ...
           loadc3d(bUser,sFile(iFileCount).name,sPath);

%% Constants and Coordinate System 
clear vRm;clear td;clear vV; clear vfD; clear aAmp;
iNumPts = iInterFactor * size(Markers,1)

% Graph dataset
if strcmp(sGraph,'true') 
 a = Markers(:,vPts,1:2:3);
 figure
 for i =1:length(vPts)
  plot(a(:,i,1)/1000,a(:,i,2)/1000)
  hold on;
  ylim([0 1.8])
 end
 title('Sensor Positions YZ')
 xlabel('y distance [m]')
 ylabel('z distance [m]')
else
end

aHuman = fInterp(Markers,iNumPts);

aHuman(:,:,1) = aHuman(:,:,1) - repmat(abs(aHuman(1,:,1)-40000),iNumPts,1);

index = 1;
for i = 1:length(vPts)
  [phi,theta,r] = cart2sph(aHuman(:,vPts(i),1),aHuman(:,vPts(i),2),...
                           aHuman(:,vPts(i),3));
  vRm(:,index) = r/1000; 
  td(:,i) = (2/c0)*vRm(:,i);
  vV(:,index) = diff(r/1000)/(deltaT); %velocity calculation
  vfD(:,index) = 2*vV(:,index)*fc/c0;
  index=index+1;
end

if strcmp(sGraph,'true') 
  t = 1:length(vfD);  
  figure
  for i = 1:length(vPts)
    plot(t/(iInterFactor*iFrameRate),-vfD(:,i))
    hold on;
  end
  title('Doppler frequency vs time: sensors')
  xlabel('Time [s]')
  ylabel('Frequency [Hz]')
end

for i =1:length(vPts)
  aAmp(:,i) =  (G*lambda*sqrt(Pt*sigma(i))*sigmaN)./(((4*pi)^1.5)*...
      (vRm(:,i)).^2*sqrt(Ls*La*Tsys));    
end

%% Generate radar response
xpSTFT = zeros(1,size(aAmp,1))';

xpWv = zeros(1,size(aAmp,1))';
for i = 1:length(vPts)
  xpSTFT = xpSTFT + aAmp(:,i)*tau.*exp(-1j*4*pi*(fc)*vRm(:,i)/c0);
  %xpWave = xpWave + aAmp(:,i)*tau.*exp(-1j*4*pi*fc*vRm(:,i)/c0);
  xpWv = xpWv + aAmp(:,i)*tau.*exp(-1j*4*pi*(fc/MagicNumber)*vRm(:,i)/c0); 
end

if strcmp(sGraph,'true') 
  figure
  plot(abs(xpSTFT))
  hold on;
  plot(detrend(abs(xpSTFT)))
  title('xpSTFT vs detranded xpSTFT')
end

aRadSignal = detrend(xpSTFT);
aWVSignal = detrend(xpWv);
%% STFT
% STFT image calculations
if strcmp(sSTFT,'true')
  Nstft = 512;                          % Number of frequency bins
  h = tftb_window(71,'Dolph');          % Window length and type  
  iCounter = 1;  
  dTimer = 0;
  for i = 1:iMoUpsamp:length(aRadSignal)     
    if i+iMoUpsamp > length(aRadSignal)
        break
    end
    aSTFT_slice = aRadSignal(i:i+iMoUpsamp);
    aFD_slice = vfD(i:i+iMoUpsamp,:);
    t = (1:size(aSTFT_slice,1));
    figure   
    tic; % Timing
    [~,~,~,oImg] = tfrsp(aSTFT_slice,t,Nstft,h,0);
    dTimer = dTimer + toc;
    
    % Spaghetti Supreme
    sName = sFile(iFileCount).name;
    sName = sName(1:end-4);
    axis off  
    saveas(oImg,'temp','png');
    RemoveWhiteSpace([], 'file', 'temp.png', 'output', 'temp_out.png');
    aTempImg = imread('temp_out.png');
    aFinalImg = imresize(aTempImg, [iSizeX iSizeY]);
    imwrite(aFinalImg, strcat('./output/stft/polychrome/', sAppend,'STFT_',sName,'_',int2str(iCounter),'.png'));        
    imwrite(rgb2gray(aFinalImg), strcat('./output/stft/monochrome/', sAppend, 'STFT_',sName,'_',int2str(iCounter),'.png'));  
    delete ('temp_out.png','temp.png');    
    
    % Saving vector for R
    save(strcat('./output/signal/', sAppend, 'Signal_',sName,'_',int2str(iCounter),'.mat'),'aSTFT_slice');
    
    iCounter = iCounter + 1;
  end
  vTimer(1,iTimeCnt) = dTimer/(iCounter-1); % Average time
end
%% Morlet Wavelet
if strcmp(sMW,'true')
 fmin = 0.001; fmax = 0.4999;  
 Nwavelet = 128;
 iCounter = 1;
 dTimer = 1; 
 vLevel = [11 28];

for i = 1:iMoUpsamp:length(aRadSignal)     
  if i+iMoUpsamp > length(aRadSignal)
      break
  end
  aSTFT_slice = aRadSignal(i:i+iMoUpsamp);
  t = (1:size(aSTFT_slice,1));
    for j = 1:2
      figure
      tic; % Flop Timer
      [~,~,~,~,oImg] = tfrscalo(aSTFT_slice,t,vLevel(j),fmin,fmax,Nwavelet);
      dTimer = dTimer + toc;
      
      % Spaghetti Supreme
      sName = sFile(iFileCount).name;
      sName = sName(1:end-4);
      axis off
      title ''
      saveas(oImg,'temp','png');
      RemoveWhiteSpace([], 'file', 'temp.png', 'output', 'temp_out.png');
      aTempImg = imread('temp_out.png');
      aFinalImg = imresize(aTempImg, [iSizeX iSizeY]);
      imwrite(aFinalImg, strcat('tempMW_', int2str(j) ,'.png'));
      delete ('temp_out.png','temp.png');
    end
    aTemp1 = imread('tempMW_1.png'); 
    aTemp2 = imread('tempMW_2.png');
    aTemp2(end-20:end,:,:) = aTemp1(end-20:end,:,:);
    imwrite(aTemp2, strcat('./output/mw/polychrome/', sAppend, 'MW_',sName,'_',int2str(iCounter),'.png'));
    imwrite(rgb2gray(aFinalImg), strcat('./output/mw/monochrome/', sAppend, 'MW_',sName,'_',int2str(iCounter),'.png'));  
    delete(strcat('tempMW_1.png'),strcat('tempMW_2.png'));
    clear aTemp1; clear aTemp2;
    
    iCounter = iCounter + 1;
  end
  vTimer(2,iTimeCnt) = dTimer/((iCounter-1)*2); % Average time, MW has a factor of 2 
end
%% Smoothed Pseudo Wigner-Ville
if strcmp(sWV,'true')
  gWv = tftb_window(61,'dolph');
  fWv = tftb_window(71,'dolph');
  NWv = 512;
  iCounter = 1;
  dTimer = 1; 
  
  for i = 1:iMoUpsamp:length(aWVSignal)     
    if i+iMoUpsamp > length(aWVSignal)
        break
    end
    aWV_slice = aWVSignal(i:i+iMoUpsamp);
    t = (1:size(aWV_slice,1));
    figure
    
    tic; % Timer
    [~,~,~,oImg] = tfrspwv(aWV_slice,t,NWv,gWv,fWv);
    dTimer = dTimer + toc;
    
    % Spaghetti Supreme
    sName = sFile(iFileCount).name;
    sName = sName(1:end-4);
    axis off
    title ''
    saveas(oImg,'temp','png');
    RemoveWhiteSpace([], 'file', 'temp.png', 'output', 'temp_out.png');
    aTempImg = imread('temp_out.png');
    aFinalImg = imresize(aTempImg, [iSizeX iSizeY]);
    imwrite(aFinalImg, strcat('./output/wv/polychrome/', sAppend, 'WV_',sName,'_',int2str(iCounter),'.png'));
    imwrite(rgb2gray(aFinalImg), strcat('./output/wv/monochrome/', sAppend, 'WV_',sName,'_',int2str(iCounter),'.png'));  
    delete ('temp_out.png','temp.png');
    
    iCounter = iCounter + 1;
  end
  vTimer(3,iTimeCnt) = dTimer/(iCounter-1); % Average time   
end

iTimeCnt = iTimeCnt + 1;
close all
end

save('timings.mat','vTimer');

%% Cleanse Folders: this section clears all folders where images have been saved to

% delete('./output/wv/polychrome/*','./output/wv/monochrome/*', ...
%    './output/stft/polychrome/*','./output/stft/monochrome/*', ...
%    './output/mw/polychrome/*','./output/mw/monochrome/*', ...
%    './output/signal/*', './output/svm/*');


