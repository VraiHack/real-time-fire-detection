vid = videoinput('winvideo', 1, 'MJPG_640x480');
src = getselectedsource(vid);
vid.FramesPerTrigger = 1;
vid.ReturnedColorspace = 'rgb';
set(vid,'TriggerRepeat', Inf);
hVideoOut = vision.VideoPlayer;
hVideoOut.Name ='Fire detected';
start(vid);
nframes= 300;
for k = 1:nframes
black=0;
white=0;
RGB=getsnapshot(vid); //Acquire and display a single image frame.
t=[9 9];
H = fspecial('Gaussian', t,1);
RGBF=imfilter(RGB,H);
YCBCR = rgb2ycbcr(RGBF);
im_red=YCBCR(:,:,1);
im_gray=rgb2gray(YCBCR);
im_diff=imsubtract(im_red,im_gray);
darkCarValue = 50;
noDarkCars = imextendedmax(im_diff, darkCarValue);
sedisk = strel('disk',10);
noSmallStructures = imopen(noDarkCars, sedisk);
noSmallStructures = bwareaopen(noSmallStructures, 500);
taggedFire= zeros(size(RGB,1),size(RGB,2),3,nframes);
taggedFire(:,:,:,k) = RGB;
stats = regionprops(noSmallStructures, {'Centroid','Area'});
if ~isempty([stats.Area])
areaArray = [stats.Area] ;
if(areaArray~=307200)
c=clock;
display('year month day hour minute seconds')
y=fix(c)
cf = 2000; // carrier frequency (Hz)
sf = 22050; // sample frequency (Hz)
d = 5.0; //duration (s)
n = sf * d; // number of samples
s = (1:n) / sf; // sound data preparation
s = sin(2 * pi * cf * s); // sinusoidal modulation
sound(s, sf); // sound presentation
pause(d + 0.5); // waiting for sound end
end
[junk,idx] = max(areaArray);
x = stats(idx).Centroid
x = floor(fliplr(x))
width = 4;
row = x(1)-width:x(1)+width;
col = x(2)-width:x(2)+width ;
taggedFire (row,col,1,k) = 255;
taggedFire (row,col,2,k) = 0;
taggedFire (row,col,3,k) = 0;
end
frameRate = get(vid);
step(hVideoOut,[taggedFire(:,:,:,k) RGB]);
end
delete(vid); //Remove video input object from memory.