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
do_dir='D:\release\edgebox-contour-neumann三种检测方法的比较\';
dir_img = dir([do_dir 'Challenge2_Test_Task12_Images\*.jpg'] );


num_img = length(dir_img);


for indexImg = 1:1
    
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    
    img_name = [do_dir 'Challenge2_Test_Task12_Images\' img_value '.jpg'];
    g = imread(img_name);
    
    
    %     edgebox_mser=rgb2gray(g);
    [len,wid,~] = size(g);
    edgebox_hx=zeros(len,wid);
    %     for i=1:len
    %        for j=1:wid
    %            edgebox_mser(i,j)=0;
    %        end
    %     end
    
    
    tic, bbs=edgeBoxes(g,model,opts); toc
    bbs=bbs(1:128,:);
    bbs=sortrows(bbs,-5);
    
    %         figure(indexImg);
    %         bbGt('showRes',g,double(bbs),double(bbs));
    %         save_name=[img_value '.jpg'];
    %         print(indexImg, '-dpng', save_name);
    
    %%
    %     bbs(:,3)=min(bbs(:,1)+bbs(:,3),len);
    %     bbs(:,4)=min(bbs(:,2)+bbs(:,4),wid);
    
    bbs(:,3)=bbs(:,1)+bbs(:,3);
    bbs(:,4)=bbs(:,2)+bbs(:,4);
    weight=[];
    for i=1:128
        weight=[weight;(64/(8+(i-1)))];
    end
    
    for i=1:128
        edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))=edgebox_hx(bbs(i,2):bbs(i,4),bbs(i,1):bbs(i,3))+weight(i,1);
        %         edgebox_hx(bbs(i,1):bbs(i,3),bbs(i,2):bbs(i,4))=edgebox_hx(bbs(i,1):bbs(i,3),bbs(i,2):bbs(i,4))+2;
    end
    
    %     [x,y]=meshgrid(1:1:wid,1:1:len);
    %     for i=1:len
    %         for j=1:wid
    %             B(i,j)=edgebox_hx(i,j);
    %         end
    %     end
    %     figure(indexImg);
    %     mesh(double(x),double(y),double(B));
    %     xlabel('x');
    %     ylabel('y');
    %     save_name=[img_value '.jpg'];
    %     print(indexImg, '-dpng', save_name);
    
    
    
    [m,n]=size(edgebox_hx);
    out=zeros(m,n);
    c=max(max(edgebox_hx));
    for i=1:m
        for j=1:n
            if edgebox_hx(i,j)<=c/4
                R(i,j)=0;
                G(i,j)=4*edgebox_hx(i,j);
                B(i,j)=c;
            else if edgebox_hx(i,j)<=c/2
                    R(i,j)=0;
                    G(i,j)=c;
                    B(i,j)=-4*edgebox_hx(i,j)+2*c;
                else if edgebox_hx(i,j)<=3*c/4
                        R(i,j)=4*edgebox_hx(i,j)-2*c;
                        G(i,j)=c;
                        B(i,j)=0;
                    else
                        R(i,j)=c;
                        G(i,j)=-4*edgebox_hx(i,j)+4*c;
                        B(i,j)=0;
                    end
                end
            end
        end
    end
    for i=1:m
        for j=1:n
            out(i,j,1)=R(i,j);
            out(i,j,2)=G(i,j);
            out(i,j,3)=B(i,j);
        end
    end
    out=out/256;
    
    
    figure(indexImg),imshow(out)
    save_name=[img_value '.jpg'];
    print(indexImg, '-dpng', save_name);
    
    %     figure(indexImg); imshow(edgebox_hx,[0 max(max(edgebox_hx))]);
    %     save_name=[img_value '.jpg'];
    %     print(indexImg, '-dpng', save_name);
    
    %     save_name=[img_value '.jpg'];
    %     print(indexImg, '-dpng', save_name);
    %     imshow(B);
    
    %     regions = detectMSERFeatures(edgebox_hx);
    %     figure; imshow(edgebox_hx); hold on;
    %     plot(regions, 'showPixelList', true, 'showEllipses', false);
    %     plot(regions);
    
    
    
    %% mser思路一
    %     mserRegions = detectMSERFeatures(edgebox_hx);
    %     mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
    %     %  把mser区域的坐标系数取出来，然后将相应系数的地方赋值为真。取出mser区域。
    %
    %     mserMask = false(size(edgebox_hx));
    %     ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
    %     mserMask(ind) = true;
    %     figure;imshow(mserMask);
    %%
    %
    %
    %%
    %     title('green=matched gt  red=missed gt  dashed-green=matched detect');
end