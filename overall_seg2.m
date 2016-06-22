function overall_seg(left_edge_cluster,lc,ini_cluster,ccol,edgebox_hx,g)
%现阶段：是将自己做的统计边缘、种子点、边缘聚集三项知识
%综合起来，实现列分割。
  figure(5);   
  %边缘响应图
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
  %边缘聚集图
  subplot(4,1,4);
  plot(left_edge_cluster);    
    %原图
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
   %显著性图
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