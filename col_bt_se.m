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
for i=1:size(bbs,1)
%     weight=[weight;(64/(8+(i-1)))];
    weight=[weight;1/i];
end
for i=1:size(bbs,1)
    edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))+weight(i,1);
end


% figure(2);
% [cx,cy]=meshgrid(1:1:wid,1:1:len);
% mesh(double(cx),double(cy),double(edgebox_hx));
% % colormap gray;
% xlabel('cx');
% ylabel('cy');

ccol=sum(edgebox_hx,1);
figure(3);
plot(ccol);
% col_max=max(col);
% cx = 1:1:size(ccol,2);
% cy = ccol;
% for i=1:length(ccol)-1
%     cz(i) = (cy(i+1)-cy(i))/(cx(i+1)-cx(i));
% end
% figure(4);
% plot(cz);
% z_max=max(z);

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

end