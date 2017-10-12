function saveC3D(Markers, InputParameterGroup, filename)
%SAVEC3D - Save markers (ver2)
%
% Markers - position of markers. The orders should be [x1, x2, ... y1, y2.... z1, z2..; ...]
% InputParameterGroup - reference parameters, you can leave it as [] 
% filename - output filename(.c3d)
%
% Example usage 1 - not using reference parameter
% saveC3D(vrigid, [], 'test.c3d'); 
%
% Example usage 2 - using reference parameter
% saveC3D(vrigid, ParameterGroup, filename );
%
% Q Youn Hong, 2010/11/08

[ParameterGroup, byteCount] = setC3DParameter( Markers, InputParameterGroup );
writeC3D( filename, Markers, ParameterGroup, byteCount );

end

function [ParameterGroup, byteCount] = setC3DParameter(Markers, InputParameterGroup)
%setC3DParameter - save group information and parameter information 
%if InputParameterGroup is used, labeling parameters will be searched
%InputParameterGroup
%
%datatype - -1(char), 1(bool), 2(int), 4(real)
%if dim is [], data is scalar, otherwise follows the dimension in dim
%
%dependency - find_c3d_parameter.m
%
%Reference - www.c3d.org
%

Nframes = size(Markers,1); 
Nmarkers = size(Markers,2);

%set parameters
%group 1 TRIAL
ParameterGroup(1).name = 'TRIAL';
ParameterGroup(1).description = '';
%group 1, start frame
ParameterGroup(1).Parameter(1).name = 'ACTUAL_START_FIELD';
ParameterGroup(1).Parameter(1).datatype = 2;
ParameterGroup(1).Parameter(1).dim = 2;
ParameterGroup(1).Parameter(1).data = [1;0];
%group 1, end frame
ParameterGroup(1).Parameter(2).name = 'ACTUAL_END_FIELD';
ParameterGroup(1).Parameter(2).datatype = 2;
ParameterGroup(1).Parameter(2).dim = 2;
ParameterGroup(1).Parameter(2).data = [Nframes;0];
%group 1, camera rate
%by default, 120Hz. also can be imported from InpurParameter
ParameterGroup(1).Parameter(3).name = 'CAMERA_RATE';
ParameterGroup(1).Parameter(3).datatype = 4;
ParameterGroup(1).Parameter(3).dim = [];
[Pvalue, Pdim, found] = find_c3d_parameter( InputParameterGroup, 'TRIAL', 'CAMERA_RATE');
if found==1
    ParameterGroup(1).Parameter(3).data = Pvalue;
else
    ParameterGroup(1).Parameter(3).data = 120.0;
end
%group 1, delay between successive sample frames. normally 1(sampled every frame)
ParameterGroup(1).Parameter(4).name = 'VIDEO_RATE_DIVIDER';
ParameterGroup(1).Parameter(4).datatype = 2;
ParameterGroup(1).Parameter(4).dim = [];
ParameterGroup(1).Parameter(4).data = 1;

%group 2 SUBJECTS 
ParameterGroup(2).name = 'SUBJECTS';
ParameterGroup(2).description = '';
%group 2, 1 if the trial subjects were captured in the static pose
ParameterGroup(2).Parameter(1).name = 'IS_STATIC';
ParameterGroup(2).Parameter(1).datatype = 2;
ParameterGroup(2).Parameter(1).dim = [];
ParameterGroup(2).Parameter(1).data = 0;
%group 2, 1 if the trial subjects are identified by prefixing the subject
%name to the point label
ParameterGroup(2).Parameter(2).name = 'USES_PREFIXES';
ParameterGroup(2).Parameter(2).datatype = 2;
ParameterGroup(2).Parameter(2).dim = [];
[Pvalue, Pdim, found] = find_c3d_parameter( InputParameterGroup, 'SUBJECTS', 'USES_PREFIXES');
if found==1
    ParameterGroup(2).Parameter(2).data = Pvalue;
else
    ParameterGroup(2).Parameter(2).data = 1;
end
%group 2,N subject names of length L(?), usually remains empty
ParameterGroup(2).Parameter(3).name = 'NAMES';
ParameterGroup(2).Parameter(3).datatype = -1;
[Pvalue, Pdim, found] = find_c3d_parameter( InputParameterGroup, 'SUBJECTS', 'NAMES');
if found==1
    ParameterGroup(2).Parameter(3).dim = Pdim;
    ParameterGroup(2).Parameter(3).data = Pvalue;
else
    ParameterGroup(2).Parameter(3).dim = [32 0];
    ParameterGroup(2).Parameter(3).data = [];
