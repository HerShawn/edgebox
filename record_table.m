function record_table(island_tab)
%island_tab可以是瞬时的，但record_tab和cluster_tab要储存
%需global，把结果保存到col_bt_se_t_test里循环结束为止
%在island_table计算得出聚类中心，然后在一行结束后返给col_bt_se_t_test
global record_tab;
global cluster_tab;
record_tab=zeros(2,10);
cluster_tab=zeros(10,10);

tab_idx=size(island_tab,2);
record_tab(2,tab_idx)=record_tab(2,tab_idx)+1;

for i=1:tab_idx
    cluster_tab(tab_idx,i)=(island_tab(1,i)+island_tab(1,i))/2;
end

end