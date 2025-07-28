%%  G-factor map calculation
%   The code below generates the g-factor maps for GRAPPA-2 Hex using 
%   GRAPPA-2 (2D) and GRAPPA-2 (3D) reconstructions as references
%   The uses pseudo-noise replica method [1] to find the pixel-wise noise 
%   standard deviation maps. The code is highly inefficient and the total
%   computation time is measured in days even utilizing "parfor" for GRAPPA
%   reconstructions. The findings are not provided in the manuscript as
%   it is matching with the noise variance maps provided. 

%   Note that 3D kernel has slight denoising capailities. That is why
%   g-factor map with GRAPPA-2 (2D) as reference has a mean value slightly
%   smaller than 1 while g-factor map with GRAPPRA-2 (3D) as reference has
%   a mean values approximately equal to 1 which is consistent with the
%   theory.

%   Author: Bahadir Alp Barlas
%   Email: bbarlas@usc.edu

% [1] Robson PM, Grant AK, Madhuranthakam AJ, Lattanzi R, Sodickson DK, 
% McKenzie CA. Comprehensive quantification of signal‐to‐noise ratio 
% and g‐factor for image‐based and k‐space‐based parallel imaging 
% reconstructions. 
% Magnetic Resonance in Med. 2008;60(4):895-907. doi:10.1002/mrm.21728

clear all;
close all;
clc;

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
end

% Spine Phantom
if strcmp(par_dataset, 'spine_phantom')
    figureflags.slice_num = 10;
end

% Spine Vol0958
if strcmp(par_dataset, 'spine_vol0958')
    figureflags.slice_num = 5;
end

% Spine Vol1095
if strcmp(par_dataset, 'spine_vol1095')
    figureflags.slice_num = 17;
end

% Spine Vol1106
if strcmp(par_dataset, 'spine_vol1106')
    figureflags.slice_num = 14;
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

    figureflags.slice_num = 10;
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

figureflags.SOS_names = ["GRAPPA-2D";"GRAPPA-3D";"GRAPPA-Hex (Before Masking)";"GRAPPA-Hex (After Masking)"];
figureflags.SOS_names = [figureflags.SOS_names;"Abs(GRAPPA-Hex - GRAPPA-2D)";"Abs(GRAPPA-Hex - GRAPPA-3D)"];

kdata_ref = kdata;

%% GET KERNELS
% Regular GRAPPA 2D Recon
grappa_start = tic;
fprintf('Starting GRAPPA Recon:\n')
kdata_GRAPPA = zeros(Nx,Ny,Nz,Ncoil,Nslice);
zero_sp_idx = Nz/2 + 1; % zero spectral dimension index
kernel_size = [5,5]; % kernal size
parfor(ns = 1:Nslice,Nslice)
    kdata_2dcoils = squeeze(kdata(:,:,:,ns,:));
    kcalib = squeeze(kdata(:, info{1}.calib_idx, zero_sp_idx, ns, :));
    [kdata_GRAPPA(:, :, :, :, ns),LIST(:,:,:,:,ns),KEY(:,:,:,:,ns)] = GRAPPA_spe_save_kernel(kdata_2dcoils, kcalib, kernel_size, lambda);
    fprintf('Finish %d/%d slice: %.2f seconds \n', ns, Nslice, toc(grappa_start))
end
fprintf('Total time: %2.f seconds \n', toc(grappa_start));
kdata_GRAPPA = permute(kdata_GRAPPA,[1 2 3 5 4]);
kdata_GRAPPA = reorder_slice(kdata_GRAPPA, Read_flags);

load_start = tic;
SEMAC_CC_GRAPPA = coil_combination(kdata_GRAPPA,Recon_flags.CoilComb);
fprintf('Total coil combination time: %2.f seconds \n', toc(load_start));
clear kdata_GRAPPA;

