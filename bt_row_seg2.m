function do_table=bt_row_seg2(do_table)
    global row_table;

    for i=1:length(do_table)      
       root=find(row_table(:,4)==min(row_table(find(row_table(:,4)>0),4))); 
       do_table(i,3)=root;
       
%        leaf_left=find(row_table(find(row_table(:,2)==row_table(root,2)),3)==0);
%        do_table(i,1)=leaf_left;

       leafs_left=row_table(find(row_table(:,2)==row_table(root,2)),1);
       leaf_left=leafs_left(find(row_table(leafs_left,4)==0));
       do_table(i,1)=leaf_left;
       
%        leaf_right=find(row_table(find(row_table(:,2)==row_table(root,2)),3)==0);
%        do_table(i,2)=leaf_right;
       
       leafs_right=row_table(find(row_table(:,3)==row_table(root,3)),1);
       leaf_right=leafs_right(find(row_table(leafs_right,4)==0));
       do_table(i,2)=leaf_right;

       row_table(root,4)=0;
       row_table(leaf_left,4)=-1;
       row_table(leaf_right,4)=-1;
    end
end