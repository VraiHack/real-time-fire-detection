Obj = VideoReader('fire2.avi');
get(Obj);
J= read(Obj, inf);
nframes = get(Obj, 'NumberOfFrames')
taggedFire = zeros([size(J,1) size(J,2) 3 nframes], class(J));
for k = 1:nframes
darkValue = 50;
singleFrame = read(Obj, k);
t=[9 9];
H = fspecial('Gaussian', t,1);
ImageG=imfilter(singleFrame,H);
YCBCR = rgb2ycbcr(ImageG);
im_red=YCBCR(:,:,1);
im_gray = rgb2gray(YCBCR);
I=imsubtract(im_red,im_gray);
noDark = imextendedmax(I, darkValue);
sedisk = strel('disk',2);
noSmallStructures = imopen(noDark, sedisk);
noSmallStructures = bwareaopen(noSmallStructures, 150);
taggedFire(:,:,:,k) = singleFrame;
stats = regionprops(noSmallStructures, {'Centroid','Area'});
if ~isempty([stats.Area])
areaArray = [stats.Area];
[junk,idx] = max(areaArray);
c = stats(idx).Centroid;
c = floor(fliplr(c));
width = 2;
row = c(1)-width:c(1)+width;
col = c(2)-width:c(2)+width;
taggedFire (row,col,1,k) = 255;
taggedFire (row,col,2,k) = 0;
taggedFire (row,col,3,k) = 0;
end
end
frameRate = get(Obj,'FrameRate');
implay(taggedFire,frameRate);