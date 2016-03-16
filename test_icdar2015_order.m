clc
clear
close all


%%
do_dir='D:\release\edgebox\edgebox-contour-neumann三种检测方法的比较\';
dir_img = dir([do_dir 'Challenge2_Test_Task12_Images\*.jpg'] );


num_img = length(dir_img);

order=zeros(num_img,1);

for indexImg = 1:num_img
    
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    img_value=str2num(img_value(5:end));
    
    
    order(indexImg,:)=img_value;
    
    
end