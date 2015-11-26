(
SynthDef(\glitch, {
arg freq1=40,freq2=200,freq3=100,dec1=1,dec2=0.5,gain,=250,index=100,hFreq=1000,lFreq=10000,amp=0.125;

var aEnv = Decay.ar(Impulse.ar(0),dec1);
var pEnv = Decay.ar(Impulse.ar(0),dec2);
var free;

var sound = Pan2.ar(Saw.ar(freq1,0.25),Saw.ar(freq2+SinOsc.ar(freq3*pEnv,0,index)))*gain;
sound = HPF.ar(sound,hFreq);
sound = sound*PinkNoise.ar;
sound = LPF.ar(sound,lFreq);
sound = sound.tanh;
sound = sound*aEnv;
free = DetectSilence.ar(sound,doneAction:2);

Out.ar(0,sound*amp);
}).store;
)
