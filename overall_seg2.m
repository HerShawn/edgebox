function overall_seg2(left_edge_cluster,left_edge_cluster2,lc,ini_cluster,ccol,edgebox_hx,g,figure_idx,img_value)
%�ֽ׶Σ��ǽ��Լ�����ͳ�Ʊ�Ե�����ӵ㡢��Ե�ۼ�����֪ʶ
%�ۺ�������ʵ���зָ
  figure(5);   
  %��Ե��Ӧͼ
  subplot(5,1,3);
   plot(ccol);
  line_len=max(ccol);
  hold on
  for i=1:length(ini_cluster)
      stem(ini_cluster(1,i),line_len,'g');
  end 
  for i=1:length(lc)
      stem(lc(1,i),line_len,'r');
  end  
  hold off   
  %��Ե�ۼ�ͼ2
  subplot(5,1,4);
  plot(left_edge_cluster2);   
  %��Ե�ۼ�ͼ1
  subplot(5,1,5);
  plot(left_edge_cluster);  
    %ԭͼ
  subplot(5,1,1);
  imshow(g);
  hold on
  for i=1:length(ini_cluster)
      stem(ini_cluster(1,i),line_len,'g');
  end 
  for i=1:length(lc)
      stem(lc(1,i),line_len,'r');
  end  
  hold off    
   %������ͼ
  subplot(5,1,2);
  imshow(edgebox_hx);
  line_len=size(edgebox_hx,1);
  hold on
  for i=1:length(ini_cluster)
      stem(ini_cluster(1,i),line_len,'g');
  end 
  for i=1:length(lc)
      stem(lc(1,i),line_len,'r');
  end  
  hold off   
  saveas(5,['D:\release\edgebox\6.24_�ۺϷ���ͼ\',img_value,'_',num2str(figure_idx) '.jpg'])
end