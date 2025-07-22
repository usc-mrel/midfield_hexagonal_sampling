function kdata = myfft3(images)
[Nx, Ny, Nz, Nslice, Ncoil] = size(images);
kdata = 1/sqrt(Nz)*fftshift(fft(ifftshift(images,3),[],3),3);
kdata = myfft2c(kdata);
end