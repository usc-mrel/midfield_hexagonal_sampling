function kernel = GRAPPA_calibrate(MCalib,kernel_matrix,lambda)
%   Learn the kernel for 3D GRAPPA recon using calibration data
%   Input:
%       - Calibration Data: MCalib (Nx x Ny_Calib x 1 x Nslice x Ncoil)
%       - Mask for 3D Kernel: kernel_matrix (3 x 3 x 3)
%
%   Output:
%       - kernel for 3D GRAPPA recon: kernel (3 x 3 x 3)
%
%   Author: Bahadir Alp Barlas
%   Email: bbarlas@usc.edu

[Nx, Ny, Nz, Nc] = size(MCalib);
pat = abs(MCalib)>0; pat = sum(pat,4); pat = abs(pat)>0;
kersize = size(kernel_matrix);
kernel_mat = zeros(sum(kernel_matrix,"all")*Nc,Nc);
step1 = (kersize(1)-1)/2;
step2 = (kersize(2)-1)/2;

% For kernel Mc and Ma
count = 1;
k = Nz/2 + 1;
for j=1+step2:Ny-step2
    for i=1+step1:Nx-step1
        if pat(i,j,k) == 1
            % fprintf('i: %2.f, j=%2.f, k=%2.f.\n',i,j,k);
            index = [i,j,k];
            % Mc
            Mc(count,:) = squeeze(MCalib(i,j,k,:));
            
            % Ma
            res = give_kernel_points(MCalib, index, kernel_matrix);
            res = res(:);
            Ma(count,:) = res;
            count = count + 1;
        end
    end
end


MaTMa = (Ma')*Ma;
lambda = norm(MaTMa,'fro')/size(MaTMa,1)*lambda;

% Calculate Kernels
for i=1:Nc
    kernel_mat(:,i) = inv(MaTMa + eye(size(MaTMa))*lambda)*(Ma')*Mc(:,i);
end
kernel = kernel_mat;
end
