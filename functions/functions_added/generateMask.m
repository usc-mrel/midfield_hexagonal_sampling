function mask = generateMask(Ny,Nz,mask_type,opt)
%   Generate mask for removing replicas in hexagonally sampled data
%   Input:
%       - # of pixels in y-direction: Ny
%       - # of SEMAC spectral bins: Nz
%       - Mask Type: mask_type (See section titles below)
%       - Show Mask Option: opt
%
%   Output:
%       - Mask: mask (Ny x Nz)
%
%   Author: Bahadir Alp Barlas
%   Email: bbarlas@usc.edu

addReplicas = 0;

%% Cross Regular
if mask_type == 1
    mask = zeros(Ny,Nz);
    mask(:,Nz/2:Nz/2+1) = 1;
    mask(Ny/4+1:Ny*3/4,2:Nz-1) = 1;

    if opt == 1
        mask_showed = showMask(mask,addReplicas);
        f1 = figure();
        imshow((mask_showed),[]); xlabel("y",'FontSize', 20); ylabel("f",'FontSize', 20);
        title("Cross Regular",'FontSize', 20); set(f1,'color','w');
        hold on; line([260 260], [241 480],'color','k');
        hold on; line([520 520], [241 480],'color','k');
        hold on; line([260 520], [241 241],'color','k');
        hold on; line([260 520], [480 480],'color','k');
        total = sum(mask,'all');
        disp("Cross Regular: "+total*100/Ny/Nz+"%");
    end
end

%% Diamond Regular
if mask_type == 2
    mask = zeros(Ny,Nz);
    size_mask_arr = zeros(Nz/2,1);
    for i = 1:length(size_mask_arr)
        size_mask_arr(i) = round(Ny*(i-1)/(Nz/2-1));
    end
    if rem(Nz/2,2) == 0
        for i = 1:Nz/4-1
            temp = size_mask_arr(i+1)+size_mask_arr(end-i)-Ny;
            size_mask_arr(end-i) = size_mask_arr(end-i) - temp;
        end
    else
        for i = 1:ceil(Nz/4)-2
            temp = size_mask_arr(i+1)+size_mask_arr(end-i)-Ny;
            size_mask_arr(end-i) = size_mask_arr(end-i) - temp;
        end
    end
    for i=1:floor(length(size_mask_arr)/2)
        if rem(size_mask_arr(i),2) == 1 && rem(size_mask_arr(end+1-i),2) == 1
            size_mask_arr(i) = size_mask_arr(i) + 1;
            size_mask_arr(end+1-i) = size_mask_arr(end+1-i) - 1;
        end
    end
    for i=1:Nz/2
        start = (Ny-size_mask_arr(i))/2;
        mask(start+1:start+size_mask_arr(i),i) = 1;
        mask(start+1:start+size_mask_arr(i),end-i+1) = 1;
    end

    if opt == 1
        mask_showed = showMask(mask,addReplicas);
        f1 = figure();
        imshow((mask_showed),[]); xlabel("y",'FontSize', 20); ylabel("f",'FontSize', 20);
        title("Diamond Regular",'FontSize', 20); set(f1,'color','w');
        hold on; line([260 260], [241 480],'color','k');
        hold on; line([520 520], [241 480],'color','k');
        hold on; line([260 520], [241 241],'color','k');
        hold on; line([260 520], [480 480],'color','k');
        total = sum(mask,'all');
        disp("Diamond Regular: "+total*100/Ny/Nz+"%");
    end
end

%% Cross 3-bin
if mask_type == 3
    mask = zeros(Ny,Nz);
    mask(:,Nz/2:Nz/2+2) = 1;
    mask(round(Ny/4+1):round(Ny*3/4),3:Nz-1) = 1;

    if opt == 1
        mask_showed = showMask(mask,addReplicas);
        f1 = figure();
        imshow((mask_showed),[]); xlabel("y",'FontSize', 20); ylabel("f",'FontSize', 20);
        title("Cross 3-bin",'FontSize', 20); set(f1,'color','w');
        hold on; line([260 260], [241 480],'color','k');
        hold on; line([520 520], [241 480],'color','k');
        hold on; line([260 520], [241 241],'color','k');
        hold on; line([260 520], [480 480],'color','k');
        total = sum(mask,'all');
        disp("Cross 3-bin: "+total*100/Ny/Nz+"%");
    end
end