% GRAPPA 3D Recon
GRAPPA_start = tic;
kdata_GRAPPA_3D = zeros(size(kdata));
kernel_mat_3D = zeros(sum(kernel_matrix_3D,"all")*Ncoil,Ncoil,Nslice);
parfor(ns = 1:Nslice,Nslice)
    MCalib = squeeze(kdata(:, info{1}.calib_idx, :, ns, :));
    MCalib = correct_MCalib(MCalib);
    kernel = GRAPPA_3D_calibrate(MCalib,kernel_matrix_3D,lambda);
    kernel_mat_3D(:,:,ns) = kernel;
    fprintf('Slice: %2.f\n',ns);
    Mu = squeeze(kdata(:,:,:,ns,:));
    recon_Mu = GRAPPA_3D_recon(Mu,kernel,kernel_matrix_3D);
    kdata_GRAPPA_3D(:,:,:,ns,:) = recon_Mu;
end
fprintf('Total time: %2.f seconds \n', toc(GRAPPA_start));
kdata_GRAPPA_3D= reorder_slice(kdata_GRAPPA_3D, Read_flags);

load_start = tic;
SEMAC_CC_GRAPPA_3D = coil_combination(kdata_GRAPPA_3D,Recon_flags.CoilComb);
fprintf('Total coil combination time: %2.f seconds \n', toc(load_start));
clear kdata_GRAPPA_3D;

% Hexagonal Undersampling
hex_start = tic;
kdata_hex = hexSampling(kdata);
fprintf('Hex sampling total time: %2.f seconds \n', toc(hex_start));

% GRAPPA-2 Hex Recon
GRAPPA_start = tic;
kdata_GRAPPA_Hex = zeros(size(kdata_hex));
kernel_mat_hex = zeros(sum(kernel_matrix_hex,"all")*Ncoil,Ncoil,Nslice);
parfor(ns=1:Nslice,round(Nslice))
    MCalib = squeeze(kdata_hex(:, info{1}.calib_idx, :, ns, :));
    MCalib = correct_MCalib(MCalib);
    kernel = GRAPPA_Hex_calibrate(MCalib,kernel_matrix_hex,lambda);
    kernel_mat_hex(:,:,ns) = kernel;
    fprintf('Slice: %2.f\n',ns);
    Mu = squeeze(kdata_hex(:,:,:,ns,:));
    recon_Mu = GRAPPA_Hex_recon(Mu,kernel,kernel_matrix_hex);
    kdata_GRAPPA_Hex(:,:,:,ns,:) = recon_Mu;
end
fprintf('Total time: %2.f seconds \n', toc(GRAPPA_start));
kdata_GRAPPA_Hex = reorder_slice(kdata_GRAPPA_Hex, Read_flags);
SEMAC_coils = myfft3(kdata_GRAPPA_Hex);
SEMAC_coils_masked = applyMask(SEMAC_coils,Read_flags.masktype);
kdata_GRAPPA_Hex = myifft3(SEMAC_coils);
kdata_GRAPPA_Hex_masked = myifft3(SEMAC_coils_masked);
clear SEMAC_coils; clear SEMAC_coils_masked; clear kdata; clear kdata_hex;

load_start = tic;
SEMAC_CC_GRAPPA_Hex = coil_combination(kdata_GRAPPA_Hex,Recon_flags.CoilComb);
SEMAC_CC_GRAPPA_Hex_masked = coil_combination(kdata_GRAPPA_Hex_masked,Recon_flags.CoilComb);
fprintf('Total coil combination time: %2.f seconds \n', toc(load_start));
clear kdata_GRAPPA_Hex; clear kdata_GRAPPA_Hex_masked;

% SEMAC Combination
start = tic;
SEMAC_Images = zeros(Nx,Ny,Nslice);

SEMAC_Images(:,:,:,1) = SEMAC_combination(SEMAC_CC_GRAPPA);
SEMAC_Images(:,:,:,2) = SEMAC_combination(SEMAC_CC_GRAPPA_3D);
SEMAC_Images(:,:,:,3) = 2*SEMAC_combination(SEMAC_CC_GRAPPA_Hex);
SEMAC_Images(:,:,:,4) = 2*SEMAC_combination(SEMAC_CC_GRAPPA_Hex_masked);

