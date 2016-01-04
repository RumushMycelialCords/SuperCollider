(// SynthDef and Ndef
~tp = 145/60; // 145 BPM
SynthDef(\sin, {arg freq=50, lw=0, index=1000, lpF=20000, hpF=40, mix=0.75, dur, amp=0.125, pan=0, out=0;
	var env = {arg dr, ml; Decay.ar(Impulse.ar(0),dr,ml)};
	var src1 = SinOsc.ar(
		freq+env.(dur*Rand(0.05,0.125),freq*(IRand(4,16))),2pi,
		env.(dur,amp*mix)
	);
	var src2 = SinOscFB.ar(
		freq+(src1*index),Rand(lw,2),env.(dur*Rand(0.05,1),amp*(1-mix))
	);
	var src = Pan2.ar(src1+src2,pan);
	var free = DetectSilence.ar(src,doneAction:2);
	src = LPF.ar(src,lpF);
	src = HPF.ar(src,hpF);

	Out.ar(out,Compander.ar(src,src,0.25,1,1/4,0.01,0.1))
}).store;
Ndef(\delay, {
	var src = In.ar(2,2);
	var loc = LocalIn.ar(2)+src;
	loc = DelayC.ar(loc,1/~tp*2,LFNoise0.ar(~tp).range(0.125,1).round(0.25)/~tp);
	loc = FreqShift.ar(loc,LFNoise1.ar(3/~tp).range(-15,15));
	loc = loc+(loc ring4: WhiteNoise.ar(1*LFNoise1.ar(0.25)));

	LocalOut.ar(loc*0.5);
	Pan2.ar(loc,SinOsc.ar(2))
}).play
)
(
{
	var kick, snare, hihat, noise, fill1, rh1;
	fill1 = Pseq([Pseq([1],4),Pseq([0.125],8)],inf); // Fill used with a snare
	rh1 = Pwrand([0.5,1,0.25,0.125],[0.75,0.15,0.05,0.05],inf); // Different hihat rhythm
	~freq = 60; // Fundamental Frequency
	~bar = 1/~tp*16; //
	kick = Pbind(*[
		\instrument, \sin,
		freq: ~freq,
		lw: 0,
		index: 10,
		lpF: 20000,
		hpF: 40,
		mix: Pwhite(0.75,1),
		dur: 1/~tp,
		amp: 0.75,
		pan: 0,
		out: 0
	]);
	snare = Pbind(*[
		\instrument, \sin,
		freq: Pseq([\rest,~freq],inf),
		lw: 1.5,
		index: Pwhite(5000,7500),
		lpF: 15000,
		hpF: 100,
		mix: Pwhite(0.25,0.5),
		dur: 1/~tp,
		amp: 0.3,
		pan: 0,
		out: 0
	]);
	hihat = Pbind(*[
		\instrument, \sin,
		freq: ~freq,
		lw: 1.5,
		index: Pwhite(5000,15000),
		lpF: 17500,
		hpF: 500,
		mix: Pwhite(0,0.5),
		dur: 0.5/~tp,
		amp: 0.125,
		pan: Pwhite(-1.0,1.0),
		out: Pwrand([0,2],[0.95,0.05],inf)
	]);
	noise = Pbind(*[
		\instrument, \sin,
		freq: ~freq*4,
		lw: 1,
		index: Pwhite(150,300),
		lpF: 15000,
		hpF: 2500,
		mix: Pwhite(0,1),
		dur: 4/~tp,
		amp: 0.1,
		pan: 0,
		out: 2
	]);
	Pdef(\kick, kick).play; ~bar.wait;
	Pdef(\snare, snare).play; ~bar.wait;
	Pdef(\hihat, hihat).play; ~bar.wait;
	Pdef(\hihat2, hihat).play;
	Pbindef(\hihat2, \dur, 0.75/~tp); ~bar.wait;
	Pdef(\hihat3, hihat).play;
	Pbindef(\hihat3, \dur, 0.25/~tp, \amp, 0.125*Pseq([1,0.5],inf)); ~bar.wait;
	Pbindef(\snare, \dur, fill1/~tp, \freq, ~freq); ~bar.wait;
	Pbindef(\snare, \dur, 1/~tp);
	Pdef(\kick).pause; ~bar.wait;
	Pdef(\kick, kick).play;
	Pdef(\noise, noise).play;
	Pbindef(\hihat2, \dur, rh1/~tp, \freq, ~freq*4);

}.fork
)
