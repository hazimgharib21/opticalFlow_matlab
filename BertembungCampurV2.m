clear all 
clc
eee=[];% semua data selepas kesan pertembungan
RoseALL=[];% data bertembung 20 sebelum+ selepas
VMDETECT=[];% data padanan setiap 42 jujukan setelah kesan pertembungan
Padanan=[];% padanan sebelum dan selepas pertembungan
sudut2=[];%taburan sudut semua jujukan
cerunsemua=[];%cerun semua jujukan
sumsemua=[];%sum semua jujukan
sudutbanding42All=[];
sudutsemua=[];
vmsemua=[];
s.kos=0;
s.jaccard=0;
s.hausdorf=0;
s.eaucledean=0;
s.mahalobis=0;
SimilarityBA=[];
index=0;
dsi=0
b=0;
n=0,
p=0;
imulatembung=0;
iakhirtembung=0
mmax=0;
tic

overLap(1)=0;
detectOverLap=0;
startOverLap=0;
endOverLap=0;
%%initialise Kalman Filter
slope(1)=0;
der=[];
P=100*eye(2);
Pp=P;
K=[0;0];
Xp=[0.0; 400];
T=1;
ak=1;


A=[ak 0
    T 1];
C=[0 1];

g=0.1;
Ns=50;
Np=Ns*g;
kira=0;
Pk=100;
b=0;
countframe=0;
%%.............................
group=0;
index1=0;
mulatembung=0;
akhirtembung=0;
 for frame=8488:8528
    
    index=index+1;
    directory = 'F:\DataCerah\OFCerah\';
    baseName= 'OF'
    mat = directory;
    mat=strcat(mat,baseName);
   
    mat=strcat(mat, int2str(frame));
    %mat_u=strcat(mat_u,'.mat');
    mat=strcat(mat,'.mat');
    
    countframe=countframe+1;
    load(mat);
    [NR NC]=size(u2);%size(newu3);
    u=zeros(NR,NC);
    v=zeros(NR,NC);
    BW= zeros(NR,NC,'uint8');
    ind1=1;
   
    for r=1:NR
        for c=1:NC
            u(r,c)=u2(NR-r+1,c);%newu3(NR-r+1,c);
            v(r,c)=v2(NR-r+1,c);%newv3(NR-r+1,c);
            
            if ((u(r,c)^2+v(r,c)^2)>0)
                ind1=ind1+1;
                angle1(index,ind1)=atan2(v(r,c),u(r,c));
                index1=index;
            end
            
            
            if ((u(r,c)^2+v(r,c)^2)>0.05)
                BW(r,c)=1;
                
            else
                BW(r,c)=0;
                
            end
        end
    end
 figure(1);
    quiver(u,v,0);
     app='F:\Campur\SkeletonCampur\S';
    app=strcat(app,int2str(frame));
    app=strcat(app,'.jpg');
    print ( '-f', '-djpeg',app);
    
    
    b1=b;
    [a,b]=rose(angle1(index1,:));
    b(1)=b(1)/4;
    if (index==1)
        b1=b;
    end
    N=4;     
%     polar(a,b);
%     rose_i= 'L:\Campur\RoseCampur\R';
%     rose_i=strcat(rose_i, int2str(frame));
%     rose_i=strcat(rose_i,'.jpeg');
%     print ( '-f', '-djpeg',rose_i)

    k=0;
    for i=1:80
        if mod(i,4)==2
            k=k+1;
            bbaru(k)=b(i);
        end
    end
    if (index==1)
        b1baru=bbaru;
    end
    
    horizontal(index)=sum(b(1:1*N))+sum(b(19*N+1:20*N))+ sum(b(9*N+1:11*N));
    %             polar(a,b);
    
    kecneg1=-18;
    kecneg2=-100;
    kecpos1=18;
    kecpos2=100;
    
