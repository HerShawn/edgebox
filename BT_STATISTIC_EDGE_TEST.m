%% 2016.5.16 Test:
%1.turn1;2.�ظ��У�3.���ӵ㣻4.��������+��ֵ+aspect��5.Ȩֵ��һ����
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
do_dir='D:\release\edgebox\edgebox-contour-neumann���ּ�ⷽ���ıȽ�\';
dir_img = dir([do_dir 'Challenge2_Test_Task12_Images\*.jpg'] );
num_img = length(dir_img);
for indexImg = 155:155   
    %������Ե��Ӧͳ��ͼ��һ������ת���������ڱ�Ե��Ӧͳ����������ռ��У�����������ֵ���������ͻ�����׷���
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    img_name = [do_dir 'Challenge2_Test_Task12_Images\' img_value '.jpg'];
    g = imread(img_name);
    [len,wid,~] = size(g);
    edgebox_hx=zeros(len,wid);
    bbs=edgeBoxes(g,model,opts); 
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
    %�����ݶȣ�Ŀ�����ڱ�Ե��Ӧͳ��ͼ�ϣ��ӱ����ж�λ������
    row=sum(edgebox_hx,2);
    row_max=max(row);    
    x = 1:1:size(row,1);
    y = row;
    for i=1:length(x)-1
        z(i) = (y(i+1)-y(i))/(x(i+1)-x(i));
    end   
    z_max=max(z);    
    %��һ�������ڹ۲��ʵ��
    for i=1:length(x)-1
        z1(i)=z(i)*(row_max/z_max)*3.5;
        z1(i)=z1(i)*(row(i)/row_max);
    end    
    [a,b]=findpeaks(abs(z1));
    z_tmp=zeros(1,length(z1));
    for i=1:length(a)
        z_tmp(b(i))=a(i);
    end    
    % �������˳�����
    windowSize=round(len/20.0);
    z_final=zeros(1, length(z_tmp));
    for i=1:length(z_tmp)
        if  z_tmp(i) == max(z_tmp(max(1,i-windowSize):min(length(z_tmp), i+windowSize)))
            z_final(i) = z_tmp(i);
        end
    end   
    %���ͼ
    [m,n]=findpeaks(z_final);
    ones1=zeros(length(n),wid);
    for i=1:length(n)
        ones1(1:wid,i)=n(i);
    end    
    %% 3.21~3.22���ļ���㷨
    %1����row_peak��С��������
    row_peak=zeros(2,length(n));
    for i=1:length(n)
        row_peak(1,i)=n(i);
        row_peak(2,i)=m(i);
    end    
    [~,idx]=sort(row_peak(2,:));
    row_peak(1,:)=row_peak(1,idx);
    row_peak(2,:)=row_peak(2,idx);    
    %2��ȡpeak��ߵ�ǰ4��peak(end-4:end)
    %ɾ��ǰ��peak����֮���peak��   
    if size(row_peak,2)>4
        for i=1:size(row_peak,2)
            if (row_peak(1,i)<min(row_peak(1,end-3:end))||...
                    row_peak(1,i)>max(row_peak(1,end-3:end)))
                row_peak(1,i)=-1;
            end
        end
    end
    %2.1���˷�Χ���peakȫɾ��
    row_peak(:,find(row_peak(1,:)<0))=[];
    %2.2�����������зָ��㷨��
     [~,idx1]=sort(row_peak(1,:));
    peak(1,:)=row_peak(1,idx1);
    peak(2,:)=row_peak(2,idx1);
    global row_table;
    global node_idx;
    table_len=(length(peak)-2)+(length(peak)-1);
    row_table=zeros(table_len,4);
    node_idx=1;       
    bt_row_seg(peak);   
    do_table=zeros(length(peak)-2,3);
    do_table=bt_row_seg2(do_table);   
 %��λ��ʶ��
    run model_release/matconvnet/matlab/vl_setupnn.m   
    for i=1:size(do_table,1)
        for j=1:3
            top=row_table(do_table(i,j),2);
            bottom=row_table(do_table(i,j),3);
            im=g(top:bottom,1:wid,:);
%             im=[im;im];
%             figure(1);
%             imshow(im);
            col_bt_se_t_test(im);            
        end
    end
end