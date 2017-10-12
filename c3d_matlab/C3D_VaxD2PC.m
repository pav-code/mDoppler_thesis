function Reply = C3D_VaxD2PC(Mode, FileSpec)
% Convert C3Ds from "DEC" to "PC" format
% C3D is a file format commonly used for biomechanics and motion analysis.
% Floating point numbers can be stored in 3 different ways in C3D files: VAX-D,
% IEEE-LE and IEEE-BE (Vicon calls them DEC, PC and MIPS).
% Unfortunately Matlab 2008b (v7.7) does not open files in VAX-D format anymore.
% This function converts C3D files written in VAX-D to IEEE-LE files (PC style)
% and works under Matlab 6 and 7. For Matlab 6 the TYPECAST command is simulated
% by a slow FREAD+FWRITE combination.
%
% VAXD = C3D_VaxD2PC(Mode, FileSpec)
% Input:
%   Mode: String, not case sensitive. If the string contains 'file', one file is
%         processed, otherwise the input FileSpec is treated as folder name and
%         all files in this folder and all subfolders are processed. If Mode
%         contains 'convert', the files are converted. Otherwise their format is
%         checked only, but the files are not touched.
%   FileSpec: String, name of a file or a folder depending on Mode. A file name
%         can include an absolute or relative path. The file extension '.c3d' is
%         appended on demand.
% Output:
%   VAXD: In file Mode, VAXD is TRUE if the file was written in VAX-D format and
%         FALSE otherwise. If a folder is processed, VAXD is a cell string of
%         names of files in VAXD format.
%
% Backups of the VAX-D files are created as "<FileName>.c3d.vaxd" during the
% conversion. The original file is patched by changing the binary representation
% of all float32 numbers. Integers do not need a conversion and double64 numbers
% do not appear in C3D files.
% Files in IEEE-LE (PC) or IEEE-BE (MIPS) are not touched.
%
% Limitations:
% - The file interpretation is limited to the functions of fC3D5.12 written by
%   Jan Simon, Heidelberg, 26-Oct-2008: No "NER" event records, no old style
%   event records (see FileOpen). Appended blocks behind the data records are
%   not processed. Tests have been performed for C3Ds written by Vicon software
%   only. The WorkStation3.5 bug of data in [NxMx0] arrays is caught.
% - The number of frames and frame indices must not exceed 65535 frames.
% - Write permissions are needed for the C3D-file, of course.
% - Matlab 7.7 can process this function 5 times faster than Matlab 6: The older
%   COPYFILE is much slower and the TYPECAST simulation using FWRITE+FREAD
%   wastes some time also. If you need to convert 10'000 sessions under
%   Matlab 6, ask me for a faster TYPECAST and COPYFILE emulation.
%
% WARNING AND DISCLAIMER OF WARRANTY:
%   Although no error appeared during the tests of this function, touching the
%   expensive measurement files must be performed with care! Create a backup of
%   all accessed files before and check the integrity of converted files after
%   the conversion. This software is published without warranties of any kind
%   and you use it on your own risk.
%
% Example 1: Check all C3D files in the current folder and subfolders:
%   VAXDFiles = C3D_VaxD2PC('CheckFolder', cd);
%
% Example 2: Convert one file (insert a file name):
%   isVAXD = C3D_VaxD2PC('ConvertFile', <AC3DFileName>);
%
% NOTE: Some parts of the source code look awkward, because they are copied
% from well tested C3D import functions with as little changes as possible, e.g.
% FREAD without using the output.
%
% Information about the C3D format can be found at: http://www.c3d.org
% The C3D data file format was developed by Andrew Dainis in 1987.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP
% Author: Jan Simon, Heidelberg, (C) 2008-2010, matlab.THISYEAR(a)nMINUSsimon.de

% $JRev: R0g V:019 Sum:jQoG72nrQurK Date:20-Aug-2010 14:50:35 $
% $License: BSD $
% History:
% 001: 01-Nov-2008 18:11, Converting VAX-D C3Ds for Matlab 7.7.
%      Surprisingly Matlab 7.7 has no VAX-D support for FOPEN anymore.
% 013: 08-Apr-2009 15:28, Stand-alone version for the Matlab FEX.
%      Original function: fC3D_VaxD2PC.
% 019: 20-Aug-2010 14:45, Conider up to 65535 frames (32767 formerly).
%      For More than 65535 frames, the fields TRIAL:ACTUAL_START_FIELD and
%      TRIAL:ACTUAL_END_FIELD are needed from the parameter block.

% Parse inputs: ----------------------------------------------------------------
if nargin ~= 2 || (ischar(Mode) && ischar(FileSpec)) == 0
   error(['### ', mfilename, ': 2 strings needed as input.']);
end
Mode      = lower(Mode);
CheckOnly = not(any(strfind(Mode, 'convert')));
FileMode  = any(strfind(Mode, 'file'));