%% Cross 1-bin
if mask_type == 4
    mask = zeros(Ny,Nz);
    mask(:,Nz/2+1) = 1;
    mask(round(Ny/4+1):round(Ny*3/4),2:Nz) = 1;

    if opt == 1
        mask_showed = showMask(mask,addReplicas);
        f1 = figure();
        imshow((mask_showed),[]); xlabel("y",'FontSize', 20); ylabel("f",'FontSize', 20);
        title("Cross 1-bin",'FontSize', 20); set(f1,'color','w');
        hold on; line([260 260], [241 480],'color','k');
        hold on; line([520 520], [241 480],'color','k');
        hold on; line([260 520], [241 241],'color','k');
        hold on; line([260 520], [480 480],'color','k');
        total = sum(mask,'all');
        disp("Cross 1-bin: "+total*100/Ny/Nz+"%");
    end
end

%% Diamond 1-bin
if mask_type == 5
    mask = zeros(Ny,Nz);
    size_mask_arr = zeros(Nz/2+1,1);
    for i = 1:length(size_mask_arr)
        size_mask_arr(i) = round(Ny*(i-1)/(Nz/2));
    end
    if rem(Nz/2,2) == 0
        for i = 1:Nz/4-1
            temp = size_mask_arr(i+1)+size_mask_arr(end-i)-Ny;
            size_mask_arr(end-i) = size_mask_arr(end-i) - temp;
        end
    else
        for i = 1:ceil(Nz/4)-2
            temp = size_mask_arr(i+1)+size_mask_arr(end-i)-Ny;
            size_mask_arr(end-i) = size_mask_arr(end-i) - temp;
        end
    end
    for i=1:floor(length(size_mask_arr)/2)
        if rem(size_mask_arr(i),2) == 1 && rem(size_mask_arr(end+1-i),2) == 1
            size_mask_arr(i) = size_mask_arr(i) + 1;
            size_mask_arr(end+1-i) = size_mask_arr(end+1-i) - 1;
        end
    end
    for i=1:Nz/2
        start = (Ny-size_mask_arr(i+1))/2;
        mask(start+1:start+size_mask_arr(i+1),i+1) = 1;
        mask(start+1:start+size_mask_arr(i+1),end-i+1) = 1;
    end

    % mask(:,2) = 0;
    % mask(:,Nz/2+2) = 1;

    if opt == 1
        mask_showed = showMask(mask,addReplicas);
        f1 = figure();
        imshow((mask_showed),[]); xlabel("y",'FontSize', 20); ylabel("f",'FontSize', 20);
        title("Diamond 1-bin",'FontSize', 20); set(f1,'color','w');
        hold on; line([260 260], [241 480],'color','k');
        hold on; line([520 520], [241 480],'color','k');
        hold on; line([260 520], [241 241],'color','k');
        hold on; line([260 520], [480 480],'color','k');
        total = sum(mask,'all');
        disp("Diamond 1-bin: "+total*100/Ny/Nz+"%");
    end
end

%% Diamond 3-bin
if mask_type == 6
    mask = zeros(Ny,Nz);
    size_mask_arr = zeros(Nz/2,1);
    for i = 1:length(size_mask_arr)
        size_mask_arr(i) = round(Ny*(i-1)/(Nz/2-1));
    end
    if rem(Nz/2,2) == 0
        for i = 1:Nz/4-1
            temp = size_mask_arr(i+1)+size_mask_arr(end-i)-Ny;
            size_mask_arr(end-i) = size_mask_arr(end-i) - temp;
        end
    else
        for i = 1:ceil(Nz/4)-2
            temp = size_mask_arr(i+1)+size_mask_arr(end-i)-Ny;
            size_mask_arr(end-i) = size_mask_arr(end-i) - temp;
        end
    end
    for i=1:floor(length(size_mask_arr)/2)
        if rem(size_mask_arr(i),2) == 1 && rem(size_mask_arr(end+1-i),2) == 1
            size_mask_arr(i) = size_mask_arr(i) + 1;
            size_mask_arr(end+1-i) = size_mask_arr(end+1-i) - 1;
        end
    end
    for i=1:Nz/2
        start = round((Ny-size_mask_arr(i))/2);
        mask(start+1:start+size_mask_arr(i),i) = 1;
        mask(start+1:start+size_mask_arr(i),end-i+1) = 1;
    end

    mask(:,2) = 0;
    mask(:,Nz/2+2) = 1;

    if opt == 1
        mask_showed = showMask(mask,addReplicas);
        f1 = figure();
        imshow((mask_showed),[]); xlabel("y",'FontSize', 20); ylabel("f",'FontSize', 20);
        title("Diamond Siemens",'FontSize', 20); set(f1,'color','w');
        hold on; line([260 260], [241 480],'color','k');
        hold on; line([520 520], [241 480],'color','k');
        hold on; line([260 520], [241 241],'color','k');
        hold on; line([260 520], [480 480],'color','k');
        total = sum(mask,'all');
        disp("Diamond Siemens: "+total*100/Ny/Nz+"%");
    end
