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
for indexImg = 221:221
    
    %构建边缘响应统计图：一种特征转换方法，在边缘响应统计这个特征空间中，文字与非文字的特征区别突出，易分类
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
    
    %计算梯度：目的是在边缘响应统计图上，从背景中定位出文字
    row=sum(edgebox_hx,2);
    row_max=max(row);    
    x = 1:1:size(row,1);
    y = row;
    for i=1:length(x)-1
        z(i) = (y(i+1)-y(i))/(x(i+1)-x(i));
    end   
    z_max=max(z);
    
    %归一化，便于观察和实验
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
    
    
    %结果图
    [m,n]=findpeaks(z_final);
    ones1=zeros(length(n),wid);
    for i=1:length(n)
        ones1(1:wid,i)=n(i);
    end
%     subplot(2,2,3);imshow(g);hold on;plot(ones1,'r');
%     imshow(g);hold on;
%     plot(ones1,'r');
    
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
    %删掉前四peak包裹之外的peak；   
    if size(row_peak,2)>4
        for i=1:size(row_peak,2)
            if (row_peak(1,i)<min(row_peak(1,end-3:end))||...
                    row_peak(1,i)>max(row_peak(1,end-3:end)))
                row_peak(1,i)=-1;
            end
        end
    end
    %2.1。此范围外的peak全删；
    row_peak(:,find(row_peak(1,:)<0))=[];
    %2.2。二叉树的行分割算法：
     [~,idx1]=sort(row_peak(1,:));
    peak(1,:)=row_peak(1,idx1);
    peak(2,:)=row_peak(2,idx1);
  
%     row_table=zeros(size(peak(1,2:end-1),2),3);
    %大概table_len和node_idx都不用了吧？
%    global table_len;
    global row_table;
    global node_idx;
%    table_len=size(peak(1,2:end-1),2);  
    table_len=(length(peak)-2)+(length(peak)-1);
    row_table=zeros(table_len,4);
    node_idx=1;       
    bt_row_seg(peak);
   
    do_table=zeros(length(peak)-2,3);
    do_table=bt_row_seg2(do_table);
    
 %定位、识别

    run model_release/matconvnet/matlab/vl_setupnn.m
    
    for i=1:size(do_table,1)
        for j=1:3
            top=row_table(do_table(i,j),2);
            bottom=row_table(do_table(i,j),3);
            im=g(top:bottom,1:wid,:);
            figure(1);
            imshow(im);
            col_bt_se(im);
%             figure_index=(i-1)*3+j;
%             figure(figure_index);
             
%             save_name=[num2str(figure_index) '.jpg'];
%             print(figure_index, '-dpng', save_name);
%             close
%             if size(im, 3) > 1, im = rgb2gray(im); end;
%             im = imresize(im, [32, 100]);
%             im = single(im);
%             s = std(im(:));
%             im = im - mean(im(:));
%             im = im / ((s + 0.0001) / 128.0);
%             net = load('dictnet.mat');
%             lexicon = load_nostruct('lex.mat');
%             %     stime = tic;
%             res = vl_simplenn(net, im);
%             %     fprintf('DICT Detection %.2fs\n', toc(stime));
%             [score,lexidx] = max(res(end).x(:));
%             fprintf(' %s\t%f\n', lexicon{lexidx},score);
            
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