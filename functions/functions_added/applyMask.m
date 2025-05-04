%% Apply Masks to Data
function masked_data = applyMask(images,mask_type)
%   Apply mask for removing replicas in hexagonally sampled data
%   Input:
%       - image data: images (Nx x Ny x Nz x Nslice x Ncoil)
%       - Mask Type: mask_type (See 'generateMask' function)
%
%   Output:
%       - Masked image data: masked_data (Nx x Ny x Nz x Nslice x Ncoil)
%
%   Author: Bahadir Alp Barlas
%   Email: bbarlas@usc.edu

opt = 0;
masked_data = images;
[Nx,Ny,Nz,Nslice,Ncoil] = size(images);
if mask_type == 1
    mask = generateMask(Ny,Nz,1,opt);
elseif mask_type == 2
    mask = generateMask(Ny,Nz,2,opt);
elseif mask_type == 3 % Cross
    mask = generateMask(Ny,Nz,3,opt);
elseif mask_type == 4
    mask = generateMask(Ny,Nz,4,opt);
elseif mask_type == 5
    mask = generateMask(Ny,Nz,5,opt);
elseif mask_type == 6 % Diamond
    mask = generateMask(Ny,Nz,6,opt); 
end

if exist('mask','var') == 1
    for q=1:Ncoil
        for n=1:Nslice
            for i=1:Nx
                masked_data(i,:,:,n,q) = squeeze(masked_data(i,:,:,n,q)).*mask;
            end
        end
    end
end
end
