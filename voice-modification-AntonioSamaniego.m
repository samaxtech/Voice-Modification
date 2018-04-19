%% ECE 160 - "VOICE MODIFICATION" %%

%Implementation by Antonio Javier Samaniego Jurado

%% (1) Read the speech audio file: %%
clear all 
close all

[audio_samples,Fs] = audioread('yourpath/speech.wav');

audio_samples=audio_samples(:,1);
t=transpose((0:length(audio_samples)-1)/Fs); %Time axis

%%
%%%%%%%%%% (2) Modification: %%%%%%%%%%
%(2.1): Amplitude Modulation
modulator=sin(2*pi*2*t); 
modulated=modulator.*audio_samples;


%(2.2): Robot Effect, by Applying a Fast Delay (Applied to previous modulated result)
%%% Strategic values for min/max delay and number of delayed signals to add up, 
%%% to achieve the effect, based on a regular, standard human voice speed: %%%
min_delay=500;
max_delay=2000;
num_delayed=10;
%%%%%%%%%%%%%%

delay=floor(linspace(min_delay,max_delay,num_delayed));
delayed=zeros(length(audio_samples)+max(delay),num_delayed);

%Perform delay:
for i=1:num_delayed
    delayed(delay(i)+1:(size(delayed,1)-(max(delay)-delay(i))),i)=modulated(:);
end
    
sum_delayed=sum(delayed,2); %Add up all delayed signals

t_delay=transpose((0:length(sum_delayed)-1)/Fs); %New time axis


%(2.3) High Pass Filtering 
[b,a]=butter(2,0.1,'high');
filtered=filter(b,a,sum_delayed);

%(2.4) Echo/Reveerb Effect
%Set gain and delay parameters strategically so that the speech is still
%understandable:
k=0.5;
D=1000;
A=zeros(1,D-1);
final=filter(1,[1 A -k],filtered);

filename='modified.wav';
audiowrite(filename,final,Fs);

%% Frequency Domain Analysis: %%%%
NFFT1=2^nextpow2(length(audio_samples));
S1=fft(audio_samples,NFFT1)/length(audio_samples);
freq=Fs/2*linspace(0,1,NFFT1/2+1);
NFFT2=2^nextpow2(length(modulated));
S2=fft(modulated,NFFT2)/length(modulated);
freq=Fs/2*linspace(0,1,NFFT2/2+1);
NFFT3=2^nextpow2(length(sum_delayed));
S3=fft(sum_delayed,NFFT3)/length(sum_delayed);
freq=Fs/2*linspace(0,1,NFFT3/2+1);
NFFT4=2^nextpow2(length(filtered));
S4=fft(filtered,NFFT4)/length(filtered);
freq=Fs/2*linspace(0,1,NFFT4/2+1);
NFFT5=2^nextpow2(length(final));
S4=fft(final,NFFT5)/length(final);
freq=Fs/2*linspace(0,1,NFFT5/2+1);


%% PLOTS: %%%%%%%%%

%Time domain:
figure(1)
subplot(2,3,1)
plot(t,audio_samples(:,1))
title('(a) Original Voice Audio')
xlabel('Time (s)')
ylabel('Amplitude')

subplot(2,3,2)
plot(t,modulated)
title('(b) After Amplitude Modulation')
xlabel('Time (s)')
ylabel('Amplitude')

subplot(2,3,3)
plot(t_delay,sum_delayed)
title('(c) After Robot Effect')
xlabel('Time (s)')
ylabel('Amplitude')

subplot(2,3,4)
plot(t_delay,filtered)
title('(d) After High Pass Filtering')
xlabel('Time (s)')
ylabel('Amplitude')

subplot(2,3,5)
plot(t_delay,final)
title('(e) Final - After Echo/Reverb Effect')
xlabel('Time (s)')
ylabel('Amplitude')


%Modulator (for the amplitude modulation step):
figure(2)
plot(t,modulator)
title('Modulating Wave')
xlabel('Time (s)')
ylabel('Amplitude')


%Frequency Domain:
figure(3)
subplot(2,3,1)
plot(freq,2*abs(S1(1:NFFT1/2+1)),'red') 
title('(a) Original Voice Audio - Spectrum')
xlabel('Frequency (Hz)')
ylabel('|S(f)|')

subplot(2,3,2)
plot(freq,2*abs(S2(1:NFFT2/2+1)),'red') 
title('(b) After Amplitude Modulation - Spectrum')
xlabel('Frequency (Hz)')
ylabel('|S(f)|')

subplot(2,3,3)
plot(freq,2*abs(S3(1:NFFT3/2+1)),'red') 
title('(c) After Robot Effect - Spectrum')
xlabel('Frequency (Hz)')
ylabel('|S(f)|')

subplot(2,3,4)
plot(freq,2*abs(S4(1:NFFT4/2+1)),'red') 
title('(d) After High Pass Filtering - Spectrum')
xlabel('Frequency (Hz)')
ylabel('|S(f)|')

subplot(2,3,5)
plot(freq,2*abs(S4(1:NFFT4/2+1)),'red') 
title('(e) Final - After Echo/Reverb Effect - Spectrum')
xlabel('Frequency (Hz)')
ylabel('|S(f)|')