function res = give_kernel_points(kdata, index, kernel_matrix)
% a1 = kdata(1:10,1:10,1:10,1);
% a2 = temp1(:,:,:,1);
kersize = size(kernel_matrix);
[Nx, Ny, Nz, Nc] = size(kdata);

limX = (kersize(1)-1)/2;
limY = (kersize(2)-1)/2;
limZ = (kersize(3)-1)/2;

i=index(1); j=index(2); k=index(3);

temp1 = kdata(i-limX:i+limX,j-limY:j+limY,k-limZ:k+limZ,:);
res = zeros(sum(kernel_matrix,"all"),Nc);
for t=1:Nc
    temp2 = temp1(:,:,:,t);
    temp2 = temp2(:);
    temp3 = temp2(find(kernel_matrix));
    res(:,t) = temp3;
end
end