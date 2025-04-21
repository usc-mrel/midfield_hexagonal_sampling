function x_est = estimate_phcor_old(kdata_profile)
% Estimiate 0 and 1st order of phase for each pre-scan data by least-square
% x_est: 0 and 1st order [2 x Nc]
% Bochao Li 
% 07/22/2023

phcor_data_fft_angle = unwrap(angle(fftshift(fft(ifftshift(kdata_profile, 1),[], 1), 1))); % calculate the phase along RO direction
[Nsample,Nc] = size(phcor_data_fft_angle);
sample_idx = (-floor(Nsample/2):ceil(Nsample/2)-1).'/Nsample;
A = [ones(Nsample,1), sample_idx];

x_est = zeros([size(A,2),Nc]); % [2 x Nc]
for nc = 1:Nc
    b = phcor_data_fft_angle(:,nc);
    x_est(:,nc) = inv(A'*A)*A'*b; 
end


end

