function recon_Mu = GRAPPA_recon(Mu,kernel,kernel_matrix)
%   Interpolation step for 3D GRAPPA Reconstruction
%   Input:
%       - k-space data: Mu (Nx x Ny x Nz x Nslice x Ncoil)
%       - Kernel for 3D GRAPPA recon: kernel (3 x 3 x 3)
%       - Mask for 3D kernel: kernel_matrix (3 x 3 x 3)
%
%   Output:
%       - Interpolated k-space data: recon_Mu (Nx x Ny x Nz x Nslice x Ncoil)
%
%   Author: Bahadir Alp Barlas
%   Email: bbarlas@usc.edu

kersize = size(kernel_matrix);
hex_param = 0;
pat = abs(Mu)>0; pat = sum(pat,4); pat = abs(pat)>0;

limX = (kersize(1)-1)/2;
limY = (kersize(2)-1)/2;
limZ = (kersize(3)-1)/2;

% Mu = padarray(Mu,[0 limY-1 ],0,'both');
% pat = padarray(pat,[0 limY-1],0,'both');
[Nx,Ny,Nz,Nc] = size(Mu);
zero_sp_idx = floor(Nz/2)+1; % zero spectral dimension index
recon_Mu = Mu;

for t=1:Nc
    fprintf('\n coil: %2.f.\n',t);
    for k=1+limZ:Nz-limZ
        % fprintf('bin: %2.f.\n',k);
        for j=1+limY:Ny-limY
            for i=1+limX:Nx-limX
                if (mod(j+k,2)==hex_param)
                    if pat(i,j,k) == 0
                        % fprintf('i: %2.f, j=%2.f, k=%2.f, t=%2.f.\n',i,j,k,t);
                        index = [i,j,k];
                        kerData = give_kernel_points(Mu, index, kernel_matrix);
                        kerData = kerData(:);
                        recon_Mu(i,j,k,t) = transpose(kerData)*kernel(:,t);
                    end
                end
            end
        end
    end
end
% recon_image = fft3c(squeeze(recon_Mu(:,:,zero_sp_idx,:)));
% figure; montage(abs(recon_image),'displayRange',[]);
end
