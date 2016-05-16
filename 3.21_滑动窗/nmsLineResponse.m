
function responses = nmsLineResponse(vec, thresh, windowSize)

if ~exist('thresh')
  thresh = 0;
end

if ~exist('windowSize')
  windowSize = 5;
end

responses = zeros(1, length(vec));
%5/11在这里做了更改，为了展现自适应尺度变换
% vec = vec - thresh;
for i=1:length(vec)
    % Rs[x,r]    在尺度s下，行r中，判断在哪些横坐标x所在的response值是局部极大值
    % 局部窗口大小是[i-5,i+5]共10个像素，步进为1；除局部极大值外的所有response抑制。
  if vec(i) > 0 && vec(i) == max(vec(max(1,i-windowSize):min(length(vec), i+windowSize)))
    responses(i) = vec(i);
  end
end

     % 以上这种步进、窗口非极大抑制可能产生重叠的文本行级bounding box
     % 解决办法是：在下一步给每个bounding box打分：依据Rs[x,r]中非零response的平均值来打分
     % 采用NMS来去掉分数不高、重叠率高过50%的小分数bounding box
