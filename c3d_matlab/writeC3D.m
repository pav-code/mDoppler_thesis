function writeC3D( filename, Markers, ParameterGroup, byteCount)
% write markers to the binary file (ver0)
% 
% filename : output filename
% Markers : position of markers
% ParameterGroup : c3d file parameters
% byteCount : the number of bytes in parameter (used for calculating
% padding zeros)
%
% Q Youn Hong, 2010/11/05 - currently only storing the marker data and not
% storing analog signal
 
fid=fopen(filename, 'w', 'n');
if fid==-1
   h=errordlg(['File: ',filename,' could not be opened'],'application error');
   return
end

% write header
Nfirst=2;
key=80;
[Nmarkers, found] = find_c3d_parameter(ParameterGroup, 'POINT', 'USED');
[Nframes, found] = find_c3d_parameter(ParameterGroup, 'POINT','FRAMES');
Nchannels = 0; 
first_field = 1;
last_field = Nframes;
max_gap = 0;
[scale_factor, found] = find_c3d_parameter(ParameterGroup, 'POINT', 'SCALE');
[record_start, found] = find_c3d_parameter(ParameterGroup, 'POINT', 'DATA_START');
NanalogFramesPerVideoFrame = 0;
[video_rate, found] = find_c3d_parameter(ParameterGroup, 'POINT', 'RATE');

fwrite(fid, Nfirst, 'int8');    %first number of parameter block
fwrite(fid, key, 'int8');       %key=80
fwrite(fid, Nmarkers, 'int16'); %Number of 3D points per field, byte = 3,4; word = 2
fwrite(fid, Nchannels, 'int16');%Number of analog channels per field byte = 5,6; word = 3
fwrite(fid, first_field, 'int16');  %Field number of first field of video data, byte = 7,8; word = 4
fwrite(fid, last_field, 'int16');   %Field number of last field of video data, byte = 9,10; word = 5
fwrite(fid, max_gap, 'int16');      %Maximum interpolation gap in fields, byte = 11,12; word = 6
fwrite(fid, scale_factor, 'float32'); %scaling parameter
fwrite(fid, record_start, 'int16'); %Starting record number, byte = 17,18; word = 9
fwrite(fid, NanalogFramesPerVideoFrame, 'int16');   %Number of analog frames per video field, byte = 19,20; word = 10
fwrite(fid, video_rate, 'float32');

for i=13:149
    fwrite(fid, 0, 'int16'); %padding zeros
end

key2 = 12345; %key value if file support 4char event labels, word = 150
fwrite(fid, key2, 'int16');

for i=151:256
    fwrite(fid, 0, 'int16');
end

%write parameter blocks
%byte 1 - reserved
type = 1;
fwrite(fid, type, 'int8');
%byte 2 - reserved
key = 80;
fwrite(fid, key, 'int8');
%byte 3 - number of parameter blocks to follow
fwrite(fid, record_start, 'int8');
%byte 4 - machine dependent value
%process type + 83 ( 1-Intel, 2-Dec, 3-MIPS)
proctype = 83+type;
fwrite(fid, proctype, 'int8');

%parameter blocks
for i=1:size(ParameterGroup, 2)
    %write group info
    n = size(char(ParameterGroup(i).name), 2);
    m = size(char(ParameterGroup(i).description), 2);
    fwrite(fid, n,'int8');
    
    group_num = i*-1;
    fwrite(fid, group_num, 'int8');
    
    fwrite(fid, char(ParameterGroup(i).name), 'char');
    
    off = 3+m;
    fwrite(fid, off, 'int16');
    
    fwrite(fid, m, 'int8');
    fwrite(fid, char(ParameterGroup(i).description), 'char');
    
    %write parameters
    for j=1:size(ParameterGroup(i).Parameter, 2)
        n = size(char(ParameterGroup(i).Parameter(j).name), 2);
        m = 0; %assume no description
        
        dlen = abs(ParameterGroup(i).Parameter(j).datatype);
        if isfield(ParameterGroup(i).Parameter(j), 'dim')
            num_dim = size(ParameterGroup(i).Parameter(j).dim,2);
        else
            num_dim = 0;
        end
        
        if num_dim > 0
            for d=1:num_dim
                dlen = dlen * ParameterGroup(i).Parameter(j).dim(d);
            end
        end
         
        fwrite(fid, n, 'int8'); %parameter name length
        fwrite(fid, i, 'int8'); %group number     
        fwrite(fid, char(ParameterGroup(i).Parameter(j).name), 'char');
        
        offset = 5 + num_dim + dlen + m;
        fwrite(fid, offset, 'int16'); %offset
        
        type = ParameterGroup(i).Parameter(j).datatype;
        fwrite(fid, type, 'int8');
        
        fwrite(fid, num_dim, 'int8');
        for d=1:num_dim
            fwrite(fid, ParameterGroup(i).Parameter(j).dim(d), 'uint8');
        end
        
        %debug from here
        Nparam = dlen / abs(type);
        data = ParameterGroup(i).Parameter(j).data;
        
        if type==-1 
           if num_dim==2 && dlen>0
               str_arr = char( ParameterGroup(i).Parameter(j).data );
               for si=1:size(str_arr,1)
                   tmpdata([1,ParameterGroup(i).Parameter(j).dim(1)]) = ' ';
                   tmpdata([1:size(str_arr,2)]) = str_arr(si,:);
                   fwrite(fid, char(tmpdata), 'char');
                   clear tmpdata;
               end
            elseif num_dim<2 && dlen>0
                fwrite(fid, char(data), 'char');
            end
        elseif type==1 
            fwrite(fid, data, 'int8');
        elseif type==2 && dlen>0
            if num_dim>1
                data = reshape(data, Nparam,1);
            end
            fwrite(fid, data, 'int16');
        elseif type==4 && dlen>0
            if num_dim>1
                data = reshape(data, Nparam,1);
            end
            fwrite(fid, data, 'float');
        end 
       
        fwrite(fid, m, 'int8');
       % fwrite(fid, 0, 'char'*m); description
    end
end

%padding zeros
padding_num = 512 - mod(byteCount,512);
for i=1:padding_num
    fwrite(fid, 0, 'int8');
end

% write data
if scale_factor < 0
    for i=1:Nframes
        for j=1:Nmarkers
            for k=1:3
                fwrite(fid, Markers(i,j,k), 'float32');
            end
            fwrite(fid, 0, 'float32'); %write residual
        end
%         for j=1:NanalogFramesPerVideoFrame
%             for k=1:NanalogChannels
%                 fwrite(fid, NanalogChannels, 'int16');
%             end
%         end

    end
else
    for i=1:Nframes
         for j=1:Nmarkers
             for k=1:3
                 pos = Markers(i,j,k) * scale;
                 fwrite(fid, pos, 'int16');
             end
             fwrite(fid, residual, 'int8'); 
             fwrite(fid, cameraInfo, 'int8');
         end
%         for j=1:NanalogFramesPerVideoFrame
%             for k=1:NanalogChannels
%                 fwrite(fid, NanalogChannels, 'int16');
%             end
%         end
     end
 end

fclose(fid);

end

