function y_center = find_mask_center(data)
% Parameters
lambda = 0.001; % 0.001, 0.01 (prev best)

[Nx,Ny,Nz] = size(data);
center_z = round(Nz/2+1);
center_y = round(Ny/2);

y0_center = center_y + zeros(Nx,1);
M = data;
M(:,:,center_z-1) = 0;
M(:,:,center_z) = 0;
M(:,:,center_z+1) = 0;

% Normalize data
M = abs(M);
for i=1:Nx
   temp1 =  2*squeeze(M(i,:,:))/max(squeeze(M(i,:,:)),[],'all');
   temp2 = temp1(:,[(1:center_z-2),(center_z+2:end)]);
   temp2 = temp2.^(2.7);
   temp3 = transpose(squeeze(abs(data(i,:,center_z))));
   temp3 = -(temp3-max(temp3));
   temp3 = log(rescale(temp3)+1);
   temp4 = repmat(temp3,1,size(temp2,2)).*temp2;
   % temp4 = reshape(softmax(temp4(:)),[Ny Nz-3]);
   M(i,:,[(1:center_z-2),(center_z+2:end)]) = temp4;
end

options = optimoptions(@fmincon,'MaxFunctionEvaluations',100000);
optimizer_start = tic;
y_center = fminunc(@(y_center)calc_cost(y_center,M,Nx,Ny,Nz,lambda),y0_center);
fprintf('Total optimization duration: %2.f seconds \n', toc(optimizer_start));
end