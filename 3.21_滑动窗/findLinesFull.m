
%bboxes�洢�����ı��е�bounding box[���ϽǺ����꣬���Ͻ������꣬�ı��г��ȣ��ı��и߶ȣ�����]
 %spaces�洢���ǡ�space locations������Ϊ��gaps between words produce sharply
      %negtive responses",����Ҳ�ɶ�negative response����NMS����space location��
 %spaces�洢��Ҳ��charScores��λ��locations
 %chars�洢����һ��Rs[x,r]�ķ���charScores��λ��locations
 %fullResponse�洢����һ��Rs[x,r]����Ӧresponse�ͳ߶�scale
function [bboxes, spaces, chars, fullResponse] = findLinesFull(responseMap, scale, thresh, nSpaces)

if ~exist('scale')
  scale = 1;
end

if ~exist('thresh')
  thresh = 0.8;
end

if ~exist('nSpaces')
  nSpaces = 5;
end

bboxes = [];
spaces = struct('locations', {}, 'scores', {});
chars  = struct('locations', {}, 'scores', {});
fullResponse = struct('response', {}, 'scale', {});

%���д���   size(responseMap, 1)=722�� һ�δ���һ���е�1248��
for i=1:size(responseMap, 1)
    %nms����һ��ͬһ��response��Сͬ���������ֲ�����ֵ�������Ǽ���ֵ����
  nms = nmsLineResponse(responseMap(i,:,1), thresh, 5);

  %peaks�洢����ֵ���꣬��[3,12,21,28,39]
  peaks = find(nms > 0);
  separations = diff(peaks);

  %���һ���ı����в��������ַ������ּ��ȴ����������Ͳ���������ı���
  if length(peaks) == 3 && ((max(separations) / min(separations)) >= 3)
    continue;
  end 
  
  if length(peaks) >= 3 
    medianSep = median(separations);
    
    start = 1;

    for j=1:length(separations)
      %���separations(j) > 5*medianSep���Ǿ�˵��j���peak������Žϳ��Ŀհ�
      %��>5*medianSep�������j��������ı������һ���ַ�������
      if separations(j) > 5*medianSep
          %�ı�������Ҫ�������ַ�
	if j - start >= 2
        %rect[���ϽǺ����꣬���Ͻ������꣬�ı��г��ȣ��ı��и߶�]
	  rect = [round(peaks(start)/scale), round(i/scale), ...
			     round((peaks(j)-peaks(start)+32)/scale), round(32/scale),...
			     mean(nms(peaks))];
             %bboxes�洢����bounding box
	  bboxes(end+1, :) = rect;
	  
      %������spaceʱ���ã�
      %�ı��п�߱�> 20��>10����Ӧ�ĸı�nSpaces
	  aspectRatio = rect(3) / rect(4);
	  if aspectRatio > 20
	    nSpaces = nSpaces * 4;
	  elseif aspectRatio > 10
	    nSpaces = nSpaces * 2;
      end
	  
      
      %charScore��nms�����У�������peaks(start:j)���Ƕ�����
	  charScores = nms(peaks(start:j));
	  locations = round((peaks(start:j) - peaks(start)) / scale) + 1;
	
      %chars�洢����һ��Rs[x,r]�ķ���charScores��λ��locations
	  chars(end+1) = struct('locations', locations, 'scores', charScores);
      
      %fullResponse�洢����һ��Rs[x,r]����Ӧresponse�ͳ߶�scale
	  fullResponse(end+1) = struct('response', responseMap(i, peaks(start):min(size(responseMap, 2), peaks(j)+31), 1), ...
				       'scale', scale);
      %spaces�洢���ǡ�space locations������Ϊ��gaps between words produce sharply
      %negtive responses",����Ҳ�ɶ�negative response����NMS����space location��
  	  spaces(end+1) = getSpaces(responseMap, i, peaks(start), peaks(j), nSpaces, scale);
	end
	start = j + 1;
      end
    end
    
    j = j + 1;
    if j - start >= 2
      rect = [round(peaks(start)/scale), round(i/scale), ...
	      round((peaks(j)-peaks(start)+31)/scale), round(32/scale), ...
	      mean(nms(peaks))];
      
      bboxes(end+1, :) = rect;
      
      %scores��locations�����������ֱ��ʾһ��peak�ķ�����λ��
      charScores = nms(peaks(start:j));
      locations = round((peaks(start:j) - peaks(start)) / scale) + 1;
      
      chars(end+1) = struct('locations', locations, 'scores', charScores);
      fullResponse(end+1) = struct('response', responseMap(i, min(size(responseMap, 2), peaks(start):peaks(j)+31), 1), ...
				   'scale', scale);
               
      spaces(end+1) = getSpaces(responseMap, i, peaks(start), peaks(j), nSpaces, scale);
    end
  end
end

%also estimate possible space locations within each Lr by applying the same
%NMS technique as above to the negative responses.
%responseMap��Ӧͼ�� row�����ꣻ colStart��colEnd�����������ʼ����ֹ�� 
function spaceData = getSpaces(responseMap, row, colStart, colEnd, nSpaces, scale)

%������ڵ�����
rNms = nmsLineResponse(-responseMap(row,colStart:colEnd), 0.25, 10);

%������ڵ�����
[~, indices] = sort(rNms, 'descend');
%nSpaces�Ǽ������Ŀ
num = min(nSpaces, length(find(rNms > 0)));

scores = rNms(indices(1:num));

spaceData= struct('locations', min(round(colEnd/scale), ...
				   round((indices(1:num)+16)/scale)), ...
		  'scores', scores);
