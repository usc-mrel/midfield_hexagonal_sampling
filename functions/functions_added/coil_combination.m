function images = coil_combinations(kdata,type)
%   Combine coil images
%   Input:
%       - k-space data: kdata (Nx x Ny x Nz x Nslice x Ncoil)
%       - How to combine coil images: type ('walsh' or 'sos')
%
%   Output:
%       - Coil combined images: images (Nx x Ny x Nz x Nslice)
%
%   Author: Bahadir Alp Barlas
%   Email: bbarlas@usc.edu

[Nx, Ny, Nz, Nslice, Ncoil] = size(kdata);
if strcmp(type, 'walsh')
    csm_option.method = 'walsh'; % coil estimation method: 'walsh', 'sos'
    csm_option.cal_shape = [16 16]; % calibration region
    kdata_prew_coils_slice_z = 1/sqrt(Nz)*myfft3(kdata);
    csm_option.kdata = squeeze(kdata(:,:,Nz/2+1,:,:)); % Please change this number to the kz of 0. (7 for SEMAC12; 4 for SEMAC6)
    [csm, cal_im] = coil_estimation(csm_option);
    
    csm = repmat(csm,[1 1 1 1 Nz]);
    csm = permute(csm,[1 2 5 3 4]);
    
    images =  sum(conj(csm).*kdata_prew_coils_slice_z,5); % Coil combined images ./ sqrt(sum(abs(csm).^2,4))
    % images =  sum(conj(csm).*myfft3(kdata_prew_coils_slice_z),5); % Coil combined images ./ sqrt(sum(abs(csm).^2,4))
else
    SEMAC_coils = myfft3(kdata);
    images = sos(SEMAC_coils);
end
