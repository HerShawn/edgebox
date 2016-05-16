
function responses = nmsLineResponse(vec, thresh, windowSize)

if ~exist('thresh')
  thresh = 0;
end

if ~exist('windowSize')
  windowSize = 5;
end

responses = zeros(1, length(vec));
%5/11���������˸��ģ�Ϊ��չ������Ӧ�߶ȱ任
% vec = vec - thresh;
for i=1:length(vec)
    % Rs[x,r]    �ڳ߶�s�£���r�У��ж�����Щ������x���ڵ�responseֵ�Ǿֲ�����ֵ
    % �ֲ����ڴ�С��[i-5,i+5]��10�����أ�����Ϊ1�����ֲ�����ֵ�������response���ơ�
  if vec(i) > 0 && vec(i) == max(vec(max(1,i-windowSize):min(length(vec), i+windowSize)))
    responses(i) = vec(i);
  end
end

     % �������ֲ��������ڷǼ������ƿ��ܲ����ص����ı��м�bounding box
     % ����취�ǣ�����һ����ÿ��bounding box��֣�����Rs[x,r]�з���response��ƽ��ֵ�����
     % ����NMS��ȥ���������ߡ��ص��ʸ߹�50%��С����bounding box
