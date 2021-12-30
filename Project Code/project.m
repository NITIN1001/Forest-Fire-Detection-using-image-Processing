clc
vid= VideoReader('Fire6.wmv');
nof=vid.NumFrames;
threshold=3;
alpha=0.5;

for f=1:nof
    %% Reading Frames
    Img = read(vid,f);
    figure(1)
    imshow(Img,'InitialMagnification','fit')
    %% Background Subtraction
    if f==1
        bg=Img;
    else
        bg=(1-alpha)* Img + alpha * bg;
    end
    Fg=abs(Img-bg);
    binaryImage =imbinarize(Fg, threshold);
    figure(2)
    imshow(Fg,'InitialMagnification','fit')
    %% RGB to YCbCr Conversion
    ycbcrmap=rgb2ycbcr(Img);
   
    Y=ycbcrmap(:,:,1);
    Cb=ycbcrmap(:,:,2);
    Cr=ycbcrmap(:,:,3);
    [a,b]=size(Y);
    Sum=sum(Y);
    total=sum(Sum);
    Ymean=total/(a*b);
    [a,b]=size(Cb);
    Sum=sum(Cb);
    total=sum(Sum);
    CbMean=total/(a*b);
    [a,b]=size(Cr);
    Sum=sum(Cr);
    total=sum(Sum);
    CrMean=total/(a*b);
    [lin,col]=size(Y);
    %% Fire Color Pixel Detection Rules
    test=ones(lin,col)*255;
    tau=70;
    for i=1:lin
        for j=1:col
            %% Rule7
            if(~(Y(i,j)>Cb(i,j)))
                test(i,j)=0;
            end
            %% Rule8
            if(~(Cr(i,j)>Cb(i,j)))
                test(i,j)=0;
            end
            %% Rule9
            if(~((Y(i,j)>Ymean) && (Cb(i,j)<CbMean) && (Cr(i,j)>CrMean)))
                test(i,j)=0;
            end
            %% Rule10
            if(~(abs(Cb(i,j)-Cr(i,j))<tau))
                test(i,j)=0;
            end
            %% Rule11
            if(~(Cb(i,j)<=120 && Cr(i,j)>=150))
                test(i,j)=0;
            end 
            
        end
    end
    figure(3)
    imshow(test,'InitialMagnification','fit')
end

%% Temporal Variation
cFrame = read(vid,1);
[h,w]=size(cFrame);
tot=zeros(1,nof);
for k=1:nof-1
    pFrame = read(vid,k+1);
    tot(k)=pFrame(h/2,w/2)-cFrame(h/2,w/2);
    cFrame = pFrame;
end
if(sum(tot)/nof>threshold)
    fprintf("Forest Fire Detected\n");
else
    fprintf("No Fire Detected\n");
end