% Process a file or files in a folder and subfolders: --------------------------
if FileMode
   % Create absolute file name:
   [fPath, fName, fExt] = fileparts(FileSpec);
   if isempty(fPath)
      fPath = cd;
   end
   if isempty(fExt)
      fExt = '.c3d';
   end
   aFile = fullfile(fPath, [fName, fExt]);
   Reply = ProcessFile(aFile, CheckOnly);
   if Reply
      disp(['VAX-D: ', aFile]);
   end
   
else  % Process a folder and subfolders:
   % Get names of all subfolders as cell string:
   FolderList = strread(genpath(FileSpec), '%s', 'delimiter', pathsep);
   
   % Try to pre-allocate memory for the output (guess: 100 trials per session,
   % increased automatically):
   Reply  = cell(length(FolderList) * 100, 1);
   ReplyI = 0;  % Cursor

   % Loop over all folders:
   for iFolder = 1:length(FolderList)
      % Get C3D files in this folder:
      aFolder  = FolderList{iFolder};
      FileDir  = dir(fullfile(aFolder, '*.c3d'));
      FileList = {FileDir(not([FileDir.isdir])).name};
      if length(FileList)
         % Process C3D files:
         disp(['== ', aFolder]);
         for iFile = 1:length(FileList)
            aFile = fullfile(aFolder, FileList{iFile});
            try
               isVAXD = ProcessFile(aFile, CheckOnly);
               if isVAXD  % Add file to output cell string:
                  disp(['  ', FileList{iFile}]);
                  ReplyI        = ReplyI + 1;
                  Reply{ReplyI} = aFile;
               end
            catch
               disp(['### Failed: ', aFile, char(10), lasterr]);
            end
         end  % for iFile
      end  % if FileList is not empty
   end  % for iFolder
   Reply = Reply(1:ReplyI);  % Crop pre-allocated output
end  % if processing a file or a folder

return;

% ******************************************************************************
function isVAXD = ProcessFile(FileName, CheckOnly)
% Process one file.

% Get numerical format the file is written in:
NumMode = OpenFile_L(FileName);

% Early return if no conversion is wanted or needed:
isVAXD = strcmpi(NumMode, 'DEC');
if CheckOnly || ~isVAXD
   return;
end

% Create a copy at first:
% NOTE: COPYFILE is very slow under Matlab 6! The Matlab 7 implementation
% (or equivalent MEX) takes 1% of Matlab 6 time!
[Status, Msg] = copyfile(FileName, [FileName, '.vaxd']);
if Status ~= 1
   Error_L(Msg, FileName);
end

% Open the file in PC-little-endian format (IEEE-LE) to modify it:
FID = fopen(FileName, 'rb+', 'l');
if FID == -1
   Error_L('Cannot open file for writing!', FileName);
end

% Read and patch header record:
Head = Patch_Head(FID);

% Patch parameter and data records:
Patch_Param(FID, Head.ParamRec, FileName);
Patch_Data(FID, Head);

% Ready:
fclose(FID);

return;

% ******************************************************************************
function NumMode = OpenFile_L(FileName)
% Open the file and get the numerical format

RecLen      = 512;  % Record length in Byte
NumMOffset  = 83;   % Arbitrary prime? Don't ask me.
MagicC3DKey = 80;   % Test integrity of C3D format

% Open the file in PC little endian:
FID = fopen(FileName, 'rb', 'l');
if FID == -1
   Error_L('Cannot open file for reading!', FileName);
end

% Identify format type:
ParamRec = fread(FID, 1, 'int8');
MagicKey = fread(FID, 1, 'int8');
if MagicKey ~= MagicC3DKey
   % This key must be 80 (decimal) - a neat test, isn't it?
   Error_L(['Bad magic key in byte 2: ', sprintf('%d', MagicKey), ...
            ' (no C3D!?)'], FileName);
end

% Spool to parameter record:
FSeek_L(FID, (ParamRec - 1) * RecLen);

% Get the first 4 bytes - first 3 bytes not used here:
Data = fread(FID, 4, 'int8');
fclose(FID);

% Format the file is written in:
NumModeD = Data(4);
switch NumModeD - NumMOffset
   case 1   % PC, IEEE-LE
      NumMode = 'PC';
   case 2   % DEC, VAX-D
      NumMode = 'DEC';
   case 3   % MIPS, IEEE-BE
      NumMode = 'MIPS';
   otherwise
      Error_L('Unknown numerical format!', FileName);
end

return;

% ******************************************************************************
function Head = Patch_Head(FID)
% Read/modify header section of an open C3D file
% Output [Head] has fields:
%   nCoor, AnalogChunk, iFrame, fFrame, nFrame, intGap, Scale, FloatMode,
%   AnalogRate, VideoFreq, nAnalog, Event, ParamRec, DataRec.

