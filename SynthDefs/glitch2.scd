(
SynthDef(\chaosGlitch3, {
arg len = 10, fundFreq = 40, henA = 2, henB = 0.4, t = 1, gate = 1;
var mainEnv = EnvGen.kr(Env.triangle(len,1), gate, doneAction:2);
var speed = Array.geom(4, t, [1.75, 1.25].choose);
var freq = Array.geom(8, fundFreq*2, 1.5);
var pulse = {|rat1,rat2|LFPulse.ar(rat1, [0,0.5,1].choose)*LFPulse.ar(rat2)};
var a = Lag.ar(HenonN.ar(
speed.choose*(mainEnv*Rand(0,10000)),
henA, henB,
), 0.01);
var bass = SinOsc.ar(fundFreq!2*(a*1.rand), 0, Lag.ar(pulse.(t, speed.choose), 0.001));
var tone1 = SinOsc.ar([(fundFreq+Rand(0,5))*a,(fundFreq+Rand(0,5))*a], 0, 0.01*pulse.(speed.choose, speed.choose));

var tone2 = Pan2.ar(SinOsc.ar(freq.choose*a, 0, 0.1*pulse.(speed.choose, t)), a);
var tone3 = SinOsc.ar([freq.choose,freq.choose*a], 0, 0.05*pulse.(speed.choose, t))*mainEnv.round(0.25);
var noise = Pan2.ar(PinkNoise.ar(a*0.1*pulse.(t,t)), a);
var impulse = RLPF.ar(Impulse.ar(pulse.(t, speed.choose), a), freq.choose+(a*10), 0.01, 0.1).tanh;
var kick = MoogFF.ar(SinOsc.ar(fundFreq+(Decay.ar(Impulse.ar(t), 0.05*a, freq.choose)), 0, Decay.ar(Impulse.ar(t), 0.5,2)).tanh, 1000);

Out.ar(0, (bass+tone1+tone2+tone3+noise+impulse+kick).tanh);
}
).store;
)
