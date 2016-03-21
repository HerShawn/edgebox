%% (2）滑动窗

clc
clear
close all
addpath('piotr_toolbox');
addpath(genpath(pwd));
%% Parameters for EdgeBox
model=load('models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect
%%
do_dir='D:\release\edgebox\edgebox-contour-neumann三种检测方法的比较\';
dir_img = dir([do_dir 'Challenge2_Test_Task12_Images\*.jpg'] );
num_img = length(dir_img);
for indexImg = 1:num_img
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    img_name = [do_dir 'Challenge2_Test_Task12_Images\' img_value '.jpg'];
    g = imread(img_name);
    [len,wid,~] = size(g);
    edgebox_hx=zeros(len,wid);
    tic, bbs=edgeBoxes(g,model,opts); toc
    bbs=bbs(1:128,:);
    bbs=sortrows(bbs,-5);
    bbs(:,3)=bbs(:,1)+bbs(:,3);
    bbs(:,4)=bbs(:,2)+bbs(:,4);
    weight=[];
    for i=1:128
        weight=[weight;(64/(8+(i-1)))];
    end
    for i=1:128
        edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))+weight(i,1);
    end
    
    
    figure(indexImg);
      
    subplot(2,2,1);
    [x,y]=meshgrid(1:1:wid,1:1:len);
    mesh(double(x),double(y),double(edgebox_hx));
    xlabel('x');
    ylabel('y');

    row=sum(edgebox_hx,2);
%     plot(row,'b');hold on;
    row_max=max(row);
    
    x = 1:1:size(row,1);
    y = row;
    for i=1:length(x)-1
        z(i) = (y(i+1)-y(i))/(x(i+1)-x(i));
    end
    
    z_max=max(z);
    
    for i=1:length(x)-1
        z1(i)=z(i)*(row_max/z_max)*3.5;
        z1(i)=z1(i)*(row(i)/row_max);
    end
    
    [a,b]=findpeaks(abs(z1));
    z_tmp=zeros(1,length(z1));
    for i=1:length(a)
        z_tmp(b(i))=a(i);
    end
    
%     plot(z_tmp,'r');hold on;
    
    %% 滑动窗滤除噪音
    windowSize=round(len/20.0);
    z_final=zeros(1, length(z_tmp));
    for i=1:length(z_tmp)
        if  z_tmp(i) == max(z_tmp(max(1,i-windowSize):min(length(z_tmp), i+windowSize)))
            z_final(i) = z_tmp(i);
        end
    end
    subplot(2,2,2);
    plot(row,'b');hold on;
    plot(z_final,'r');hold on;
    
    [m,n]=findpeaks(z_final);
    ones1=ones(length(n),wid);
    for i=1:length(n)
        ones1(1:wid,i)=n(i);
    end
    subplot(2,2,3:4);imshow(g);hold on;plot(ones1,'r');
    
    %%
    
    save_name=[img_value '.jpg'];
    print(indexImg, '-dpng', save_name);
    clear row;
    clear z1;
    clear z_tmp;
    clear z;
    close(figure(indexImg));
end