% Initialize: ==================================================================
I8  = 'int8';
I16 = 'int16';
U16 = 'uint16';  % 20-Aug-2010: For 32767 to 65535 frames

Event = [];

% Do the work: =================================================================
% Spool to the beginning:
FSeek_L(FID, 0);

% Reading record number of parameter section:
Head.ParamRec = fread(FID, 1, I8);
MagicKey      = fread(FID, 1, I8);      %#ok<NASGU>

% Getting all the necessary parameters from the header record:
% Not needed for file conversion!
Head.nCoor       = fread(FID, 1, U16);  % number of trajectories
Head.AnalogChunk = fread(FID, 1, U16);  % analog values per video frame
Head.iFrame      = fread(FID, 1, U16);  % index of first video frame
Head.fFrame      = fread(FID, 1, U16);  % index of last video frame
Head.MaxGap      = fread(FID, 1, U16);  % max allowed interpolation gaps
Scale            = fread_F32(FID, 1);   % scale integers to ref. units
Head.DataRec     = fread(FID, 1, U16);  % 1st record of data section
Head.AnalogRate  = fread(FID, 1, U16);  % analog samples per video frame
Head.VideoFreq   = fread_F32(FID, 1);   % frequency of video data

% If scale is negative, the data is stored in float format:
Head.FloatMode = (Scale < 0);
Head.Scale     = abs(Scale);

% Number of frames:
Head.nFrame = Head.fFrame - Head.iFrame + 1;

% Number of analog channels (FRC + EMG + ?):
if Head.AnalogRate  % Avoid division by zero:
   Head.nAnalog = round(Head.AnalogChunk / Head.AnalogRate);
else
   Head.nAnalog = 0;
end

% Event inside header section: -------------------------------------------------
% NOTE: Never tested! Vicon370 supports events as a group, but there are two
% styles which save the events in an extra section in the parameter part:
FSeek_L(FID, 298);

% Word 148:
keyWord = fread(FID, 1, I16);           % '12345': new event style
if keyWord == 12345
   % New event record style "NER" not implemented.
   % See: Proposed C3D file EVENT storage enhancement
   %      Date of this DRAFT: 4/6/00
   %      Authors: Steven J. Stanhope, Ph.D., Steven_Stanhope@nih.gov
   Event.NewStyle = true;
   NewEventsRec   = fread(FID, 1, I16);  %#ok<NASGU> % Word 149: event record
else
   Event.NewStyle = false;
   dum            = fread(FID, 1, I16);  %#ok<NASGU>
end

% Old event record style: (not used by Vicon C3Ds)
% Not tested under no circumstances! This will crash!
% Word 150:
keyWord = fread(FID, 1, I16);           % '12345': old event style
if keyWord == 12345
   Event.OldStyle = true;
   nEvent         = fread(FID, 1, I16);
   Event.Num      = nEvent;
   dum            = fread(FID, 1, I16);  %#ok<NASGU>
   Event.Times    = fread_F32(FID, nEvent);
   FSeek_L(FID, 378);
   
   Event.Switch   = fread(FID, nEvent, 'int8');
   FSeek_L(FID, 399);
   for i = 1:nEvent
      Event.Label{i} = fread(FID, [1, 4], 'char=>char');
   end
else
   Event.OldStyle = false;
end
Head.Event = Event;

return;

% ******************************************************************************
function Patch_Param(FID, ParamRec, FileName)
% Read/patch C3D parameter section
% This is a fat free fC3Di_Param without storing any data.

% Initialize: ==================================================================
RecLen = 512;        % Record length in Byte

% Create format specificators for FREAD (faster to do it once):
Int8Fmt   = 'int8';
UInt8Fmt  = 'uint8';
Int16Fmt  = 'int16';
Uint16Fmt = 'uint16';
% SingleFmt = 'float32';  % Not used: This is the point!
StringFmt = 'uchar=>char';

% Do the work: =================================================================
% Spool to first Parameter record:
FSeek_L(FID, (ParamRec - 1) * RecLen);

% 4 bytes initial block, 4th is the numerical format:
fseek(FID, 3, 0);
fwrite(FID, 84, 'int8');  % Set to IEEE-LE format ("PC")
fseek(FID, 0, 0);         % Needed! See: help fopen

