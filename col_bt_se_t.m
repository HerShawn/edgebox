function col_bt_se(g)
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

[len,wid,~] = size(g);
edgebox_hx=zeros(len,wid);
tic, bbs=edgeBoxes(g,model,opts); toc
% bbs=bbs(1:min(128,size(bbs,1)),:);

bbs=sortrows(bbs,-5);
bbs(:,3)=bbs(:,1)+bbs(:,3);
bbs(:,4)=bbs(:,2)+bbs(:,4);
weight=[];

%【重要参数1】调整权值
%【使得文字与非文字间差异增强；文字间尽量平稳】
%【抑制非文字的权值】
for i=1:size(bbs,1)
%     weight=[weight;(64/(8+(i-1)))];
    weight=[weight;1];
end

all=size(bbs,1);
turns=ceil(all/2);

for j=1:turns
    for i=max((j-1)*2,1):min(size(bbs,1),j*2)
        edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))+weight(i,1);
        ccol=sum(edgebox_hx,1);
        figure(3);
        plot(ccol);
    end
end


%【重要参数2】用均值代替max(max(edgebox_hx))
%【重要参数3】分割阈值选取；怎样结合：0.2做定位？0.3做分割
 max_thresh=0.1*max(max(edgebox_hx));
% max_thresh=0.5*max(ccol);
figure(4);
for x=1:len
   for y=1:wid
       if edgebox_hx(x,y)<max_thresh;
           edgebox_hx(x,y)=0;
       end
   end
end    
imshow(edgebox_hx);

max_thresh=0.2*max(max(edgebox_hx));
figure(5);
for x=1:len
   for y=1:wid
       if edgebox_hx(x,y)<max_thresh;
           edgebox_hx(x,y)=0;
       end
   end
end    
imshow(edgebox_hx);

max_thresh=0.3*max(max(edgebox_hx));
figure(6);
for x=1:len
   for y=1:wid
       if edgebox_hx(x,y)<max_thresh;
           edgebox_hx(x,y)=0;
       end
   end
end    
imshow(edgebox_hx);

max_thresh=0.4*max(max(edgebox_hx));
figure(7);
for x=1:len
   for y=1:wid
       if edgebox_hx(x,y)<max_thresh;
           edgebox_hx(x,y)=0;
       end
   end
end    
imshow(edgebox_hx);

% all=size(bbs,1);
% turns=ceil(all/5);

% for j=1:5
%     for i=max((j-1)*turns,1):min(size(bbs,1),j*turns)
%         edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))+weight(i,1);
%         ccol=sum(edgebox_hx,1);
%         figure(3);
%         plot(ccol);
%     end
% end



% ccol=sum(edgebox_hx,1);
% figure(3);
% plot(ccol);


% if i==1
%     edgebox_hx_1=edgebox_hx;
% end
% if i==4
%     edgebox_hx_4=edgebox_hx;
% end
% if i==8
%     edgebox_hx_8=edgebox_hx;
% end
% if i==16
%     edgebox_hx_16=edgebox_hx;
% end
% if i==32
%     edgebox_hx_32=edgebox_hx;
% end
% if i==64
%     edgebox_hx_64=edgebox_hx;
% end
% if i==128
%     edgebox_hx_128=edgebox_hx;
% end
% if i==256
%     edgebox_hx_256=edgebox_hx;
% end


end