end
%group 2, prefixes attached to the trajectory labels
ParameterGroup(2).Parameter(4).name = 'LABEL_PREFIXES';
ParameterGroup(2).Parameter(4).datatype = -1;
[Pvalue, Pdim, found] = find_c3d_parameter( InputParameterGroup, 'SUBJECTS', 'LABEL_PREFIXES');
if found==1
    ParameterGroup(2).Parameter(4).dim = Pdim;
    ParameterGroup(2).Parameter(4).data = Pvalue;
else
    ParameterGroup(2).Parameter(4).dim = [32 0];
    ParameterGroup(2).Parameter(4).data = [];
end
%group 2, the number of named subjects in the trial, 0 if specific subjects
%were not used
ParameterGroup(2).Parameter(5).name = 'USED';
ParameterGroup(2).Parameter(5).datatype = 2;
ParameterGroup(2).Parameter(5).dim = [];
ParameterGroup(2).Parameter(5).data = ParameterGroup(2).Parameter(3).dim(1,2); 

%group 3 POINT
ParameterGroup(3).name = 'POINT';
ParameterGroup(3).description = '';
%group 3, the number of markers
ParameterGroup(3).Parameter(1).name = 'USED';
ParameterGroup(3).Parameter(1).datatype = 2;
ParameterGroup(3).Parameter(1).dim = [];
ParameterGroup(3).Parameter(1).data = Nmarkers;
%group 3, the number of frames
ParameterGroup(3).Parameter(2).name = 'FRAMES';
ParameterGroup(3).Parameter(2).datatype = 2;
ParameterGroup(3).Parameter(2).dim = [];
ParameterGroup(3).Parameter(2).data = Nframes;
%group 3, the first block where 3d/analog data start. should be adjusted
%after all parameters are determined
ParameterGroup(3).Parameter(3).name = 'DATA_START';
ParameterGroup(3).Parameter(3).datatype = 2;
ParameterGroup(3).Parameter(3).dim = [];
ParameterGroup(3).Parameter(3).data = 0;
%group 3, scale which convert the raw data to the reference cooridinate
%system values recorded by POINT:UNITS parameter
ParameterGroup(3).Parameter(4).name = 'SCALE';
ParameterGroup(3).Parameter(4).datatype = 4;
ParameterGroup(3).Parameter(4).dim = [];
[Pvalue, Pdim, found] = find_c3d_parameter( InputParameterGroup, 'POINT', 'SCALE');
if found==1
    ParameterGroup(3).Parameter(4).data = Pvalue;
else
    ParameterGroup(3).Parameter(4).data = -0.10;
end
%group 3, sample rate of the data
ParameterGroup(3).Parameter(5).name = 'RATE';
ParameterGroup(3).Parameter(5).datatype = 4;
ParameterGroup(3).Parameter(5).dim = [];
[Pvalue, Pdim, found] = find_c3d_parameter( InputParameterGroup, 'POINT', 'RATE');
if found==1
    ParameterGroup(3).Parameter(5).data = Pvalue;
else
    ParameterGroup(3).Parameter(5).data = 120.0;
end
%group 3, synchronization offset in seconds between frame 1 of the trial
%and additional movie data
ParameterGroup(3).Parameter(6).name = 'MOVIE_DELAY';
ParameterGroup(3).Parameter(6).datatype = 4;
ParameterGroup(3).Parameter(6).dim = [];
ParameterGroup(3).Parameter(6).data = 0;
%group 3, distance units
ParameterGroup(3).Parameter(7).name = 'UNITS';
ParameterGroup(3).Parameter(7).datatype = -1;
[Pvalue, Pdim, found] = find_c3d_parameter( InputParameterGroup, 'POINT', 'UNITS');
if found==1
    ParameterGroup(3).Parameter(7).dim = Pdim;
    ParameterGroup(3).Parameter(7).data = Pvalue;
else
    ParameterGroup(3).Parameter(7).dim = 2;
    ParameterGroup(3).Parameter(7).data = 'mm';
