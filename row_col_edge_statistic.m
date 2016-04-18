clc
clear
close all
% warning off all

addpath('C:\Users\Administrator\Desktop\edge box\release\piotr_toolbox');
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


for indexImg = 122:122
    
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    
    img_name = [do_dir 'Challenge2_Test_Task12_Images\' img_value '.jpg'];
    g = imread(img_name);
    
    
    %     edgebox_mser=rgb2gray(g);
    [len,wid,~] = size(g);
    edgebox_hx=zeros(len,wid);
    %     for i=1:len
    %        for j=1:wid
    %            edgebox_mser(i,j)=0;
    %        end
    %     end
    
    
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
%     bbGt('showRes',g,double(bbs),double(bbs));
%     row=sum(edgebox_hx,2);
%     plot(row);
    col=sum(edgebox_hx,1);
    plot(col);
    save_name=[img_value '.jpg'];
    print(indexImg, '-dpng', save_name);
    
    
    %     title('green=matched gt  red=missed gt  dashed-green=matched detect');
end