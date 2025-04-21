function SEMSI_CC_correct_slice = reorder_slice(SEMSI_CC, Read_flags)
    SEMSI_CC_correct_slice = zeros(size(SEMSI_CC));
    size_data = size(SEMSI_CC);
    
    if length(size_data) == 4
        [Nx,Ny,Nz,Ns] = size(SEMSI_CC);
        if strcmp(Read_flags.SliceOrder, 'int')
            if mod(Ns, 2) == 0 % even # slice; interleave
                SEMSI_CC_correct_slice(:,:,:,1:2:end) = SEMSI_CC(:,:,:,Ns/2+1:end);
                SEMSI_CC_correct_slice(:,:,:,2:2:end) = SEMSI_CC(:,:,:,1:Ns/2);
            else % odd # slice; interleave
                SEMSI_CC_correct_slice(:,:,:,2:2:end) = SEMSI_CC(:,:,:,ceil(Ns/2+1):end);
                SEMSI_CC_correct_slice(:,:,:,1:2:end) = SEMSI_CC(:,:,:,1:ceil(Ns/2+1)-1);
            end
        else
            SEMSI_CC_correct_slice = SEMSI_CC;
        end
    end
    
    if length(size_data) == 5
        [Nx,Ny,Nz,Ns,Ncoils] = size(SEMSI_CC);
        if strcmp(Read_flags.SliceOrder, 'int')
            if mod(Ns, 2) == 0 % even # slice; interleave
                SEMSI_CC_correct_slice(:,:,:,1:2:end,:) = SEMSI_CC(:,:,:,Ns/2+1:end,:);
                SEMSI_CC_correct_slice(:,:,:,2:2:end,:) = SEMSI_CC(:,:,:,1:Ns/2,:);
            else % odd # slice; interleave
                SEMSI_CC_correct_slice(:,:,:,2:2:end,:) = SEMSI_CC(:,:,:,ceil(Ns/2+1):end,:);
                SEMSI_CC_correct_slice(:,:,:,1:2:end,:) = SEMSI_CC(:,:,:,1:ceil(Ns/2+1)-1,:);
            end
        else
            SEMSI_CC_correct_slice = SEMSI_CC;
        end
    end
end