%% Show SOS Images
max_value = max(max(max(squeeze(SEMAC_Images(:,:,figureflags.slice_num,:)))));
x_label = "y [cm]";
y_label = "x [cm]";
f1 = figure();
Nimages = size(SEMAC_Images,4);
for i=1:Nimages
    if i <= 2
        image = SEMAC_Images(:,:,figureflags.slice_num,i);
        image = image/max_value;
    elseif i<=4
        image = SEMAC_Images(:,:,figureflags.slice_num,i);
        image = image/max_value;
    end
    disp("Max Pixel Value: "+max(max(image)));
    subplot(1,Nimages,i);
    if i>=5
        imshow(image,[0 max(max(image))]);
    else
        imshow(image,[0 1]);
    end
    title(figureflags.SOS_names(i)); xlabel(x_label);
    ylabel(y_label); colorbar;
end
set(f1, 'Position', get(0, 'Screensize'));

%% Pseudo-noise replica method for G-factor calculation
num_iter = 100;
SEMAC_Images_noise = zeros(Nx,Ny,Ns,4,num_iter);

for iter=1:num_iter
    % Add Noise
    pat = abs(kdata_ref)>0;
    noise1 = randn(Nx,Ny,Nz,Nslice,Ncoil);
    noise2 = randn(Nx,Ny,Nz,Nslice,Ncoil);
    noise = noise1 + 1i*noise2;
    noise = noise.*pat;
    clear noise1; clear noise2;
    kdata = kdata_ref;
    kdata = kdata + noise;

    % Regular GRAPPA Recon
    grappa_start = tic;
    fprintf('Starting GRAPPA Recon:\n')
    kdata_GRAPPA = zeros(Nx,Ny,Nz,Ncoil,Nslice);
    zero_sp_idx = Nz/2 + 1; % zero spectral dimension index
    kernel_size = [5,5]; % kernel size
    parfor(ns = 1:Nslice,Nslice)
        kdata_2dcoils = squeeze(kdata(:,:,:,ns,:));
        kcalib = squeeze(kdata(:, info{1}.calib_idx, zero_sp_idx, ns, :));
        list = LIST(:,:,:,:,ns);
        key = KEY(:,:,:,:,ns);
        kdata_GRAPPA(:, :, :, :, ns) = GRAPPA_spe_with_kernel(kdata_2dcoils, kcalib, kernel_size, lambda, list, key);
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

    % GRAPPA-3D Recon
    GRAPPA_start = tic;
    kdata_GRAPPA_3D = zeros(size(kdata));
    parfor(ns=1:Nslice,Nslice)
        MCalib = squeeze(kdata(:, info{1}.calib_idx, :, ns, :));
        MCalib = correct_MCalib(MCalib);
        kernel = kernel_mat_3D(:,:,ns);
        fprintf('Slice: %2.f\n',ns);
        Mu = squeeze(kdata(:,:,:,ns,:));
        recon_Mu = GRAPPA_recon_3D(Mu,kernel,kernel_matrix_3D);
        kdata_GRAPPA_3D(:,:,:,ns,:) = recon_Mu;
    end
    fprintf('Total time: %2.f seconds \n', toc(GRAPPA_start));
    kdata_GRAPPA_3D = reorder_slice(kdata_GRAPPA_3D, Read_flags);

    % Coil Combination
    load_start = tic;
    SEMAC_CC_GRAPPA_3D = coil_combination(kdata_GRAPPA_3D,Recon_flags.CoilComb);
    fprintf('Total coil combination time: %2.f seconds \n', toc(load_start));
    clear kdata_GRAPPA_3D;

    % Hexagonal Undersampling
    hex_start = tic;
    kdata_hex = hexSampling(kdata);
    fprintf('Hex sampling total time: %2.f seconds \n', toc(hex_start));

    % GRAPPA-2 Hex Recon
    GRAPPA_start = tic;
    kdata_GRAPPA_Hex = zeros(size(kdata_hex));
    parfor(ns=1:Nslice,round(Nslice))
        MCalib = squeeze(kdata_hex(:, info{1}.calib_idx, :, ns, :));
        MCalib = correct_MCalib(MCalib);
        kernel = kernel_mat_hex(:,:,ns);
        fprintf('Slice: %2.f\n',ns);
        Mu = squeeze(kdata_hex(:,:,:,ns,:));
        recon_Mu = GRAPPA_recon(Mu,kernel,kernel_matrix_hex);
        kdata_GRAPPA_Hex(:,:,:,ns,:) = recon_Mu;
    end
    fprintf('Total time: %2.f seconds \n', toc(GRAPPA_start));
    kdata_GRAPPA_Hex = reorder_slice(kdata_GRAPPA_Hex, Read_flags);
    SEMAC_coils = myfft3(kdata_GRAPPA_Hex);
    SEMAC_coils_masked = applyMask(SEMAC_coils,Read_flags.masktype);
    kdata_GRAPPA_Hex = myifft3(SEMAC_coils);
    kdata_GRAPPA_Hex_masked = myifft3(SEMAC_coils_masked);
    clear SEMAC_coils; clear SEMAC_coils_masked; clear kdata_hex;
    
    load_start = tic;
    SEMAC_CC_GRAPPA_Hex = coil_combination(kdata_GRAPPA_Hex,Recon_flags.CoilComb);
    SEMAC_CC_GRAPPA_Hex_masked = coil_combination(kdata_GRAPPA_Hex_masked,Recon_flags.CoilComb);
    fprintf('Total coil combination time: %2.f seconds \n', toc(load_start));
    clear kdata_GRAPPA_Hex; clear kdata_GRAPPA_Hex_masked;

    SEMAC_Images_noise(:,:,:,1,iter) = SEMAC_combination(SEMAC_CC_GRAPPA);
    SEMAC_Images_noise(:,:,:,2,iter) = SEMAC_combination(SEMAC_CC_GRAPPA_3D);
    SEMAC_Images_noise(:,:,:,3,iter) = SEMAC_combination(SEMAC_CC_GRAPPA_Hex);
    SEMAC_Images_noise(:,:,:,4,iter) = SEMAC_combination(SEMAC_CC_GRAPPA_Hex_masked);
