function record_table(island_tab)
%island_tab������˲ʱ�ģ���record_tab��cluster_tabҪ����
%��global���ѽ�����浽col_bt_se_t_test��ѭ������Ϊֹ
%��island_table����ó��������ģ�Ȼ����һ�н����󷵸�col_bt_se_t_test
global record_tab;
global cluster_tab;


tab_idx=size(island_tab,2);
record_tab(1,tab_idx)=record_tab(1,tab_idx)+1;

for i=1:tab_idx
    cluster_tab(tab_idx,i)=round((island_tab(1,i)+island_tab(2,i))/2);
end

end