%     bwpilih(:,:,index)=BW;
    sudut(index,:)=bbaru;
    sudutbanding=[bbaru];sudutbanding42All=[sudutbanding42All,sudutbanding]
   
    sum1(index)=sum(sum(BW));
        
    if sum1(index)==0
        sum1(index)=sum1(index-1);
    end
       cos_theta(index) = (dot(bbaru,b1baru)/(norm(b1baru)*norm(bbaru)+0.001));
    %Jaccard Bertembung
    cos_theta1a(index) = dot(bbaru,b1baru)/(norm(bbaru)*norm(bbaru)+norm(b1baru)*norm(b1baru)-dot(bbaru,b1baru));
    d1(index) = HausdorffDist(bbaru,b1baru);
    d2=cvMahaldist(bbaru,b1baru);
    d5(index)=sum(sum(d2));
    d3=distance(bbaru,b1baru);
    d6(index)=sum(sum(d3));
    %cos_theta(index)=norm(b-b1);%/norm(b+b1);
    
    %kalman filtering
    Xm = A*Xp;
    
    Pm = A*Pp*A' + Np;
    K =Pm*C'/(C*Pm*C'+Ns);
    Pp =Pm - K*C*Pm;
    Xp = Xm + K*(sum1(index)-C*Xm);
    slope(index)=Xp(1);
    if (detectOverLap==0 && endOverLap==0 )
        if (slope(index)<kecneg1 && slope(index)>kecneg2 )
            n=n+1;
            dn(n)=slope(index)
            detectOverLap=1;
            startOverLap=index
            roseStart=bbaru;
            mulatembungsimilarity=[cos_theta(index),cos_theta1a(index),d1(index),d5(index),d6(index)];
            mulatembung=frame;
             figure(2),
    quiver(u,v,0);
     
     figure(3),
               polar(a,b);  
        end
    end
    
    if (detectOverLap==1)
        if (slope(index)>kecpos1 && slope(index)<kecpos2)
            p=p+1
            dp(n)=slope(index)
            detectOverLap=0;
            endOverLap=index
            roseEnd=bbaru;
            detectframe=frame;
             akhirtembungsimilarity=[cos_theta(index),cos_theta1a(index),d1(index),d5(index),d6(index)];
            akhirtembung=frame;
            figure(4),
    quiver(u,v,0);
     figure(5),
               polar(a,b);  
        end
    end
    overLap(index)=detectOverLap;
    %kalman
   
    
    %to check for increasing sum of index
    
    snatch(index)=0;
    if (index<3)
        index2=index;
        index3=index;
    else
        index3=index-2;
        index2=index-1;
    end
    
    
    if (endOverLap ~= 0)
        d1a=HausdorffDist(roseStart,roseEnd);
        d2a=cvMahaldist(roseStart,roseEnd);
        d2a=sum(sum(d2a));
        d3a=distance(roseStart,roseEnd);
        d3a=sum(sum(d3a));
        
        cos_theta1 = (dot(roseStart,roseEnd)/(norm(roseEnd)*norm(roseStart)+0.001));
        
        %Jaccard Bertembung
        cos_theta1b = dot(roseStart,roseEnd)/(norm(roseEnd)*norm(roseEnd)+norm(roseStart)*norm(roseStart)-dot(roseStart,roseEnd));
        if (cos_theta1<0.95)
            snatch(index)=1;
            
        end
        figure(6)
            x=1:1:25;
            plot(1000*cos_theta','-r');           
            hold on,
            plot(sum1','-b');
            hold on,
            plot(overLap'*1000);
            hold on
            plot(500*snatch','-.b');
            hold off;
            
     
    end
    
    
       
    if countframe==25
        group=group+1;
        if startOverLap==0 || endOverLap==0
            figure(7)
            x=1:1:25;
            plot(x,1000*cos_theta','-r',x,sum1','-b',x,overLap'*1000,'-go',x, 500*snatch','-.b');
            axis([0 25  0  1000])
            h = legend('cos_theta','sum','overLap','snatch',4);
            graf='F:\Campur\GrafCampur\';
            kira=kira+1;
%             graf=strcat(graf, 'GC');
%             graf=strcat(graf, int2str(group));
%             graf=strcat(graf,'.jpeg');
%             print ( '-f', '-djpeg', graf);
%       
        elseif( startOverLap>0 && endOverLap>startOverLap )||length(kedudukan)==length(costhetabaru)
            

            figure(7)
            x=1:1:25;
            plot(x,1000*cos_theta','-r',x,sum1','-b',x,overLap'*1000,'-go',x, 500*snatch','-.b');
            axis([0 25  0  1000])
            h = legend('cos_theta','sum','overLap','snatch',4);
%             graf='G:\Campur\GrafCampur\';
%             kira=kira+1;
%             graf=strcat(graf, 'GC');
%             graf=strcat(graf, int2str(group));
%             graf=strcat(graf,'.jpeg');
%             print ( '-f', '-djpeg', graf);
% %             
            jumstart=sum1(startOverLap);
            jumend=sum1(endOverLap);
            bezajum=jumend-jumstart;
            anglestart=cos_theta(startOverLap);
            angleend=cos_theta(endOverLap);
            bezaangle=angleend-anglestart;
            
            data1=[roseStart,roseEnd,cos_theta1,cos_theta1b,cos_theta,cos_theta1a,bezajum,bezaangle,jumstart,jumend];
            data=[data1,d1,d5,d6,d1a,d2a,d3a,sum1,group,mulatembung,akhirtembung];
             sudutsimpansemasa=sudutbanding42All;
           sudut1=[sudutsimpansemasa]; sudut2=[sudut2;sudut1]
            
            VM=[cos_theta,cos_theta1a,d1,d5,d6];VMDETECT=[VMDETECT;VM]
            ee=data;eee=[eee;ee];
            PadananVM=[d1a,d2a,d3a,cos_theta1,cos_theta1b];Padanan=[Padanan;PadananVM]
            PadananBADetect=[mulatembungsimilarity,akhirtembungsimilarity];SimilarityBA=[SimilarityBA;PadananBADetect];
            RoseBA=[roseStart,roseEnd];RoseALL=[RoseALL,RoseBA];
                       
        else
%             figure(2)
%             x=1:1:42;
%             plot(x,1000*costhetaedit,'-r',x,sumedit,'-b');
%             axis([0 42  0  1000])
%             h = legend('cos_theta','sum',2);
%             
%             graf='L:\NorazlinPHD\Thesis\DataLokasiSama\DataLokasiSama\DataCerah\OFCerahTerkini\';
%             kira=kira+1;
%             graf=strcat(graf, 'GC_');
%             graf=strcat(graf, int2str(group));
%             graf=strcat(graf,'.jpeg');
%             print ( '-f', '-djpeg', graf);
                    
        end
        cerun=slope;cerunsemua=[cerunsemua;cerun];
        sumof=sum1; sumsemua=[sumsemua;sumof];
        sudutsimpansemasa=sudutbanding42All;
        sudutc=[sudutsimpansemasa];sudutsemua=[sudutsemua;sudutc];
        vmc=[cos_theta,cos_theta1a,d1,d5,d6];vmsemua=[vmsemua;vmc];
        index=0;
        dsi=0
        b=0;
        n=0,
        p=0;
        
        mmax=0;
        
        
        overLap(1)=0;
        detectOverLap=0;
        startOverLap=0;
        endOverLap=0;
        %%initialise Kalman Filter
        slope(1)=0;
        der=[];
        P=100*eye(2);
        Pp=P;
        K=[0;0];
        Xp=[0.0; 400];
        T=1;
        ak=1;
        
        
        A=[ak 0
            T 1];
        C=[0 1];
        
        g=0.1;
        Ns=50;
        Np=Ns*g;
        kira=0;
        Pk=100;
        b=0;
        countframe=0;
        %%.............................
        
        index1=0;
        sudutbanding42All=[];
    end
    
end % frame
ttime = toc;
disp('Processing Done...')
disp(sprintf('Total time taken = %f',ttime))

% fclose(fid)