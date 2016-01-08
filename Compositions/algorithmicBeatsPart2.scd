s.recHeaderFormat = "wav";
s.prepareForRecord;
(// SynthDef and Ndef
a = TempoClock.new(145/60);
a.permanent = true;
~bps = a.tempo;
SynthDef(\sin, {arg freq=50, dec=0.5, sus=0, amp=0.125, pan=0, out=0, gate=1, dist=0;
	var env = EnvGen.ar(Env.adsr(0.005,dec/~bps,sus,0.005),gate,doneAction:2);
	var src1 = SinOsc.ar(freq, 2pi, amp)+
	BPF.ar(HenonC.ar(freq*32,Rand(1.0,1.5),Rand(0.2,0.5),mul:amp*0.05),freq*16,Rand(0.0,0.5));
	var src2 = PinkNoise.ar(Decay.ar(Impulse.ar(0),0.0005,250)).fold(-0.25,0.25);
	var src = Pan2.ar(src1*env+src2,pan);
	src = src + ((src*dist).tanh*amp);

	Out.ar(out,Compander.ar(src,src,0.25,1,1/4,0.01,0.1))
}).store;
SynthDef(\noise, {arg dec=1, sus=0, lfo1=8, amp=0.125, pan=0, out=0, gate=1;
	var env = EnvGen.ar(Env.adsr(0.005,dec/~bps,sus,0.005),gate, doneAction:2);
	var src1 = PinkNoise.ar(amp*SinOsc.ar(lfo1))*env;
	var src = Pan2.ar(src1,pan);

	Out.ar(out, src);
}).store;
SynthDef(\saw, {arg freq=50, rel=0.5, amp=0.1, pan=0, out=0, gate=1;
	var env = EnvGen.ar(Env.perc(0.005, rel/~bps, amp),gate, doneAction:2);
	var src1 = Saw.ar(freq, env);
	var src2 = Saw.ar(freq*2, env*0.25);
	var src = Pan2.ar(src1+src2, pan);
	src = LPF.ar(src,5000);

	Out.ar(out, src);
}).store;
Ndef(\delay, {
	var src = In.ar(2,1);
	var loc = LocalIn.ar(1)+src;
	loc = DelayC.ar(loc,1/~bps*2,0.25/~bps);
	loc = FreqShift.ar(loc,LFNoise1.ar(3/~bps).range(-15,15));
	loc = loc+(loc ring4: WhiteNoise.ar(1*LFNoise1.ar(0.25)));

	LocalOut.ar(loc*0.75);
	Pan2.ar(Limiter.ar(loc),SinOsc.ar(3/~bps))*0.5
}).play;
Ndef(\delay2, {
	var src = In.ar(4,1);
	var loc = LocalIn.ar(1)+src;
	loc = DelayC.ar(loc,1/~bps*2,0.5/~bps);
	loc = ((loc*LFNoise1.ar(2/~bps).range(1,4)).softclip)*0.25;
	loc = HPF.ar(loc, LFNoise1.ar((4/~bps)!2,500,500));

	LocalOut.ar(loc*0.75);
	Pan2.ar(Limiter.ar(loc),SinOsc.ar(2/~bps))*0.5
}).play;
)
(
{
	var kick, snare, hihat, long, noise, melody, pul1, pul2, pul3, rRt1, rRt2, rRt3, rRt4, rA, pShuf;
	/*
	Constant Pulses
	*/
	pul1 = {arg rep; Pseq([1],rep)};
	pul2 = {arg rep; Pseq([0.5],rep)};
	pul3 = {arg rep; Pseq([0.25],rep)};
	/*
	Random Rhythm Patterns
	*/
	rRt1 = {arg rep; Pwrand([0.5,1,2],[0.15,0.7,0.15],rep)};
	rRt2 = {arg rep; Pwrand([1,0.25,0.5],[0.05,0.7,0.25],rep)};
	/*
	Rhythm Array function to be used with Pshuf. Arguments: ac=Accent, gh=Ghost, qu=Quiet.
	*/
	rA = {arg ac,gh,qu; Array.fill(ac,{rrand(1,0.9)})++Array.fill(gh,{rrand(0.75, 0.5)})++Array.fill(qu,{0})};
	pShuf = {arg ar, rep; Pshuf(ar, rep)};
	~freq = 60; // Fundamental Frequency
	~bar = 1/~bps*4;
	kick = Pbind(*[
		\instrument, \sin,
		freq: ~freq,
		dec: Pwhite(0.5,1),
		sus: Pwhite(0.0,0.125),
		amp: 0.75*Pseq([pShuf.(rA.(10,4,2),2)],inf),
		pan: 0,
		out: 0,
		dist: 8,
		dur: Pseq([pul1.(4),rRt1.(2)],inf),
	]);
	snare = Pbind(*[
		\instrument, \sin,
		freq: ~freq*Pstutter(Prand([1,2,6], inf), Pseq([Pseries(2,2,7)],inf)),
		dec: 0.5,
		sus: Pwhite(0.0,0.125),
		amp: 0.05*Pseq([pShuf.(rA.(5,2,4),3)],inf),
		pan: 0,
		out: Pwrand([0,2,4],[0.8,0.1,0.1],inf),
		dist: Pwrand([25,10,0.5],[0.5,0.4,0.1],inf),
		dur: Pseq([pul2.(8),rRt2.(2)],inf),
	]);
	hihat = Pbind(*[
		\instrument, \sin,
		freq:~freq*Pstutter(Prand([2,4,6],inf),Pseq([Pseries(4,2,8)],inf)),
		dec: 0.5,
		sus: Pwhite(0.0,0.125),
		amp: 0.01*Pseq([pShuf.(rA.(4,8,4),5)],inf),
		pan: Pwhite(-1.0,1.0),
		out: 0,
		dist: Pwrand([100,50],[0.75,0.25],inf),
		dur: Pseq([pul3.(4),rRt2.(2)],inf),
	]);
	long = Pbind(*[
		\instrument, \sin,
		freq: ~freq*16,
		dec: 4,
		sus: Pwhite(0.0,0.125),
		amp: 0.025,
		pan: 0,
		out: 0,
		dist: Pwrand([4,2],[0.25,0.75],inf),
		dur: Pseq([rRt4.(inf)],inf),
	]);
	noise = Pbind(*[
		\instrument, \noise,
		dec: Pseq([Pseries(0.05,0.01,12)],inf),
		amp: 0.05*Pseq([pShuf.(rA.(1,4,3),8)],inf),
		pan: Pwhite(-1.0,1.0),
		out: Pwrand([0,2],[0.9,0.1],inf),
		dur: Pseq([pul2.(4),rRt2.(2),pul3.(10)],inf)
	]);
	melody = Pbind(*[
		\instrument, \saw,
		freq: ~freq*Pstutter(Prand([2,3],inf),Pseq([4,3,5,6,4,7],inf)),
		rel: Pwhite(0.25,1),
		pan: Pwhite(-0.5,0),
		out: Pwrand([0,2],[0.8,0.2],inf),
		amp: Pwrand([0.05,0],[0.95,0.05],inf),
		dur: 0.25
	]);

	//s.record;
	(~bar).wait;
	Pdef(\kick, kick).play(a);
	(~bar*4).wait;
	Pdef(\snare, snare).play(a);
	Pdef(\hihat, hihat).play(a);
	(~bar*4).wait;
	Pdef(\long, long).play(a);
	Pdef(\noise, noise).play(a);
	(~bar*2).wait;
	Pdef(\noise2, noise).play(a);
	Pbindef(\noise2, \sus, 0.25, \lfo1, Pseq([Pseries(4,3,13)],inf), \dur, Pseq([pul1.(2)],inf), \amp, Pseq([0,0.1],inf), \out, 0);
	(~bar*16).wait;
	Pdef(\crash, noise).play(a);
	Pbindef(\crash, \dec, 16, \lfo1, 100, \amp, 0.125, \dur, Pseq([8],1), \out, 0);
	Pdef(\kick).stop;
	Pdef(\snare).stop;
	(~bar*8).wait;
	Pdef(\crash, noise).play(a);
	Pbindef(\kick2, \dec, 0.75, \amp, 0.5, \dur, pul2.(inf));
	Pdef(\kick2, kick).play(a);
	Pbindef(\kick, \freq, ~freq*4, \amp, 0.1);
	Pdef(\kick).play(a);
	Pdef(\snare).play(a);
	(~bar*8).wait;
	Pdef(\melody, melody).play(a);
	Pdef(\kick).stop;
	Pdef(\snare).stop;
	(~bar*2).wait;
	Pdef(\kick).play(a);
	Pdef(\snare).play(a);
	Pbindef(\melody2, \dur, 0.75, \amp, 0.01, \pan, Pwhite(0,0.5));
	Pdef(\melody2, melody).play(a);
	(~bar*4).wait;
	//s.stopRecording;

}.fork
)
