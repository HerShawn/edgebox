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

island_front=find(diff_idx>0)
island_back=find(diff_idx<0)
island_tab=[island_front;island_back]

record_table(island_tab);

end