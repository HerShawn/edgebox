function overall_seg(left_edge_cluster,lc,ini_cluster,ccol,edgebox_hx,g)
%�ֽ׶Σ��ǽ��Լ�����ͳ�Ʊ�Ե�����ӵ㡢��Ե�ۼ�����֪ʶ
%�ۺ�������ʵ���зָ
  figure(5);   
  %��Ե��Ӧͼ
  subplot(4,1,3);
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
  %��Ե�ۼ�ͼ
  subplot(4,1,4);
  plot(left_edge_cluster);    
    %ԭͼ
  subplot(4,1,1);
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
  subplot(4,1,2);
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
end