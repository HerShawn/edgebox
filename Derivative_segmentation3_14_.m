clc
clear
close all
% warning off all


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


for indexImg = 1:1
    
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    
    img_name = [do_dir 'Challenge2_Test_Task12_Images\' img_value '.jpg'];
    g = imread(img_name);
    
    
    %     edgebox_mser=rgb2gray(g);
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
    
    row=sum(edgebox_hx,2);
    
    col=sum(edgebox_hx);
    
    
%     figure(indexImg);
%     
%     subplot(2,2,1);
%     imshow(g);
%     
%     subplot(2,2,2);
%     [x,y]=meshgrid(1:1:wid,1:1:len);
%     mesh(double(x),double(y),double(edgebox_hx));
%     xlabel('x');
%     ylabel('y');
%     
%     subplot(2,2,3);
%     plot(row);
%     
%     subplot(2,2,4);
%     plot(col);
    
    
    %     save_name=[img_value '.jpg'];
    %     print(indexImg, '-dpng', save_name);
    
    figure(indexImg);
    
    s(1)=subplot(3,2,1);
    plot(row);
    title(s(1),'row');
    
    
    s(2)=subplot(3,2,2);   
    row1=smooth(row,30);						%移动平均法
    plot(row1);
    title(s(2),'移动平均法');
    
    s(3)=subplot(3,2,3);
    row2=smooth(row,30,'lowess');				%利用lowess方法
    plot(row2);
    title(s(3),'lowess方法');
    
    s(4)=subplot(3,2,4);  
    row3=smooth(row,30,'rlowess');			%利用rlowess方法
    plot(row3);
    title(s(4),'rlowess方法');

    s(5)=subplot(3,2,5);    
    row4=smooth(row,30,'loess');				%利用loess方法
    plot(row4);
    title(s(5),'loess方法');
    
    s(6)=subplot(3,2,6);    
    row5=smooth(row,30,'sgolay',3);			%利用sgolay方法
    plot(row5);
    title(s(6),'sgolay方法');
 
    save_name=[img_value '.jpg'];
    print(indexImg, '-dpng', save_name);
    
    
    
    
    
end