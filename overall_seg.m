function overall_seg(lc,ini_cluster,ccol,edgebox_hx,g)

%�ֽ׶Σ��ǽ��Լ�����ͳ�Ʊ�Ե�����ӵ㡢��Ե�ۼ�����֪ʶ
%�ۺ�������ʵ���зָ

  %ͳ�Ʊ�Ե��Ӧ
  figure(3);
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
  
  %��Ե��Ӧ
  figure(4);
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
  
  %ԭͼЧ��
  figure(1);
  imshow(g);
  hold on
  for i=1:length(ini_cluster)
      stem(ini_cluster(1,i),line_len,'g');
  end 
  for i=1:length(lc)
      stem(lc(1,i),line_len,'r');
  end  
  hold off 
  
end