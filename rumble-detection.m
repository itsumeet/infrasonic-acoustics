%% SRFP 2019
%%%%%%%%%%%%%%%%%%%%%% Final working main file
%% audio files for training
audio_signal = ["C:\Users\Asus\Desktop\SRFP 2019\elephant rumble\elephant rumble mp3\baroo\137_file_1.mp3";...
    "C:\Users\Asus\Desktop\SRFP 2019\elephant rumble\elephant rumble mp3\baroo\139_file_1.mp3";...
    "C:\Users\Asus\Desktop\SRFP 2019\elephant rumble\elephant rumble mp3\baroo\140_file_1.mp3";...
    "C:\Users\Asus\Desktop\SRFP 2019\elephant rumble\elephant rumble mp3\baroo\143_file_1.mp3";...
    "C:\Users\Asus\Raven Lite 2.0\Examples\CanyonWren.mp3"];%%reading the audio signals as string
%%%%%%%%%%%%%%%%%%%%%%%
%% Base template
[audioIn,fs_base] = audioread('C:\Users\Asus\Desktop\SRFP 2019\elephant rumble\elephant rumble mp3\estrous-rumble\70_file_1.mp3'); %reading base file
data = load('base_table.txt'); %load base text file containing annotating time from selection table of that audio file
x1 = data(1);                  %start time
y1 = data(2);                  %end time
x = floor(x1*fs_base);         %corresponding start sample
y = floor(y1*fs_base);         %corresponding end sample
del_time_b = y1-x1;             % time interval of that base template
total_sample_b = del_time_b * fs_base ; % no of samples in base template
frame_len_b = 100e-3 ;                  % frame length 100ms
overlap_len_b = 0.5*frame_len_b;        % overalap length 50ms
samples_in_1_frame_b = floor(frame_len_b * fs_base); % number of samples in one frame
samples_in_overlap_b = floor(0.5 * frame_len_b * fs_base); %no of samples in overlap frame
no_of_frames_b = floor(total_sample_b / samples_in_1_frame_b); % number of fframes in base template
coeffs = cal_mfcc(audioIn(x:y,1),no_of_frames_b,fs_base,samples_in_1_frame_b,samples_in_overlap_b); % calling calc_mfcc function to find mfcc coefficients
coeffs1 = zeros(8,no_of_frames_b);
%%% coeffs is a cell data structure, storing it into a array coeffs1
for i1 = 1:no_of_frames_b
    temp = coeffs{i1};
    for j1 = 1:8
        coeffs1(j1,i1) = temp(j1,1);
    end
end
%%%%%%%%%%%%%%%%%%
%% processing testing templates
[c_1_m,c_1_n] = size(coeffs1);
data1 = load('test_cases.txt');            %%load start end time from of audio files to be tested into data1 
                                           % rows contains annotated time
                                           % of one audio file
                                           % column contains start and end
                                           % time in pairwise fashion so
                                           % during looping hopping of 2
                                           % column is required
[rumble_m,rumble_n] = size(data1);          
[audio_m,audio_n] = size(audio_signal);

%%%looping over audio files
for l = 1:audio_m
    [audioIn1,fs1] = audioread(audio_signal(l,1));  %% reading audio files from audio_signal
    %%looping over the rows of data1
    for qw = 1:rumble_m     
        d=0;
        [~,b]  = size(data1(qw,:));
        %%looping over the column of a row of data1
        for len = 1:2:b
            %%if element of data1 is zero skip to next row otherwise with
            %%hopping of two column continue
            if data1(qw,len) ~= 0
                i2 = data1(qw,len);
                j2 = data1(qw,len+1);
                i = floor(i2*fs1);
                j = floor(j2*fs1);
                del_time = j2-i2;
                total_sample = floor(del_time * fs1) ;
                frame_len = 100e-3 ; 
                overlap_len = 0.5*frame_len;
                samples_in_1_frame = floor(frame_len * fs1);
                samples_in_overlap = floor(overlap_len * fs1);
                no_of_frames = floor(total_sample / samples_in_1_frame);
                coeffs2 = cal_mfcc(audioIn1(i:j,1),no_of_frames,fs1,samples_in_1_frame,samples_in_overlap); %% calc_mfcc is called for each annotations in selection table
                for i3 = 1:no_of_frames
                    temp1 = coeffs2{i3};
                    for j3 = 1:8
                        coeffs3(j3,i3) = temp1(j3,1);
                    end
                end
                [c3_m,c3_n] = size(coeffs3);
                %% dtw is calculated frame wise over the whole annotated time intereval del_time and threshold is kept as 280
                for u = 1 : 15 : c3_n
                    if c3_n - u > c_1_n
                        [dist] = dtw(coeffs3(:,u:u + c_1_n),coeffs1);
                        dtw(coeffs3(:,u:u + c_1_n),coeffs1);
                    end
                    if dist < 280 && dist >100
                        d=d+1;
                    end
                end
            else
                break;
            end
        end
    end
        if d>0
            disp('rumble is present');
        else
           disp('rumble is not present');
        end
end

