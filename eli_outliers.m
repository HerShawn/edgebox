function cluster2=eli_outliers(cluster)
    % �������Ҿֲ����ֵ
    % ���ڴ�С
    windowSize=round(length(cluster)/10.0);
    cluster2=zeros(1, length(cluster));
    for i=1:length(cluster)
        if  cluster(i) == max(cluster(max(1,i-windowSize):min(length(cluster), i+windowSize)))
            cluster2(i) = cluster(i);
        end
    end  
    
%     figure(5);
%     plot(cluster2);
%     
    
    
end