end

end

function mask_showed = showMask(mask,addReplicas)
if addReplicas == 0
    mask_showed = transpose(imresize(mask, [size(mask,1) size(mask,2)*20],'nearest'));
else
    [Ny,Nz] = size(mask);
    mask_inverse = abs(mask-1);
    temp = zeros(Ny,Nz,3);
    temp(:,:,1) = (213*mask + 0*mask_inverse)/256;
    temp(:,:,2) = (94*mask + 114*mask_inverse)/256;
    temp(:,:,3) = (0*mask + 178*mask_inverse)/256;
    image_final = [temp,temp,temp;temp,temp,temp;temp,temp,temp];
    image_final = permute(image_final,[2 1 3]);
    mask_showed = imresize3(image_final, [size(image_final,1)*20....
        size(image_final,2) size(image_final,3)],'nearest');
    
end

% function mask_showed = showMask(mask,addReplicas)
% if addReplicas == 0
%     mask_showed = transpose(imresize(mask, [size(mask,1) size(mask,2)*20],'nearest'));
% else
%     [Ny,Nz] = size(mask);
%     image_final = zeros(3*Ny,3*Nz,3);
%     temp = zeros(Ny,Nz);
%     image = [temp,temp,temp;temp,mask,temp;temp,temp,temp];
% 
%     % Add images
%     temp = zeros(Ny*3,Nz*3,3);
%     temp(:,:,1) = image; % temp(:,:,2) = image; temp(:,:,3) = image;
%     image_final = image_final + temp;
%     
%     temp = zeros(Ny*3,Nz*3,3);
%     temp_2 = circshift(image,Ny/2,1);
%     temp_2 = circshift(temp_2,Nz/2,2);
%     temp(:,:,3) = temp_2;
%     image_final = image_final + temp;
% 
%     temp = zeros(Ny*3,Nz*3,3);
%     temp_2 = circshift(image,-Ny/2,1);
%     temp_2 = circshift(temp_2,-Nz/2,2);
%     temp(:,:,3) = temp_2;
%     image_final = image_final + temp;
% 
%     temp = zeros(Ny*3,Nz*3,3);
%     temp_2 = circshift(image,-Ny/2,1);
%     temp_2 = circshift(temp_2,Nz/2,2);
%     temp(:,:,3) = temp_2;
%     image_final = image_final + temp;
% 
%     temp = zeros(Ny*3,Nz*3,3);
%     temp_2 = circshift(image,Ny/2,1);
%     temp_2 = circshift(temp_2,-Nz/2,2);
%     temp(:,:,3) = temp_2;
%     image_final = image_final + temp;
% 
%     temp = zeros(Ny*3,Nz*3,3);
%     temp_2 = circshift(image,Ny,1);
%     temp_2 = circshift(temp_2,0,2);
%     temp(:,:,1) = temp_2;
%     image_final = image_final + temp;
% 
%     temp = zeros(Ny*3,Nz*3,3);
%     temp_2 = circshift(image,-Ny,1);
%     temp_2 = circshift(temp_2,0,2);
%     temp(:,:,1) = temp_2;
%     image_final = image_final + temp;
% 
%     temp = zeros(Ny*3,Nz*3,3);
%     temp_2 = circshift(image,0,1);
%     temp_2 = circshift(temp_2,Nz,2);
%     temp(:,:,1) = temp_2;
%     image_final = image_final + temp;
% 
%     temp = zeros(Ny*3,Nz*3,3);
%     temp_2 = circshift(image,0,1);
%     temp_2 = circshift(temp_2,-Nz,2);
%     temp(:,:,1) = temp_2;
%     image_final = image_final + temp;
% 
%     image_final = permute(image_final,[2 1 3]);
%     mask_showed = imresize3(image_final, [size(image_final,1)*20....
%         size(image_final,2) size(image_final,3)],'nearest');
%     
% end
end
