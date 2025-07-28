%%  Hexagonal Sampling
%   The main file for "Acceleration of SEMAC at 0.55T using hexagonal sampling" paper
%   Choose the dataset from "Choose Dataset" section by commenting all
%   other datasets except the chosen one. Then, simply run the code. For
%   detailed instruction see the README file in the Github respitory.

%   Author: Bahadir Alp Barlas
%   Email: bbarlas@usc.edu

clear all;
close all;
clc;

%% Add path
file_folder = pwd;
addpath(genpath('./ismrmrd'));
addpath(genpath('./MR_data'));
addpath(genpath('./functions'));
addpath(genpath('./figures'));

%% Choose Dataset
par_dataset = 'hip_phantom';
% par_dataset = 'spine_phantom'; 
% par_dataset = 'spine_vol0958'; 
% par_dataset = 'spine_vol1095'; 
% par_dataset = 'spine_vol1106'; 
% par_dataset = 'invivo_hip'; 

%% ISMRMD Data

% Hip Phantom SEMAC 16
if strcmp(par_dataset, 'hip_phantom')
    data_folder = append(file_folder,'/MR_data/hip_phantom');
    h5_SEMAC = [data_folder,'/h5/meas_MID00086_FID12781_pd_hip_cor_semac16_FOV280_p2.h5'];
    noise_SEMAC =  [data_folder,'/noise/noise_meas_MID00086_FID12781_pd_hip_cor_semac16_FOV280_p2.h5'];
    filename = 'hip_phantom_SEMAC16';
end

% Spine Phantom
if strcmp(par_dataset, 'spine_phantom')
    data_folder = append(file_folder,'/MR_data/spine_phantom');
    h5_SEMAC = [data_folder,'/h5/meas_MID00380_FID13479_pd_spine_cor_semac12_FOV320_p2.h5'];
    noise_SEMAC =  [data_folder,'/noise/noise_meas_MID00380_FID13479_pd_spine_cor_semac12_FOV320_p2.h5'];
    filename = 'spine_phantom_SEMAC12';
end

% Spine Vol958 Transversal
if strcmp(par_dataset, 'spine_vol0958')
    data_folder = append(file_folder,'/MR_data/vol0958_Spine');
    h5_SEMAC = [data_folder,'/h5/meas_MID00580_FID21999_t2_tse_tra_SEMAC6_bw401_os50_pr75_etl16_TR3900_p2.h5'];
    noise_SEMAC =  [data_folder,'/noise/noise_meas_MID00580_FID21999_t2_tse_tra_SEMAC6_bw401_os50_pr75_etl16_TR3900_p2.h5'];
    filename = 'spine_vol958_SEMAC6';
end

% Spine Vol1095 Transversal
if strcmp(par_dataset, 'spine_vol1095')
    data_folder = append(file_folder,'/MR_data/vol1095_Spine');
    h5_SEMAC = [data_folder,'/h5/meas_MID00857_FID09954_t2_semac_ax_bw401_os50_RL.h5'];
    noise_SEMAC =  [data_folder,'/noise/noise_meas_MID00857_FID09954_t2_semac_ax_bw401_os50_RL.h5'];
    filename = 'spine_vol1095_SEMAC6';
end

% Spine Vol1106 Transversal
if strcmp(par_dataset, 'spine_vol1106')
    data_folder = append(file_folder,'/MR_data/vol1106_Spine');
    h5_SEMAC = [data_folder,'/h5/meas_MID00777_FID11019_t2_semac8_ax_bw401_p2_os50_RL.h5'];
    noise_SEMAC =  [data_folder,'/noise/noise_meas_MID00777_FID11019_t2_semac8_ax_bw401_p2_os50_RL.h5'];
    filename = 'spine_vol1106_SEMAC8';
end