% Read all group and parameter information:
GPOffset = -1;                          % Dummy value for the first loop
while 1
   if GPOffset == 0                     % Stop if former Offset==0 (C3D style)
      break;
   end
   
   nNameChar = fread(FID, 1, Int8Fmt);  % Length of group/param name
   if nNameChar == 0                    % Stop: length==0 (Vicon style)
      break;                            % Break out of "WHILE 1" loop
   elseif nNameChar < 0                 % Locked parameter
      nNameChar = abs(nNameChar);
   end
   
   iG       = fread(FID, 1, Int8Fmt);   % [-]:Group, [+]: Parameter, [abs]:index
   fread(FID, nNameChar, StringFmt);    % Group/Parameter name
   GPOffset = fread(FID, 1, Uint16Fmt);
   if iG < 0                            % Group data:
      nDescChar = fread(FID, 1, UInt8Fmt);  % # of chars for description
      fread(FID, nDescChar, StringFmt);
      
   else                                 % Parameter data:
      eType = fread(FID, 1, Int8Fmt);   % Enumerator for type of variable
      nDim  = fread(FID, 1, UInt8Fmt);  % Dimensions
      Dims  = fread(FID, nDim, UInt8Fmt);
      pDims = prod(Dims);
      
      switch eType
      case -1  % String type:
         if nDim <= 2 || all(Dims)
            fread(FID, pDims, StringFmt);  % nDim=0 => PROD([]) == 1!
         else  % Multi-dimensional string (string array):
            if Dims(1) ~= 0  % Some trailing dimensions are zero:
               pDims = prod(Dims(Dims ~= 0));      % Ignore zeros
               if (4 + nDim + pDims) < GPOffset && GPOffset ~= 0
                  % Vicon WorkStation3.5 "feature": Data in [N x M x 0] arrays
                  fread(FID, pDims, StringFmt);
               end  % If data present inspite of zero dimensions
            end  % If Dims(1)==0 or other dims == 0
         end
         
      case 1  % int8:
         fread(FID, pDims, Int8Fmt);   % nDim=0 => PROD(Dims) == 1!
      case 2  % int16:
         fread(FID, pDims, Int16Fmt);  % nDim=0 => PROD(Dims) == 1!
      case 4  % float32 - the actual problem:
         fread_F32(FID, pDims);        % nDim=0 => PROD(Dims) == 1!
      otherwise
         Error_L('Bad type enum.', FileName);
      end  % If numeric or string type
      
      % Description:
      nDescChar = fread(FID, 1, UInt8Fmt);
      fread(FID, nDescChar, StringFmt);
   end  % if iG < 0
end  % while go

return;

% ******************************************************************************
function Patch_Data(FID, Head)
% Patch data section

if Head.FloatMode == 0  % No need to touch integer data!
   return;
end

% Spool to the data record:
FSeek_L(FID, (Head.DataRec - 1) * 512);

% Sizes of blocks to read:
DataLen = 4 * Head.nCoor + Head.nAnalog * Head.AnalogRate;
for iF = 1:Head.nFrame         % Loop over all video frames
   fread_F32(FID, DataLen);
end

return;

% ******************************************************************************
function X_d = fread_F32(FID, N)
% Read N numbers in single precision and DEC format, convert them to a PC float,
% overwrite the original data in the file.
% A scalar or column vector is replied.
% The function TYPECAST casts the type of a variable without changing the binary
% representation. Under Matlab 6 this is simulated by writing the data to the
% disk and read them again in a different format, because TYPECAST exists in
% Matlab >= 7.1 only.

if N == 0
   return;
end

Pos  = ftell(FID);
X_u8 = fread(FID, [2, N], '*uint16');
X_u8 = X_u8([2, 1], :);  % Swap bytes: [1,2,3,4] -> [3,4,1,2]

if sscanf(version, '%f', 1) >= 7.1  % Or > ?!  Works for Matlab v7.10 also!
   X_d = double(typecast(X_u8(:), 'single')) / 4;
   
else  % Fallback for Matlab 6 - simulate TYPECAST:
   % This slows down the function by just 10%.
   FSeek_L(FID, Pos);
   fwrite(FID, X_u8, 'uint16');         % Overwrite
   FSeek_L(FID, Pos);
   X_d = fread(FID, N, 'float32') / 4;  % Replies a DOUBLE
end

FSeek_L(FID, Pos);
fwrite(FID, X_d, 'float32');  % Overwrite
fseek(FID, 0, 0);             % Needed! See: help fopen

return;

% ******************************************************************************
function Error_L(Msg, FileName)
% Simple local error handler
FuncName = mfilename;
error(['*** ', FuncName, ': ', Msg, char(10), '    File: ', FileName]);

return;  %#ok<UNRCH>

% ******************************************************************************
function FSeek_L(FID, Pos)
% Under critical load the operating system can stop FSEEK caused by a thread
% switch. This is not nice, but there are any good reasons. This function tries
% 10 times to fulfill the task and stops with an error on failure. Unfortunately
% these errors are not reproducible in principle.

for dull = 1:10
   if fseek(FID, Pos, -1) == 0
      return;
   end
end

% Really unlikely, that it failed 10 times...
Error_L('FSEEK failed - heavy system load?! Try it again.', fopen(FID));

return;
