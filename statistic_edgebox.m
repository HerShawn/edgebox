%% (3） 检测算法

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
for indexImg = 195:195
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
    
    
%     figure(indexImg);
  
    %三维图
%     subplot(2,2,1);
%     [x,y]=meshgrid(1:1:wid,1:1:len);
%     mesh(double(x),double(y),double(edgebox_hx));
%     xlabel('x');
%     ylabel('y');

    row=sum(edgebox_hx,2);
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

    
    % 滑动窗滤除噪音
    windowSize=round(len/20.0);
    z_final=zeros(1, length(z_tmp));
    for i=1:length(z_tmp)
        if  z_tmp(i) == max(z_tmp(max(1,i-windowSize):min(length(z_tmp), i+windowSize)))
            z_final(i) = z_tmp(i);
        end
    end
    
    %行图及分割点
%     subplot(2,2,2);
%     plot(row,'b');hold on;
%     plot(z_final,'r');hold on;
    
    %结果图
    [m,n]=findpeaks(z_final);
    ones1=zeros(length(n),wid);
    for i=1:length(n)
        ones1(1:wid,i)=n(i);
    end
%     subplot(2,2,3);imshow(g);hold on;plot(ones1,'r');
    
    %% 3.21~3.22做的检测算法
    %1。将row_peak从小到大排列
    row_peak=zeros(2,length(n));
    for i=1:length(n)
        row_peak(1,i)=n(i);
        row_peak(2,i)=m(i);
    end    
    [~,idx]=sort(row_peak(2,:));
    row_peak(1,:)=row_peak(1,idx);
    row_peak(2,:)=row_peak(2,idx);
    
    %2。取peak最高的前4个peak(end-4:end)
    %bug:逻辑出错了：不是除前四个外的peak都删掉，
    %而是删掉前四peak包裹之外的peak；   
    for i=1:size(row_peak,2)
        if (row_peak(1,i)<min(row_peak(1,end-3:end))||...
                row_peak(1,i)>max(row_peak(1,end-3:end)))
        row_peak(1,i)=-1;
        end
    end  
    %2.1。此范围外的peak全删；
    row_peak(:,find(row_peak(1,:)<0))=[];
    %2.2。peak从小到大，beam search+col分割：
    peak=sort(row_peak(1,:));
    diff_scores=zeros(1,size(row_peak(1,:),2)-2);
    ii=1;
    for i=1:size(row_peak(1,:),2)
        %peak(i)只有一边：
        if (row_peak(1,i)==peak(end))%在最下面的边
            col=sum(edgebox_hx(peak(find(row_peak(1,i)==peak)-1):row_peak(1,i),:),1);
             
        elseif (row_peak(1,i)==peak(1))%在最上面的边
            col=sum(edgebox_hx(row_peak(1,i):peak(find(row_peak(1,i)==peak)+1),:),1);
            
        else%peak(i)有上下：
            
            %subplot(2,2,1);
            col_up=sum(edgebox_hx(peak(find(row_peak(1,i)==peak)-1):row_peak(1,i),:),1);
            %plot(col_up);
            %subplot(2,2,2);
            col_down=sum(edgebox_hx(row_peak(1,i):peak(find(row_peak(1,i)==peak)+1),:),1);
            %plot(col_down);
            %subplot(2,2,3);
            col_all=sum(edgebox_hx(peak(find(row_peak(1,i)==peak)-1):peak(find(row_peak(1,i)==peak)+1),:),1);
            %plot(col_all);
            %subplot(2,2,4);
            col_diff=col_down-(max(col_down)/max(col_up))*col_up;
            %plot(col_diff);
            diff_score=sum(abs(col_diff))/wid;
            diff_scores(ii)=diff_score;
            ii=ii+1;
        end
    end
    
    
    %%
    
%     save_name=[img_value '.jpg'];
%     print(indexImg, '-dpng', save_name);
%     clear row;
%     clear z1;
%     clear z_tmp;
%     clear z;
%     clear ones1;
%     clear ones2;
%     close(figure(indexImg));
end