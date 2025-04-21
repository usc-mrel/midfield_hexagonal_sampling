function SEMAC_Recon = SEMAC_combination(SEMAC_CC_correct_slice)
[Nx,Ny,Nz,Nslice] = size(SEMAC_CC_correct_slice);
SEMAC_Recon = zeros(size(SEMAC_CC_correct_slice,1,2,4));

for ss = 1:Nslice
    sum = 0;
    for ii = 0:Nz-1
        index_SEMAC = Nz-ii;
        index_slice = ss-floor(Nz/2)+1+ii;
        if index_slice>0 && index_slice<=Nslice
            sum = sum + abs(SEMAC_CC_correct_slice(:,:,index_SEMAC,index_slice)).^2;
        end
    end
    SEMAC_Recon(:,:,ss) = sqrt(sum);
end
end

