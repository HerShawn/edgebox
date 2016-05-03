%% (3） 检测算法：statistic edgebox;binary tree search（横向和纵向）

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
for indexImg = 157:157
    
    %构建边缘响应统计图：一种特征转换方法，在边缘响应统计这个特征空间中，文字与非文字的特征区别突出，易分类
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    img_name = [do_dir 'Challenge2_Test_Task12_Images\' img_value '.jpg'];
    g = imread(img_name);
    [len,wid,~] = size(g);
    edgebox_hx=zeros(len,wid);
    tic, bbs=edgeBoxes(g,model,opts); toc
%     bbs=bbs(1:128,:);
    bbs=sortrows(bbs,-5);
    bbs(:,3)=bbs(:,1)+bbs(:,3);
    bbs(:,4)=bbs(:,2)+bbs(:,4);
    weight=[];
    
    all=size(bbs,1)
    turns=ceil(all/5);
    for i=1:all
        weight=[weight;(64/(i+15))];
    end
 for j=1:5
    for i=max((j-1)*turns,1):min(size(bbs,1),j*turns)
        edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))+weight(i,1);
        [x,y]=meshgrid(1:1:wid,1:1:len);
        mesh(double(x),double(y),double(edgebox_hx));
        xlabel('x');
        ylabel('y');
    end
 end
    
    
    
   
end