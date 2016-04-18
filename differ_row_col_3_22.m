%% (3�� ����㷨

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
for indexImg = 122:122
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
  
    %��άͼ
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

    
    % �������˳�����
    windowSize=round(len/20.0);
    z_final=zeros(1, length(z_tmp));
    for i=1:length(z_tmp)
        if  z_tmp(i) == max(z_tmp(max(1,i-windowSize):min(length(z_tmp), i+windowSize)))
            z_final(i) = z_tmp(i);
        end
    end
    
    %��ͼ���ָ��
%     subplot(2,2,2);
%     plot(row,'b');hold on;
%     plot(z_final,'r');hold on;
    
    %���ͼ
    [m,n]=findpeaks(z_final);
    ones1=zeros(length(n),wid);
    for i=1:length(n)
        ones1(1:wid,i)=n(i);
    end
%     subplot(2,2,3);imshow(g);hold on;plot(ones1,'r');
    
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
    %2��������Сpeak������&&��Сpeak<�����peak/10��,ɾ��peak��
    %�����˹��̣�ֱ����Сpeak��������㣬��С��peak/20��
    %�ؼ��㣺Ҫ��row_peak(2,i)<(max(row_peak(2,:))/15.0)������Ӧ�����ͺ���
    i=1;
    while i<=size(row_peak,2)
        if((row_peak(1,i)==max(row_peak(1,:))||(row_peak(1,i)==min(row_peak(1,:))))&&...
                row_peak(2,i)<(max(row_peak(2,:))/15.0))
           row_peak(:,i)=[];  
           i=0;
        end
        i=i+1;
    end
    
   
    
    %����2��ɾȥ�˽�һ�������
    
    %3����row������row��col�ָ��ߣ�һ������������ߺ͵��ʼ���ߣ���
    %Ӧ����peakС�������ںϣ��ںϹ��������¡����ϡ����µ�col�ָ���һ�£�
    %ɾȥ��Ӧpeak��
    
    %������
    
    ones2=zeros(size(row_peak,2),wid);
    for i=1:size(row_peak,2)
        ones2(1:wid,i)=row_peak(1,i);
    end
    subplot(1,1,1);imshow(g);hold on;plot(ones2,'r');
    %%
    
    save_name=[img_value '.jpg'];
    print(indexImg, '-dpng', save_name);
    clear row;
    clear z1;
    clear z_tmp;
    clear z;
    clear ones1;
    clear ones2;
    close(figure(indexImg));
end