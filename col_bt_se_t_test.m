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

[len,wid,~] = size(g);
edgebox_hx=zeros(len,wid);
tic, bbs=edgeBoxes(g,model,opts); toc
size(bbs,1)
b_num=round(0.1*size(bbs,1))
if size(bbs,1)<128
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
      weight=[weight;(64/(i+31))];
end

for j=1:1
    for i=max((j-1)*turns,1):min(size(bbs,1),j*turns)
        edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))+weight(i,1);
        ccol=sum(edgebox_hx,1);
        island_table(ccol);
        figure(2);
        plot(ccol);
        figure(3);
        imshow(edgebox_hx);
    end
end

end