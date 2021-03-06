%% 2016.5.16 Test:
%1.turn1;2.重复行；3.种子点；4.四线三格+阈值+aspect；5.权值归一化。
function col_bt_se_t_test(g)
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

global record_tab;
global cluster_tab;

record_tab=zeros(1,10);
cluster_tab=zeros(10,10);

[len,wid,~] = size(g);
edgebox_hx=zeros(len,wid);
bbs=edgeBoxes(g,model,opts); 
size(bbs,1)
b_num=round(0.1*size(bbs,1))

% 【1】2016.6.1 待实验确定的参数：太小起不到过滤杂质的作用；
% 太大会误删文本行，如图69中的programme就被误删了。
% 应当使其自适应；
if size(bbs,1)<100
  return;
else
    
% 【2】2016.6.1 待实验确定的参数：
% 选多少个bbs才合适？很重要；
bbs=bbs(1:min(128,2*b_num),:);
end
size(bbs,1)

bbs=sortrows(bbs,-5);
bbs(:,3)=bbs(:,1)+bbs(:,3);
bbs(:,4)=bbs(:,2)+bbs(:,4);
weight=[];

% bbs1(:,1)=bbs(:,1);
% bbs1(:,2)=bbs(:,2);
% bbs1(:,3)=bbs(:,3)-bbs1(:,1);
% bbs1(:,4)=bbs(:,4)-bbs1(:,1);

all=size(bbs,1);
turns=ceil(all/5)

% 【3】2016.6.1 待实验确定的参数：
%权值的选择！ 要实现权值均一化
for i=1:all
      weight=[weight;(64/(i+7))];
end

left_edge_cluster=zeros(1,wid);

% 【4】2016.6.1 待实验确定的参数：
%自适应调整turn大小
for j=1:1
    for i=max((j-1)*turns,1):min(size(bbs,1),j*turns)
        %2016.6.5 聚集边缘去除离群点
        figure(4);
        left_edge_cluster(1,bbs(i,1))=left_edge_cluster(1,bbs(i,1))+1;
        plot(left_edge_cluster);
        
        %2016.6.3 显示边缘盒
        figure(1);
        imshow(g);        
        bbGt('showRes',g,[bbs(i,1);bbs(i,2);bbs(i,3)-bbs(i,1);bbs(i,4)-bbs(i,2)]',[bbs(i,1);bbs(i,2);bbs(i,3)-bbs(i,1);bbs(i,4)-bbs(i,2)]');
%         hold on;
        %
        edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))+weight(i,1);
        %2016.6.3 要做的权值归一化
        ccol=sum(edgebox_hx,1);   
%         ccol=sum(edgebox_hx,1)/ size(edgebox_hx,1);  
    
        figure(2);
        plot(ccol);
%         figure(3);
%         imshow(edgebox_hx);
        island_table(ccol);
    end    
end


%2016.6.9 边缘聚集去除离散边缘
% 消除左点
left_edge_cluster2=eli_outliers(left_edge_cluster);
lc=find(left_edge_cluster2>0);
cluster_num=length(lc);
l2=zeros(1,cluster_num);
for i=1:cluster_num
    l2(1,i)=size(edgebox_hx,1);
end
% 消除右点


figure(1);
hold on
for i=1:cluster_num
    stem(lc(1,i),l2(1,i),'r');
end
hold off

%在这儿处理global record_tab和cluster_tab；


%     ini_cluster=cluster_tab( find(record_tab==max(record_tab)),:)
    if length(find(record_tab==max(record_tab)))==1
        ini_cluster=cluster_tab( find(record_tab==max(record_tab)),:);
    else
        record_idx=find(record_tab==max(record_tab));
%         ini_cluster=cluster_tab( ceil(length(find(record_tab==max(record_tab)))/2),:);
        ini_cluster=cluster_tab( record_idx(1,ceil(length(find(record_tab==max(record_tab)))/2)),:);
    end   
    ini_cluster=ini_cluster(ini_cluster~=0);
%     figure(2);
%     plot(ccol);
    line_len=size(edgebox_hx,1);
    line_seg=zeros(2,length(ini_cluster));
    for i=1:length(ini_cluster)
        line_seg(1,i)=ini_cluster(1,i);
        line_seg(2,i)=line_len;
    end
    figure(3);
     imshow(edgebox_hx);
    hold on
    for i=1:length(ini_cluster)
          stem(line_seg(1,i),line_seg(2,i),'g');
    end  
    hold off
end