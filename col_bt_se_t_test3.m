%% 2016.6.27 
%1.turn放宽；2.滤除aspect不符的边缘响应；3.抹平毛刺
function col_bt_se_t_test3(g)
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
bbs=edgeBoxes(g,model,opts); 
size(bbs,1)
b_num=round(0.1*size(bbs,1))

if size(bbs,1)<100
  return;
else

bbs=bbs(1:min(128,2*b_num),:);
end
size(bbs,1)

bbs=sortrows(bbs,-5);
bbs(:,3)=bbs(:,1)+bbs(:,3);
bbs(:,4)=bbs(:,2)+bbs(:,4);
weight=[];

all=size(bbs,1);
turns=ceil(all/5)

for i=1:all
      weight=[weight;(64/(i+7))];
end

for j=1:3  %turn放宽
    for i=max((j-1)*turns,1):min(size(bbs,1),j*turns)     
        %2016.6.3 显示边缘盒
        figure(1);
        imshow(g);        
        bbGt('showRes',g,[bbs(i,1);bbs(i,2);bbs(i,3)-bbs(i,1);bbs(i,4)-bbs(i,2)]',[bbs(i,1);bbs(i,2);bbs(i,3)-bbs(i,1);bbs(i,4)-bbs(i,2)]');
        %aspect宽高比 限制不符的边缘响应
        rwidth=bbs(i,3)-bbs(i,1)
        rlength=bbs(i,4)-bbs(i,2)
        if rwidth/rlength>1
            edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))+weight(i,1);
             edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=mean(mean(edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))));
        end
        %2016.6.3 要做的权值归一化 2016.6.27 抹平毛刺
        ccol=sum(edgebox_hx,1);   

        figure(2);
        plot(ccol);
    end    
end
    figure(3);
    imshow(edgebox_hx);
end