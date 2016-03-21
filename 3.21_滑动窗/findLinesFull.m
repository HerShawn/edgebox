
%bboxes存储的是文本行的bounding box[左上角横坐标，左上角列坐标，文本行长度，文本行高度，分数]
 %spaces存储的是“space locations”；因为“gaps between words produce sharply
      %negtive responses",所以也可对negative response采用NMS来求space location。
 %spaces存储的也是charScores和位置locations
 %chars存储的是一个Rs[x,r]的分数charScores和位置locations
 %fullResponse存储的是一个Rs[x,r]的响应response和尺度scale
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

%按行处理   size(responseMap, 1)=722行 一次处理一行中的1248列
for i=1:size(responseMap, 1)
    %nms就是一个同一行response大小同的向量，局部极大值保留，非极大值抑制
  nms = nmsLineResponse(responseMap(i,:,1), thresh, 5);

  %peaks存储极大值坐标，如[3,12,21,28,39]
  peaks = find(nms > 0);
  separations = diff(peaks);

  %如果一个文本行中不足三个字符，且字间距比大于三倍，就不考虑这个文本行
  if length(peaks) == 3 && ((max(separations) / min(separations)) >= 3)
    continue;
  end 
  
  if length(peaks) >= 3 
    medianSep = median(separations);
    
    start = 1;

    for j=1:length(separations)
      %如果separations(j) > 5*medianSep，那就说明j这个peak后面隔着较长的空白
      %（>5*medianSep），因此j就是这段文本行最后一个字符的坐标
      if separations(j) > 5*medianSep
          %文本行最少要有三个字符
	if j - start >= 2
        %rect[左上角横坐标，左上角列坐标，文本行长度，文本行高度]
	  rect = [round(peaks(start)/scale), round(i/scale), ...
			     round((peaks(j)-peaks(start)+32)/scale), round(32/scale),...
			     mean(nms(peaks))];
             %bboxes存储的是bounding box
	  bboxes(end+1, :) = rect;
	  
      %这在求space时有用！
      %文本行宽高比> 20，>10，相应的改变nSpaces
	  aspectRatio = rect(3) / rect(4);
	  if aspectRatio > 20
	    nSpaces = nSpaces * 4;
	  elseif aspectRatio > 10
	    nSpaces = nSpaces * 2;
      end
	  
      
      %charScore是nms向量中，索引是peaks(start:j)的那段向量
	  charScores = nms(peaks(start:j));
	  locations = round((peaks(start:j) - peaks(start)) / scale) + 1;
	
      %chars存储的是一个Rs[x,r]的分数charScores和位置locations
	  chars(end+1) = struct('locations', locations, 'scores', charScores);
      
      %fullResponse存储的是一个Rs[x,r]的响应response和尺度scale
	  fullResponse(end+1) = struct('response', responseMap(i, peaks(start):min(size(responseMap, 2), peaks(j)+31), 1), ...
				       'scale', scale);
      %spaces存储的是“space locations”；因为“gaps between words produce sharply
      %negtive responses",所以也可对negative response采用NMS来求space location。
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
      
      %scores和locations都是向量，分别表示一个peak的分数和位置
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
%responseMap响应图； row行坐标； colStart和colEnd是列坐标的起始和终止； 
function spaceData = getSpaces(responseMap, row, colStart, colEnd, nSpaces, scale)

%间隔所在的向量
rNms = nmsLineResponse(-responseMap(row,colStart:colEnd), 0.25, 10);

%间隔所在的坐标
[~, indices] = sort(rNms, 'descend');
%nSpaces是间隔的数目
num = min(nSpaces, length(find(rNms > 0)));

scores = rNms(indices(1:num));

spaceData= struct('locations', min(round(colEnd/scale), ...
				   round((indices(1:num)+16)/scale)), ...
		  'scores', scores);
