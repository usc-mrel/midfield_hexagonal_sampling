function images = myifft3(kdata)
[Nx, Ny, Nz, Nslice, Ncoil] = size(kdata);
images = sqrt(Nz)*fftshift(ifft(ifftshift(kdata,3),[],3),3);
images = myifft2c(images);
end