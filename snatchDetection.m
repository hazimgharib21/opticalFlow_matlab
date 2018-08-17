clear all
clc




global vidIn;
[file,path] = uigetfile('E:\Cloud\Google Drive\projectMdmAzlin\*.avi;*.mp4',...
    'Select a video file');

if isequal(file,0)
    return;
else
    disp(['User selected ', fullfile(path,file)]);
end

vidIn = VideoReader(fullfile(path,file));
numFrames = vidIn.NumberOfFrames;
vidIn = VideoReader(fullfile(path,file));
info = get(vidIn);
curFrame = readFrame(vidIn);
curFrame = rgb2gray(curFrame);
width = info.Width;
height = info.Height;
width = round(width / 5);
height = round(height / 5);
curFrame = imresize(curFrame, [height, width]);

u = zeros(height, width);
v = zeros(height, width);
u2 = zeros(height, width);
v2 = zeros(height, width);
BW = zeros(height, width, 'uint8');
ind1=1; index=0; index1=0; b=0;

tic;
while hasFrame(vidIn)
    index=index+1;
    curFrame = readFrame(vidIn);
    curFrame = imresize(curFrame, [height, width]);
    
    for r=1:height
        for c=1:width
            u(r,c)=curFrame(height-r+1,c);
            v(r,c)=curFrame(height-r+1,c);
            
            if((u(r,c)^2+v(r,c)^2)>0)
                ind1=ind1+1;
                angle1(index,ind1)=atan2(v(r,c),u(r,c));
                index1=index;
            end
            if((u(r,c)^2+v(r,c)^2)>0.05)
                BW(r,c)=1;
            else
                BW(r,c)=0;
            end
        end
    end
    figure(1);
    imshow(curFrame);
    figure(2);
    quiver(u,v,0);
    
    b1=b;
    [a,b]=rose(angle1(index1,:));
    b(1)=b(1)/4;
    if (index==1)
        bl=b;
    end
    polar(a,b);
end

    
    
    
    
toc;