end
%group 3, marker labels
label_field_num = 1;
for i=1:Nmarkers
    if mod(i,255) == 1
        if label_field_num==1
            label_name = 'LABELS';
        else
            label_name = sprintf('LABELS%d', label_field_num);
        end
     
        [Pvalue, Pdim, found] = find_c3d_parameter( InputParameterGroup, 'POINT', label_name );
        if( found==1 )
            ParameterGroup(3).Parameter(7 + label_field_num).name = label_name;
            ParameterGroup(3).Parameter(7 + label_field_num).datatype = -1;
            ParameterGroup(3).Parameter(7 + label_field_num).dim = Pdim;
            ParameterGroup(3).Parameter(7 + label_field_num).data = Pvalue;
        else
            %if it doesn't have labels
            label_dim1 = 30;
            if i+255 < Nmarkers+1
                label_dim2 = 255;
            else
                label_dim2 = Nmarkers+1 - i;
            end
            %make label strings
            for j=1:label_dim2
                tmpdata(j, [1:label_dim1]) = ' ';
                tmpdata(j,1) = '*'; %first character should not be number
                str = int2str(i+j-2);
                str_length = size(str, 2);
                tmpdata(j, [2:(str_length+1)]) = str;
            end
            ParameterGroup(3).Parameter(7 + label_field_num).name = label_name;
            ParameterGroup(3).Parameter(7 + label_field_num).datatype = -1;
            ParameterGroup(3).Parameter(7 + label_field_num).dim(1) = label_dim1;
            ParameterGroup(3).Parameter(7 + label_field_num).dim(2) = label_dim2;
            for j=1:label_dim2
                ParameterGroup(3).Parameter(7 + label_field_num).data{j} = tmpdata(j, :);
            end
        end
        label_field_num = label_field_num + 1;
    end
end

%group 4 EVENT_CONTEXT - contexts of named events that are stored in the
%EVENT group
ParameterGroup(4).name = 'EVENT_CONTEXT';
ParameterGroup(4).description = '';
%group 4, the number of event contexts stored in the group
ParameterGroup(4).Parameter(1).name = 'USED';
ParameterGroup(4).Parameter(1).datatype = 2;
ParameterGroup(4).Parameter(1).dim = [];
ParameterGroup(4).Parameter(1).data = 3;
%group 4, defining the event type or the context where the event will be
%used
ParameterGroup(4).Parameter(2).name = 'ICON_IDS';
ParameterGroup(4).Parameter(2).datatype = 2;
ParameterGroup(4).Parameter(2).dim = 3;
ParameterGroup(4).Parameter(2).data = [0;0;0];
%group 4, context label string(typically 16 characters each)
ParameterGroup(4).Parameter(3).name = 'LABELS';
ParameterGroup(4).Parameter(3).datatype = -1;
ParameterGroup(4).Parameter(3).dim = [16 3];
ParameterGroup(4).Parameter(3).data = {'Left' 'Right' 'General'};
%group 4, description of each event(typically 32 characters each)
ParameterGroup(4).Parameter(4).name = 'DESCRIPTIONS';
ParameterGroup(4).Parameter(4).datatype = -1;
ParameterGroup(4).Parameter(4).dim = [32 3];
ParameterGroup(4).Parameter(4).data = {'Left side' 'Right side' 'For other events'};
%group 4, color(RGB) of event context
ParameterGroup(4).Parameter(5).name = 'COLOURS';
ParameterGroup(4).Parameter(5).datatype = 2;
ParameterGroup(4).Parameter(5).dim = [3 3];
ParameterGroup(4).Parameter(5).data = 192 * eye(3);

%group 5 EVENT 
ParameterGroup(5).name = 'EVENT';
ParameterGroup(5).description = '';
%group 5 - the number of events in EVENT group
ParameterGroup(5).Parameter(1).name = 'USED';
ParameterGroup(5).Parameter(1).datatype = 2;
ParameterGroup(5).Parameter(1).dim = [];
ParameterGroup(5).Parameter(1).data = 0;

%calculate the start block number (group POINT, parameter 'DATA_START')

%count the number of bytes in header & parameter sections
byteCount = 512 + 4; %header + 4bytes of parameter section
for i=1:size(ParameterGroup,2)
    n = size(char(ParameterGroup(i).name), 2);
    m = size(char(ParameterGroup(i).description), 2);
    byteCount = byteCount + n + m + 5;
    for j=1:size(ParameterGroup(i).Parameter, 2)
        n = size(char(ParameterGroup(i).Parameter(j).name), 2);
        m = 0; %description
        
        dlen = abs( ParameterGroup(i).Parameter(j).datatype );
        if isfield( ParameterGroup(i).Parameter(j), 'dim' )
            num_dim = size(ParameterGroup(i).Parameter(j).dim, 2);
        else
            num_dim = 0;
        end
        
        if num_dim > 0
            for d=1:num_dim
                dlen = dlen * ParameterGroup(i).Parameter(j).dim(d);
            end
        end
        byteCount = byteCount + 6 + n + num_dim + dlen + 1+ m;
    end
end

if mod(byteCount,512) == 0
    start_record_num = floor(byteCount/512) + 1;
else
    start_record_num = floor(byteCount/512) + 2;
end

ParameterGroup(3).Parameter(3).data = start_record_num;

end