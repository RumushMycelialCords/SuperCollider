(
SynthDef(\hasherTest,
{
arg rate = 1, freq = 60, index = 1000, tRate = 100,
out = 0, fRate = 0.1;

var t_trig = LFPulse.kr(0.5/fRate, 0.5);
var random = LFNoise0.ar(rate, add:1);
var noise = Hasher.ar(random);
var sound = Saw.ar((freq+(noise*index)), Decay.kr(Impulse.kr(tRate), noise*0.001)).tanh;
sound = Pan2.ar(sound, noise-0.3*2);
FreeSelf.kr(t_trig);
Out.ar(out, sound);
}).store;
)