% Hip In Vivo
if strcmp(par_dataset, 'invivo_hip')
    data_folder = append(file_folder,'/MR_data/Invivo_hip');
    h5_SEMAC = [data_folder,'/h5/meas_MID00228_FID58568_pd_tse_cor_bw401_SEMAC12.h5'];
    noise_SEMAC =  [data_folder,'/noise/noise_meas_MID00228_FID58568_pd_tse_cor_bw401_SEMAC12.h5'];
    filename = 'hip_invivo_SEMAC12';
end


%% Initialize processing flags
Read_flags.h5_fileList       = h5_SEMAC;
Read_flags.noise_fileList    = noise_SEMAC;
Read_flags.RemoveOS          = true; % remove oversampling
Read_flags.IgnoreSeg         = true; % concatanate segmemtns
Read_flags.DoAverage         = true; % Do averages (if 'average' was set during data acquistion)
Read_flags.CropPhaseEncoding = true;
Read_flags.Squeeze           = true;
Read_flags.os                = 2; % oversampling rate (Siemens Default value, don't change it)
Read_flags.noisePreWhitening = true;

Read_flags.GRAPPA = true;

Read_flags.SliceOrder        = 'int';
Recon_flags.CoilComb         = 'walsh'; % ' walsh', 'sos'

figureflags.max_contrast = 1;

%% ISMRMD to mat
ismrmdtomat_start = tic;

[c_img, kdata, noise, info] = readSEMAC_ismrmd(Read_flags); % kdata:[Nkx,Nky,Nkz,NSlice,NCoil]
[Nx, Ny, Nz, Ns, Ncoil] = size(kdata{1});
kdata = kdata{1};

fprintf('Finished reading ismrmd data.\n');
fprintf('Total read SEMAC ismrmd time: %2.f seconds \n', toc(ismrmdtomat_start));

% Apply the noise prewhitening matrix on k-space before Recon
% ---- Calculate noise covariance ----
for k = 1:length(noise)
    [Psi, inv_L] = calculate_noise_covariance(noise{k});
    kdata_prew{k} = prewhitening_SEMAC(kdata,inv_L);
end

kdata = kdata_prew{1};


%% Organize Data
org_start = tic;

% Hip Phantom
if strcmp(par_dataset, 'hip_phantom')
    figureflags.slice_num = 11;
    figureflags.x = [51,66,83,154];
    figureflags.zoomed_ROI = [32,106;146,220];
    figureflags.snr_x_extend = [Nx-10:Nx];
end

% Spine Phantom
if strcmp(par_dataset, 'spine_phantom')
    figureflags.slice_num = 10;
    figureflags.x = [221,222,224];
    figureflags.zoomed_ROI = [86,256;57,165];
    figureflags.snr_x_extend = [355:359];
end

% Spine Vol0958
if strcmp(par_dataset, 'spine_vol0958')
    figureflags.max_contrast = 0.5;
    figureflags.slice_num = 5;
    figureflags.x = [218,234,239,242];
    figureflags.zoomed_ROI = [159,266;126,232];
end

% Spine Vol1095
if strcmp(par_dataset, 'spine_vol1095')
    figureflags.max_contrast = 0.5;
    figureflags.slice_num = 17;
    figureflags.x = [198,226,235,238];
    figureflags.zoomed_ROI = [142,263;166,314];
end

% Spine Vol1106
if strcmp(par_dataset, 'spine_vol1106')
    figureflags.max_contrast = 0.5;
    figureflags.slice_num = 14;
    figureflags.x = [197,219,229,235];
    figureflags.zoomed_ROI = [163,285;168,327];
end

% Hip In vivo
if strcmp(par_dataset, 'invivo_hip')

    SEMAC_coils = myfft3(kdata);
    SEMAC_coils = SEMAC_coils(:,:,2:11,:,:);
    kdata = myifft3(SEMAC_coils);
    filename = 'hip_invivo_SEMAC12';

    % GRAPPA-2 undersampling
    info{1}.calib_idx = transpose((118:143));
    kdata_ACR = kdata(:,info{1}.calib_idx,:,:,:);
    kdata(:,1:2:end,:,:,:) = 0;
    kdata(:,info{1}.calib_idx,:,:,:) = kdata_ACR;
    [Nx, Ny, Nz, Ns, Ncoil] = size(kdata);

    figureflags.max_contrast = 0.3;
    figureflags.slice_num = 10;
    figureflags.x = [56,80,117,152];
    figureflags.zoomed_ROI = [41,163;214,370];
end


fprintf('Total load time: %2.f seconds \n', toc(org_start));
[Nx, Ny, Nz, Nslice, Ncoil] = size(kdata);


%% Parameters
Recon_flags.CoilComb = 'walsh';                 % 'walsh', 'sos'
Read_flags.masktype = 4;                        % 4: Cross 1-bin ,5: Diamond 1-bin, DO NOT TRY OTHER VALUES                    

% Kernel Parameters
lambda = 0;
kersize = [3 3 3];
kernel_matrix_3D = zeros(kersize);
kernel_matrix_3D(:,1:2:3,:) = 1;
kernel_matrix_3D(2,2,2) = 0;
kernel_matrix_hex = zeros(kersize);
kernel_matrix_hex(:,1:2:3,1:2:3) = 1;

figureflags.y_f_log_scale = true;
figureflags.show_SOS_images = true;
figureflags.zoomed_SOS = true;
figureflags.show_error_images = true;
figureflags.snr_analysis = true;
figureflags.saveData = true;

figureflags.type_array = [Read_flags.masktype];
figureflags.type_name_array = ["Cross Regular";"Diamond Regular";"Cross 3-bin";
       "Cross 1-bin";"Diamond 1-bin";"Diamond 3-bin"];
figureflags.type_name_error_array = ["abs(Cross 2-bin - Full)";
       "abs(Diamond 2-bin - Full)";"abs(Cross 3-bin - Full)";
       "abs(Cross 1-bin - Full)";"abs(Diamond 1-bin - Full)";
       "abs(Diamond 3-bin - Full)"];
figureflags.y_f_setNames = ["GRAPPA-2 (2D)";"Hex Sampling (Before Mask)";"Hex Sampling (After Mask)"];
figureflags.SOS_names = ["GRAPPA-2D";"GRAPPA-3D";"GRAPPA-Hex (Before Masking)";"GRAPPA-Hex (After Masking)"];
if figureflags.show_error_images == true
    figureflags.SOS_names = [figureflags.SOS_names;"Abs(GRAPPA-Hex - GRAPPA-2D)";"Abs(GRAPPA-Hex - GRAPPA-3D)"];
end

if figureflags.show_error_images == true
    for i=1:length(figureflags.type_array)
        figureflags.y_f_setNames(end+1) = figureflags.type_name_error_array(figureflags.type_array(i));
    end
end

%% Regular GRAPPA 2D Recon
grappa_start = tic;
fprintf('Starting GRAPPA Recon:\n')
kdata_GRAPPA = zeros(Nx,Ny,Nz,Ncoil,Nslice);
zero_sp_idx = Nz/2 + 1; % zero spectral dimension index
kernal_size = [5,5]; % kernal size
for ns = 1:Nslice
    kdata_2dcoils = squeeze(kdata(:,:,:,ns,:));
    kcalib = squeeze(kdata(:, info{1}.calib_idx, zero_sp_idx, ns, :));
    kdata_GRAPPA(:, :, :, :, ns) = GRAPPA_spe(kdata_2dcoils, kcalib, kernal_size, lambda);
    fprintf('Finish %d/%d slice: %.2f seconds \n', ns, Nslice, toc(grappa_start))
end
fprintf('Total time: %2.f seconds \n', toc(grappa_start));
kdata_GRAPPA = permute(kdata_GRAPPA,[1 2 3 5 4]);
kdata_GRAPPA = reorder_slice(kdata_GRAPPA, Read_flags);

% Coil Combination
load_start = tic;
SEMAC_CC_GRAPPA = coil_combination(kdata_GRAPPA,Recon_flags.CoilComb);
fprintf('Total coil combination time: %2.f seconds \n', toc(load_start));
clear kdata_GRAPPA;

%% GRAPPA 3D Recon
GRAPPA_start = tic;
kdata_GRAPPA_3D = zeros(size(kdata));
for ns=1:Nslice
    MCalib = squeeze(kdata(:, info{1}.calib_idx, :, ns, :));
    MCalib = correct_MCalib(MCalib);
    kernel = GRAPPA_3D_calibrate(MCalib,kernel_matrix_3D,lambda);
    fprintf('Slice: %2.f\n',ns);
    Mu = squeeze(kdata(:,:,:,ns,:));
    recon_Mu = GRAPPA_3D_recon(Mu,kernel,kernel_matrix_3D);
    kdata_GRAPPA_3D(:,:,:,ns,:) = recon_Mu;
end
fprintf('Total time: %2.f seconds \n', toc(GRAPPA_start));
kdata_GRAPPA_3D = reorder_slice(kdata_GRAPPA_3D, Read_flags);

% Coil Combination
load_start = tic;
SEMAC_CC_GRAPPA_3D = coil_combination(kdata_GRAPPA_3D,Recon_flags.CoilComb);
fprintf('Total coil combination time: %2.f seconds \n', toc(load_start));
clear kdata_GRAPPA_3D;

%% Hexagonal Undersampling
hex_start = tic;
kdata_hex = hexSampling(kdata);
fprintf('Hex sampling total time: %2.f seconds \n', toc(hex_start));

%% GRAPPA-2 Hex Recon
GRAPPA_start = tic;
kdata_GRAPPA_Hex = zeros(size(kdata_hex));
for ns=1:Nslice
    MCalib = squeeze(kdata_hex(:, info{1}.calib_idx, :, ns, :));
    MCalib = correct_MCalib(MCalib);
    kernel = GRAPPA_Hex_calibrate(MCalib,kernel_matrix_hex,lambda);
    fprintf('Slice: %2.f\n',ns);
    Mu = squeeze(kdata_hex(:,:,:,ns,:));
    recon_Mu = GRAPPA_Hex_recon(Mu,kernel,kernel_matrix_hex);
    kdata_GRAPPA_Hex(:,:,:,ns,:) = recon_Mu;
end
fprintf('Total time: %2.f seconds \n', toc(GRAPPA_start));
% kdata_GRAPPA_Hex(:,info{1}.calib_idx,:,:,:) = kdata(:,info{1}.calib_idx,:,:,:)/2;
kdata_GRAPPA_Hex = reorder_slice(kdata_GRAPPA_Hex, Read_flags);
SEMAC_coils = myfft3(kdata_GRAPPA_Hex);
SEMAC_coils_masked = applyMask(SEMAC_coils,Read_flags.masktype);
kdata_GRAPPA_Hex = myifft3(SEMAC_coils);
kdata_GRAPPA_Hex_masked = myifft3(SEMAC_coils_masked);
clear SEMAC_coils; clear SEMAC_coils_masked; clear kdata; clear kdata_hex;

% Coil Combination
load_start = tic;
SEMAC_CC_GRAPPA_Hex = coil_combination(kdata_GRAPPA_Hex,Recon_flags.CoilComb);
SEMAC_CC_GRAPPA_Hex_masked = coil_combination(kdata_GRAPPA_Hex_masked,Recon_flags.CoilComb);
fprintf('Total coil combination time: %2.f seconds \n', toc(load_start));
clear kdata_GRAPPA_Hex; clear kdata_GRAPPA_Hex_masked;


%% Show y-f profiles
x = figureflags.x;
slice_num = figureflags.slice_num;

f1 = figure();
kz = floor(Ny/Nz);
for i=1:length(figureflags.x)
    for j=1:3
        if j==1 coil_images = SEMAC_CC_GRAPPA;
        elseif j==2 coil_images = SEMAC_CC_GRAPPA_Hex;
        else coil_images = SEMAC_CC_GRAPPA_Hex_masked;
        end

        image = zeros(Ny,Nz);
        for ii = 0:Nz-1
            index_SEMAC = Nz-ii;
            index_slice = slice_num-floor(Nz/2)+1+ii;
            if index_slice>0 && index_slice<=Nslice
                image(:,ii+1) = coil_images(x(i),:,index_SEMAC,index_slice);
            end
        end  
        image = transpose(abs(squeeze(image)));
        image = flip(abs(squeeze(image)),1);
        image = imresize(image, [size(image,1)*kz size(image,2)],'nearest');
        image = image/max(max(image));
        if strcmp(par_dataset, 'hip_invivo')
            image(image>0.5) = 0.5;
            image = image/max(max(image));
        end
        if figureflags.y_f_log_scale == true
            image = log(abs(image)+1);
        end
        subplot(length(x),3,3*(i-1)+j); imshow(image,[]); ylabel('\color{white}f');
        if i==1
            title(append('\color{white}',figureflags.y_f_setNames(j)));
        elseif i==length(x)
            xlabel('\color{white}y');
        end
    end
end
set(f1,'Position', get(0, 'Screensize'));
set(f1,'color','k');

%% SEMAC Combination
start = tic;
SEMAC_Images = zeros(Nx,Ny,Nslice);

SEMAC_Images(:,:,:,1) = SEMAC_combination(SEMAC_CC_GRAPPA);
SEMAC_Images(:,:,:,2) = SEMAC_combination(SEMAC_CC_GRAPPA_3D);
SEMAC_Images(:,:,:,3) = 2*SEMAC_combination(SEMAC_CC_GRAPPA_Hex);
SEMAC_Images(:,:,:,4) = 2*SEMAC_combination(SEMAC_CC_GRAPPA_Hex_masked);

fprintf('SEMAC Combination time: %2.f seconds \n', toc(start));

% SSIM
SSIM_values = zeros(Nslice,6);
for i=1:Nslice
    im1 = SEMAC_Images(:,round(Ny/4):round(3*Ny/4),i,2);
    im2 = SEMAC_Images(:,round(Ny/4):round(3*Ny/4),i,1);
    ssim_GRAPPA3D_2D = ssim(im1/max(max(im2)),im2/max(max(im1)));
    SSIM_values(i,1) = ssim_GRAPPA3D_2D;
    
    im1 = SEMAC_Images(:,round(Ny/4):round(3*Ny/4),i,4);
    im2 = SEMAC_Images(:,round(Ny/4):round(3*Ny/4),i,1);
    ssim_GRAPPAHex_2D = ssim(im1/max(max(im2)),im2/max(max(im1)));
    SSIM_values(i,2) = ssim_GRAPPAHex_2D;

    im1 = SEMAC_Images(:,round(Ny/4):round(3*Ny/4),i,4);
    im2 = SEMAC_Images(:,round(Ny/4):round(3*Ny/4),i,2);
    ssim_GRAPPAHex_3D = ssim(im1/max(max(im2)),im2/max(max(im1)));
    SSIM_values(i,3) = ssim_GRAPPAHex_3D;

    if i == figureflags.slice_num
        disp("SSIM (Central half FOV-y) (GRAPPA-3D -> GRAPPA-2D)= "+ssim_GRAPPA3D_2D);
        disp("SSIM (Central half FOV-y) (GRAPPA-HEX -> GRAPPA-2D)= "+ssim_GRAPPAHex_2D);
        disp("SSIM (Central half FOV-y) (GRAPPA-HEX -> GRAPPA-3D)= "+ssim_GRAPPAHex_3D);
    end

    im1 = SEMAC_Images(:,:,i,2);
    im2 = SEMAC_Images(:,:,i,1);
    ssim_GRAPPA3D_2D = ssim(im1/max(max(im2)),im2/max(max(im2)));
    SSIM_values(i,4) = ssim_GRAPPA3D_2D;

    im1 = SEMAC_Images(:,:,i,4);
    im2 = SEMAC_Images(:,:,i,1);
    ssim_GRAPPAHex_2D = ssim(im1/max(max(im2)),im2/max(max(im2)));
    SSIM_values(i,5) = ssim_GRAPPAHex_2D;

    im1 = SEMAC_Images(:,:,i,4);
    im2 = SEMAC_Images(:,:,i,2);
    ssim_GRAPPAHex_3D = ssim(im1/max(max(im2)),im2/max(max(im2)));
    SSIM_values(i,6) = ssim_GRAPPAHex_3D;

    if i == figureflags.slice_num
        disp("SSIM (GRAPPA-3D -> GRAPPA-2D)= "+ssim_GRAPPA3D_2D);
        disp("SSIM (GRAPPA-HEX -> GRAPPA-2D)= "+ssim_GRAPPAHex_2D);
        disp("SSIM (GRAPPA-HEX -> GRAPPA-3D)= "+ssim_GRAPPAHex_3D);
    end
end

if strcmp(par_dataset, 'invivo_hip')
    SEMAC_Images_temp = zeros(Nx,570,Nslice,3);
    for j=1:4
        for i=1:Nslice
            SEMAC_Images_temp(:,:,i,j) = imresize(SEMAC_Images(:,:,i,j),[Nx 570]);
        end
    end
    SEMAC_Images = SEMAC_Images_temp;
end


%% Show SOS for y-f profiles
x_label = "y [cm]";
y_label = "x [cm]";
max_contrast = figureflags.max_contrast;
f2 = figure();
image = SEMAC_Images(:,:,figureflags.slice_num,1);
imshow(image,[0 max(max(image))*max_contrast]);
for j=1:length(x)
    hold on; line([1,Ny],[x(j),x(j)],'LineWidth',2);
end
xlabel(x_label); ylabel(y_label);
set(f2, 'Position', get(0, 'Screensize'));

%% Show All Slices
x_label = "y [cm]";
y_label = "x [cm]";
max_contrast = figureflags.max_contrast;
num_row = floor(sqrt(Nslice));
num_col = ceil(Nslice/num_row);
f3 = figure();
for i=1:Nslice
    subplot(num_row,num_col,i);
    image = SEMAC_Images(:,:,i,1);
    imshow(image,[0 max(max(image))*max_contrast]);
    title(append('Slice: ',num2str(i)));
end
set(f3, 'Position', get(0, 'Screensize'));

%% Show SOS Images
if figureflags.show_SOS_images == true   
    max_value = max(max(max(squeeze(SEMAC_Images(:,:,figureflags.slice_num,:)))));

    % Show SOS Images
    f4 = figure();
    if figureflags.show_error_images == true
        Nimages = size(SEMAC_Images,4)+2;
    else
        Nimages = size(SEMAC_Images,4);
    end
    for i=1:Nimages
        if i <= 2
            image = SEMAC_Images(:,:,figureflags.slice_num,i);
            image = image/max_value;
        elseif i<=4
            image = SEMAC_Images(:,:,figureflags.slice_num,i);
            image = image/max_value;
        elseif figureflags.show_error_images == true
            if i==5
                image = abs(SEMAC_Images(:,:,figureflags.slice_num,4)-SEMAC_Images(:,:,figureflags.slice_num,1));
                image = image/max_value;
            elseif i==6
                image = abs(SEMAC_Images(:,:,figureflags.slice_num,4)-SEMAC_Images(:,:,figureflags.slice_num,2));
                image = image/max_value;
            end
        end
        disp("Max Pixel Value: "+max(max(image)));
        zoomed_images(:,:,i) = image(figureflags.zoomed_ROI(1,1):figureflags.zoomed_ROI(1,2),figureflags.zoomed_ROI(2,1):figureflags.zoomed_ROI(2,2));
        if figureflags.show_error_images == false
            subplot(1,Nimages,i);
        else
            subplot(2,Nimages/2,i);
        end
        if i>=5
            imshow(image,[0 max(max(image))]);
        else
            imshow(image,[0 1*max_contrast]);
        end
        title(figureflags.SOS_names(i)); xlabel(x_label);
        ylabel(y_label); colorbar;
    end
    set(f4, 'Position', get(0, 'Screensize'));

    f5 = figure();
    for i=1:Nimages
        if figureflags.show_error_images == false
            subplot(1,Nimages,i);
        else
            subplot(2,Nimages/2,i);
        end
        image = zoomed_images(:,:,i);
        if figureflags.show_error_images == true && i>4
            imshow(image,[0 max(max(image))]);
        else
            imshow(image,[0 1*max_contrast]);
        end
        title(figureflags.SOS_names(i)); xlabel(x_label);
        ylabel(y_label); colorbar;
    end
    set(f5, 'Position', get(0, 'Screensize'));
end

%% SNR Analysis
if figureflags.snr_analysis == true && (strcmp(par_dataset, 'hip_phantom') | strcmp(par_dataset, 'spine_phantom'))
    snr_data = zeros(length(figureflags.snr_x_extend),Ny,Nz,Nslice,3);
    snr_data(:,:,:,:,1) = real(SEMAC_CC_GRAPPA(figureflags.snr_x_extend,:,:,:));
    snr_data(:,:,:,:,2) = 2*real(SEMAC_CC_GRAPPA_Hex(figureflags.snr_x_extend,:,:,:));
    snr_data(:,:,:,:,3) = 2*real(SEMAC_CC_GRAPPA_Hex_masked(figureflags.snr_x_extend,:,:,:));

    sigma_array = zeros(Ny,3);
    for i=1:Ny
        for j=1:3
            temp = snr_data(:,i,:,:,j);
            temp = temp(:);
            sigma_array(i,j) = var(temp);
        end
    end
    sigma_array = sigma_array/mean(sigma_array(:,1));
    sigma_array = sigma_array-mean(sigma_array(:,1))+1;

    f6 = figure();
    for i=1:3
        subplot(1,3,i); plot(sigma_array(:,i)); ylim([0 2.5]); yticks([0 0.5 1.0 1.5 2 2.5]);
        xlim([1 Ny]); xticks([1 round(Ny/4) round(Ny/2) round(3*Ny/4) Ny]); title(figureflags.y_f_setNames(i)); grid on;
    end
    set(f6, 'Position', get(0, 'Screensize'));
else
    figureflags.snr_analysis = false;
end


%% Save SOS Data
if figureflags.saveData == true
    load_start = tic;
    
    matlab_SOS_data_folder = append(file_folder,'/figures');
    addpath(genpath(matlab_SOS_data_folder));
    file_name = append(filename,'_SOS.mat');
    
    cd(matlab_SOS_data_folder)
    mkdir(filename); cd(filename);
    save(file_name,'SEMAC_Images','SSIM_values','figureflags','-v7.3');
    savefig(f1,append(filename,'_y_f_profile.fig'));
    savefig(f2,append(filename,'_SOS_y_f_lines.fig'));
    savefig(f3,append(filename,'_SOS_allslices.fig'));
    savefig(f4,append(filename,'_SOS.fig'));
    if figureflags.zoomed_SOS == true
        savefig(f5,append(filename,'_SOS_zoomed.fig'));
    end
    if figureflags.snr_analysis == true
        savefig(f6,append(filename,'_SNR.fig'));
    end
    cd(file_folder);
    fprintf('Total SOS data save time: %2.f seconds \n', toc(load_start));
end

