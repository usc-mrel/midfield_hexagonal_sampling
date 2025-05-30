%% Hexagonal Sampling
function kdata_hexSampled = hexSampling(kdata_all_org)
%   Interpolation step for 3D GRAPPA Reconstruction
%   Input:
%       - kdata: kdata_all_org (Nx x Ny x Nz x Nslice x Ncoil)
%
%   Output:
%       - kdata (hexagonally undersampled): kdata_hexSampled (Nx x Ny x Nz x Nslice x Ncoil)
%
%   Author: Bahadir Alp Barlas
%   Email: bbarlas@usc.edu

[Nx, Ny, Nz, Nslice, Ncoil] = size(kdata_all_org);
kdata_hexSampled = zeros(Nx,Ny,Nz,Nslice,Ncoil);
for q=1:Ncoil
    for n=1:Nslice
        for i=1:Nx
            kdata_temp = squeeze(kdata_all_org(i,:,:,n,q));
            for j=1:Ny
                for k=1:Nz
                    if(mod(j+k,2)==1)
                        kdata_temp(j,k) = 0;
                    end
                end
            end
            kdata_hexSampled(i,:,:,n,q) = kdata_temp;
        end
    end
end
end
