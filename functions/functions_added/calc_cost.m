function cost = calc_cost(y_center,M,Nx,Ny,Nz,lambda)
cost = 0;
for i=1:Nx
    for j=1:Ny
        for k=1:Nz
            cost = cost + abs(M(i,j,k))*((y_center(i)-j)/Ny)^2;
        end
    end
end
diff_y = diff(y_center).^2;
cost = cost + lambda*sum(diff_y);
end