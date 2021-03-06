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
    
    row1=smooth(row,45,'lowess');
%     subplot(2,2,4);
%     plot(row1);
%     
%     
    x = 1:1:size(row,1);
    y = row;
    for i=1:length(x)-1
        z(i) = (y(i+1)-y(i))/(x(i+1)-x(i));
    end
    
    
    x1 = 1:1:size(row1,1);
    y1 = row1;
    for i=1:length(x1)-1
        z1(i) = (y1(i+1)-y1(i))/(x1(i+1)-x1(i));
    end
%        
%     figure(indexImg+1);
%     subplot(2,1,1);
%     plot(z);
%     subplot(2,1,2);
%     plot(z1);
       
    [a,b]=findpeaks(z1);
%     [aa,bb]=findpeaks(z,'MINPEAKDISTANCE',2);
    [a1,b1]=findpeaks(-z1);
    [~,idx]=max(z1);
    [~,idx1]=min(z1);
    
    b_temp=b(find(b>=idx));
    b=b_temp(find(b_temp<=idx1));
    
    
    b_temp1=b1(find(b1>=idx));
    b1=b_temp1(find(b_temp1<=idx1));
    
 
     [za,zb]=findpeaks(z);
%     [aa,bb]=findpeaks(z,'MINPEAKDISTANCE',2);
    [za1,zb1]=findpeaks(-z);
    [~,zidx]=max(z);
    [~,zidx1]=min(z);
    
    zb_temp=zb(find(zb>=zidx));
    zb=zb_temp(find(zb_temp<=zidx1));
    
    
    zb_temp1=zb1(find(zb1>=zidx));
    zb1=zb_temp1(find(zb_temp1<=zidx1));
    
    
    
    
    
    figure(indexImg);
%     imshow(g);
%     hold on;
    ones1=ones(length(b),wid);
    for i=1:length(b)
        ones1(1:wid,i)=b(i);
    end
    
    ones2=ones(length(b1),wid);
    for i=1:length(b1)
        ones2(1:wid,i)=b1(i);
    end   
     ones3=[ones1,ones2];
   
     
     
      zones1=ones(length(zb),wid);
    for i=1:length(zb)
        zones1(1:wid,i)=zb(i);
    end
    
    zones2=ones(length(zb1),wid);
    for i=1:length(zb1)
        zones2(1:wid,i)=zb1(i);
    end   
     zones3=[zones1,zones2];
     
     
    subplot(1,2,2);imshow(g);hold on;plot(ones3,'g-');
    subplot(1,2,1);imshow(g);hold on;plot(zones3,'g-');
    save_name=[img_value '.jpg'];
    print(indexImg, '-dpng', save_name);
 
end