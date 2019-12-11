
function MFCCoeffs = cal_mfcc(x,no_frames,fs,samples_in_1_frame,samples_in_overlap)
%==============================================================================
% MFCC CALCULATIONS INFORMATION
% We divide the time domain signal into Frames of 25 ms == 200 SAMPLES
% We take the next frame at 10ms = 80 samples and so on. (Next at multiples
% of 80)
% We have neglected 40 values (5ms signal) to have integer # of frames
% Then TOTAL NUM OF FRAMES REQUIRED is 44
%================================================================================
s=cell(1,no_frames); % cell data structure to store 44 frames' data
periodogram=cell(1,no_frames);
freqs=cell(1,no_frames); % holds the fourier of s
h=hamming(samples_in_1_frame); %creates hamming window of length samples_in_1_frame 


n=(1:samples_in_1_frame)/fs; % to plot s{i} against
n=n';
w=fs*(0:99)/samples_in_1_frame; % frequency axis for EACH FRAME to plot against (if needed)
w=w';

for i=1:no_frames
    s{i}=x((samples_in_overlap*(i-1)+1):(samples_in_1_frame+samples_in_overlap*(i-1)));
    s{i}=s{i}.*h;  % Multiplying Hamming window so that the frame is Hamming like smooth
    
    % take fourier transform
    freqs{i}=fft(s{i});
    freqs{i}=freqs{i}(1:100);
    % Now calculate Periodogram based Power Estimate
    periodogram{i}=((abs(freqs{i}).^2)/100);
    
    
   %*% jaffa=[jaffa s{i}']; %For concatenating frames
end

% s{i} are the frames calculated Hamming approximated!

%=========COMPUTING MEL BANK========================================

% CHoose lower freq as 0.8Hz and max as 400Hz
melMin=1125*log(1+0.8/700);
melMax=1125*log(1+400/700);

m=linspace(melMin,melMax,10);
%Convert these back to normal scale freq in h(i)
h=zeros(1,10);

for i=1:10
    h(i)=700*(exp(m(i)/1125)-1);
end



w=fs*(0:99)/samples_in_1_frame; % frequency axis for EACH FRAME to plot against (if needed)
w=w';
N=100; %size of fourier transform of each frame
FilterBank=cell(8,1);


figure('name','8 COMPONENT MEL-FILTER BANK GENERATED');
for j=2:9
    filterTemp=zeros(100,1);
    fofj=h(j);
    fofjp1=h(j+1);
    for i=1:100
         
         if j~=1 
          fofjm1=h(j-1);
          if w(i)< fofjm1
              filterTemp(i)=0;
          elseif w(i)<= fofj
              filterTemp(i)= (w(i)-fofjm1)/(fofj-fofjm1);
          elseif w(i)<= fofjp1
              filterTemp(i)=(fofjp1-w(i))/(fofjp1-fofj);
          elseif w(i)>fofjp1
              filterTemp(i)=0;
          end
         end 
      
      if j==1
        
        if w(i)<= fofjp1
            filterTemp(i)=(fofjp1-w(i))/(fofjp1-fofj);
        elseif w(i)>fofjp1
            filterTemp(i)=0;
      
        end
      end  
       
    end
    
    FilterBank{j-1}=filterTemp;
    hold on;
    plot(w,filterTemp);
end

xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('8 component Mel-Filter Bank in frequency: 2 Hz to 400 HZ');
xlim([0 500]);

% NOW WE HAVE CALCULATED THE 13 filtered MEL BANK STARTING AT 0 Hz ENDING
% at 500hz
%=== NOW CALCULATE FILTERBANK ENERGIES ====

filterbankEnergies=cell(no_frames,1);
temp=zeros(100,1);
for j=1:no_frames
    filterbankTemp=zeros(8,1);
    for i=1:8
        temp=periodogram{j}.*FilterBank{i};
        
        filterbankTemp(i)=sum(temp);
    end
    
    filterbankEnergies{j}=filterbankTemp;
end

%==AWESOME!! Now we have filterbank energies calculated in
%filterbankEnergies cell data structure


%Now calculate log filterbank energies

logFilterEnergies=cell(no_frames,1);

for i=1:no_frames
    logFilterEnergies{i}=log(abs(filterbankEnergies{i}));
end
% BUT INCASE log(0)=-inf WE WILL **** UP! SO If -inf found, replace by
% large neg number
tempvector=zeros(8,1);
for tempi=1:no_frames
    tempvector=logFilterEnergies{tempi};
    
    for tempj=1:8
        if tempvector(tempj,1)==-inf
            tempvector(tempj,1)=-10000;  % SET THIS VALUE APPROPRIATELY
        end
    end
    logFilterEnergies{tempi}=tempvector;
    tempvector=zeros(8,1);
end
% done

%!!!!!!  NOW FOR THE FINAL CALCULATION OF CEPSTRAL MFCC COEFFICIENTS

MFCCoeffs=cell(no_frames,1);
for i=1:no_frames
    MFCCoeffs{i}=zeros(8,1);
   
end

append=zeros(1,1);
for i=1:no_frames
    MFCCoeffs{i}=dct(logFilterEnergies{i});
    append=[append MFCCoeffs{i}']; % appended MFCC coefficients
end



