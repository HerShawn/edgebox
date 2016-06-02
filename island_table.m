function island_table(ccol)
diff_idx=zeros(1,length(ccol));
% diff_idx(1)=0;
for i=2:length(ccol)
    if (ccol(i)-ccol(i-1))==ccol(i)&&ccol(i)~=0
        diff_idx(i)=ccol(i);
    elseif (ccol(i)-ccol(i-1))==-ccol(i-1)&&ccol(i-1)~=0
        diff_idx(i-1)=-ccol(i-1);   
    else 
%         diff_idx(i)=0
    end
end

%2016.6.1 在这里发现一个bug！
% 当响应连到图块首末时，会造成上升和下降不匹配。
%应当分各种case处理！
island_front=find(diff_idx>0);
island_back=find(diff_idx<0);
% island_tab=[island_front;island_back];
if length(find(diff_idx>0))>length(find(diff_idx<0))
    island_tab=[island_front;[island_back;length(diff_idx)-1]'];
elseif length(find(diff_idx>0))<length(find(diff_idx<0))
    island_tab=[[1;island_front]';island_back];
    
%  2016.6.2 debug: island_front和island_back都是空集的情况
elseif  isempty(find(diff_idx>0))
    island_tab=[1;length(diff_idx)-1];
else
    island_tab=[island_front;island_back];
end
%  2016.6.1 debug完毕 

record_table(island_tab);

end