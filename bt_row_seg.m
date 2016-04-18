function bt_row_seg(peak)
%     global table_len;
    global row_table;
    global node_idx;
    
%       node_idx=node_idx+1;
%     
%     if size(peak(1,:),2)==2
%         row_idx=floor(node_idx/3)+1;
%         col_idx=floor(node_idx/table_len)+1;
%         row_table(row_idx,col_idx)=num2cell(node_idx);
%         
%         return;
%     end

    left=peak(1,1);
    right=peak(1,end);
    value=max(peak(2,2:end-1));

    row_table(node_idx,1)=node_idx;
    row_table(node_idx,2)=left;
    row_table(node_idx,3)=right;    
    row_table(node_idx,4)=value;
    
    node_idx=node_idx+1;
    
    if length(peak(1,:))==3
         left=peak(1,1);
         right=peak(1,2);
         value=0;
         row_table(node_idx,1)=node_idx;
         row_table(node_idx,2)=left;
         row_table(node_idx,3)=right;
         row_table(node_idx,4)=value;
         node_idx=node_idx+1;
         left=peak(1,2);
         right=peak(1,3);
         value=0;
         row_table(node_idx,1)=node_idx;
         row_table(node_idx,2)=left;
         row_table(node_idx,3)=right;
         row_table(node_idx,4)=value;
          node_idx=node_idx+1;
         return;
    end


    [~,peak_seg]=max(peak(2,2:end-1));
    peak_seg1=peak(:,1:(peak_seg+1));
    bt_row_seg(peak_seg1);
    peak_seg2=peak(:,(peak_seg+1):end);
    bt_row_seg(peak_seg2);
    
  
end