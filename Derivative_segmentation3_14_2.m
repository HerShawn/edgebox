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


for indexImg = 18:18
    
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
    
    %     col=sum(edgebox_hx);
    
    
    figure(indexImg);
    
    subplot(2,2,1);
    imshow(g);
    
    subplot(2,2,2);
    [x,y]=meshgrid(1:1:wid,1:1:len);
    mesh(double(x),double(y),double(edgebox_hx));
    xlabel('x');
    ylabel('y');
    
    subplot(2,2,3);
    plot(row);
    
    row1=smooth(row,45,'lowess');
    subplot(2,2,4);
    plot(row1);
    
    
    x = 1:1:size(row,1);
    y = row;
    for i=1:length(x)-1
        z(i) = (y(i+1)-y(i))/(x(i+1)-x(i));
        %         z2(i)=y(i+1)-y(i);
    end
    
    
    x1 = 1:1:size(row1,1);
    y1 = row1;
    for i=1:length(x1)-1
        z1(i) = (y1(i+1)-y1(i))/(x1(i+1)-x1(i));
    end
    
    
    figure(indexImg+1);
    subplot(2,1,1);
    plot(z);
    subplot(2,1,2);
    plot(z1);
    
    [a,b]=findpeaks(z1);
    [a_temp,sort_idx]=sort(a,'descend');
    b_temp=b(sort_idx);
    a_diff=a_temp(1:end-1)-a_temp(2:end);
    [max_diff,idx_diff]=max(a_diff);
    a_final=a_temp(1:idx_diff);
    b_final=b_temp(1:idx_diff);
    
    [a1,b1]=findpeaks(-z1);
    [a_temp1,sort_idx1]=sort(a1,'descend');
    b_temp1=b1(sort_idx1);
    a_diff1=a_temp1(1:end-1)-a_temp1(2:end);
    [max_diff1,idx_diff1]=max(a_diff1);
    a_final1=a_temp1(1:idx_diff1);
    b_final1=b_temp1(1:idx_diff1);
    
    
    
    
    
    figure(indexImg+2);
    imshow(g);
    hold on;
    ones1=ones(idx_diff,wid);
    for i=1:idx_diff
        ones1(1:wid,i)=b_final(i);
    end
    
    ones2=ones(idx_diff1,wid);
    for i=1:idx_diff1
        ones2(1:wid,i)=b_final1(i);
    end
    
    ones3=[ones1,ones2];
    
    plot(ones3,'r+');
    
    
    
    
    %      figure(indexImg+2);
    %      imshow(g);
    %       hold on ;
    %      [max,idx]=max(z1);
    %      line_x=[1:1:wid];
    %      line_y=ones(1,wid)*idx;
    %      plot(line_x,line_y,'r+');
    %
    %      [min,idx1]=min(z1);
    %      line_x1=[1:1:wid];
    %      line_y1=ones(1,wid)*idx1;
    %      plot(line_x1,line_y1,'r+');
    %
    %      imshow(g);
    
    
    
    
    
    
    
    
    
end