end

%% Get Std Map (Bin)
std_SEMAC = zeros(Nx,Ny,Nslice,4);
for k=1:Nslice
    for i=1:Nx
        for j=1:Ny
            for ind = 1:4
                vect = squeeze(SEMAC_Images_noise(i,j,k,ind,:));
                std_SEMAC(i,j,k,ind) = std(real(vect));
            end
        end
    end
end

%% Show STD Results
figure;
subplot(2,2,1); imshow(std_SEMAC(:,:,figureflags.slice_num,1),[0 1]);
title('SEMAC Comb GRAPPA-2'); colormap("jet"); colorbar;
subplot(2,2,2); imshow(std_SEMAC(:,:,figureflags.slice_num,2),[0 1]);
title('SEMAC Comb GRAPPA-3D'); colormap("jet"); colorbar;
subplot(2,2,3); imshow(std_SEMAC(:,:,figureflags.slice_num,3),[0 1]);
title('SEMAC Comb Hex'); colormap("jet"); colorbar;
subplot(2,2,4); imshow(std_SEMAC(:,:,figureflags.slice_num,4),[0 1]);
title('SEMAC Comb Hex Masked'); colormap("jet"); colorbar;

%% G-factor Maps
mean_array_2D = zeros(Nslice,1);
mean_array_3D = zeros(Nslice,1);

for ns=1:Nslice
    grappa2D_noise = std_SEMAC(:,:,ns,1);
    grappa3D_noise = std_SEMAC(:,:,ns,2);
    hex_noise = std_SEMAC(:,:,ns,4);
    g_factor_2D = sqrt(2)*hex_noise./grappa2D_noise;
    g_factor_3D = sqrt(2)*hex_noise./grappa3D_noise;

    if ns==figureflags.slice_num
        figure; imshow(g_factor_2D,[0.5 1.5]); colormap("jet"); colorbar;
        figure; imshow(g_factor_3D,[0.5 1.5]); colormap("jet"); colorbar;
    end

    % ind1 = (130:250);
    % ind2 = (160:200);
    % 
    % area2D = g_factor_2D(ind1,ind2);
    % mean_val2D = mean(area2D(:));
    % mean_array_2D(ns,1) = mean_val2D;
    % 
    % if ns==figureflags.slice_num
    %     disp(mean_val2D);
    % end
    % 
    % area3D = g_factor_3D(ind1,ind2);
    % mean_val3D = mean(area3D(:));
    % mean_array_3D(ns,1) = mean_val3D;
    % 
    % if ns==figureflags.slice_num
    %     disp(mean_val3D);
    % end
end



