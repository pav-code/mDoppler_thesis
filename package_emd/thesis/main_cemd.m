% main of complex EMD
clear all;
close all;
clc;

% time for cemd2: Elapsed time is 0.047778 seconds.
disp('starting script.')

slice_size = 4800;
aTotPath = ('./data/');
dirNames = dir(aTotPath);
for lp = 3:length(dirNames)
    aPath = dirNames(lp).name;

    sPath = strcat('./data/',aPath ,'/');
    sFile = dir(strcat(sPath,'*.mat'));
    wPath = './imfs/';
    wCnn = strcat('/cnn/',aPath,'/');
    wAnn = strcat('/ann/',aPath,'/');

    d_samp_num = 2; % downsampling ammount
    sum_term = 3; % SUM 3 IMFS
    num_pixels = 120;

    Nf = 256;% # of frequency bins
    Nh = 127;% short-time window length
    w = tftb_window(Nh,'Kaiser');

    %sPath = '/home/pav/Dropbox/Chalmers/Year_2/Thesis/Matlab Code/emd_pkg/complex_emd/package_emd/Final/OneSecond90/'
    %sFile = strcat(sPath,'W_MW_16_08_1.mat')
    for iFileCount=1:size(sFile,1)
        load(strcat(sPath,sFile(iFileCount).name));
        aSTFT_slice = aSTFT_slice(1:end-1);
        if length(aSTFT_slice) == slice_size
            sum_term = 6;
        else
            sum_term = 3;
        end
%         tic 
%         [IMF,NB_IT] = emd(aSTFT_slice);
%         toc
        tic
        [IMF,NB_IT] = cemdc2([], aSTFT_slice); % bivariate emd 1st algo 
        toc
        %sum_imf=0;
        con_sig = []; %zeros(1,num_pixels*num_pixels);
        if length(NB_IT) < sum_term
            sum_term = length(NB_IT);
        end
        for i = 1:sum_term
            %sum_imf = sum_imf + IMF(i,:);
            con_sig = [con_sig imag(IMF(i,1:d_samp_num:end))];
        end
        if length(con_sig) ~= num_pixels*num_pixels
            add_len = num_pixels*num_pixels - length(con_sig);
            con_sig = [con_sig zeros(1,add_len)]; % for less imfs
        end
        Amin = min(con_sig);
        Amax = max(con_sig);
        sig_re = reshape(con_sig,[num_pixels, num_pixels])';
        image_imf = mat2gray(sig_re,[Amin,Amax]);
        imwrite(image_imf, strcat(wPath,wCnn,sFile(iFileCount).name(1:end-4),'_imf','.png')); 
        save(strcat(wPath,wAnn,sFile(iFileCount).name(1:end-4),'_imf','.mat'), 'con_sig');

    end
    disp(strcat('Finished folder: ',aPath))
end
disp('done.')