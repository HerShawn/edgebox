%% (1）NMS抑制非PEAK，先滤去一部分

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
for indexImg = 19:19 
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
    row=sum(edgebox_hx,2);
    plot(row,'b');hold on;
    row_max=max(row);
      
    x = 1:1:size(row,1);
    y = row;
    for i=1:length(x)-1
        z(i) = (y(i+1)-y(i))/(x(i+1)-x(i));
    end
    %NMS，抑制非peak，
    
    z_max=max(z);
    
%     plot(z_tmp,'g');hold on;
    for i=1:length(x)-1   
    z1(i)=z(i)*(row_max/z_max)*3.5;
    z1(i)=z1(i)*(row(i)/row_max);
%     z1_max=max(z1);
%     z1(i)=z1(i)*(row_max/z1_max);   
    end
    
    plot(abs(z1),'r');hold on;
    
    [a,b]=findpeaks(abs(z1));
    z_tmp=zeros(1,length(z1));
    for i=1:length(a)
        z_tmp(b(i))=a(i);
    end
    
    plot(z_tmp,'g');hold on;
    %plot(abs(z1),'r');hold on;
  
    save_name=[img_value '.jpg'];
    print(indexImg, '-dpng', save_name);
    clear row;
    clear z1;
    clear z_tmp;
    clear z;
    close(figure(indexImg));
end