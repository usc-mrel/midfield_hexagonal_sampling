function SEMSI_coils_correct_slice = reorder_slice_coils(SEMSI_coils, Read_flags, Ns)
    SEMSI_coils_correct_slice = zeros(size(SEMSI_coils));
    
    if strcmp(Read_flags.SliceOrder, 'int')
        if mod(Ns, 2) == 0 % even # slice; interleave
            SEMSI_coils_correct_slice(:,:,:,:,1:2:end) = SEMSI_coils(:,:,:,:,Ns/2+1:end);
            SEMSI_coils_correct_slice(:,:,:,:,2:2:end) = SEMSI_coils(:,:,:,:,1:Ns/2);
        else % odd # slice; interleave
            SEMSI_coils_correct_slice(:,:,:,:,2:2:end) = SEMSI_coils(:,:,:,:,ceil(Ns/2+1):end);
            SEMSI_coils_correct_slice(:,:,:,:,1:2:end) = SEMSI_coils(:,:,:,:,1:ceil(Ns/2+1)-1);
        end
    else
        SEMSI_coils_correct_slice = SEMSI_coils;
    end
end
