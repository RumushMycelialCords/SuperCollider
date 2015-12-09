(// 1st
SynthDef(\perc1, {
	arg freq=100, dec1 = 2, dec2 = 4, gain = 250, ground = 0;
	var src, rnd, env, free;
	free = EnvGen.ar(Env.sine(dec2),doneAction:2);
	rnd = {arg rt,low,high; LFNoise2.ar(rt).range(low,high)};
	env = {arg dec; Decay.ar(Impulse.ar(0),dec!2,1-ground)+ground};
	src = GrainSin.ar(
		2, Dust.ar(freq*env.(dec1)), // Channels & Trig
		rnd.(2,0.00005,0.0005), // Grain Duration
		rnd.(dec2,freq/4,freq*8), // Grain Freq
		0,-1,1024,0.1 // Pan, Env, MaxGrain, Mul
	);
	src = src*env.(dec2)*gain;
	src = LPF.ar(src.fold(-0.5,0.5),10000,0.25);
	src = HPF.ar(src,100);
	Out.ar(0,src);
}).store
)
(// 2nd
SynthDef(\perc1, {
	arg freq=100, dec1 = 2, dec2 = 4, gain = 250, ground=0, gDur = 0.0005, pitchE = 1;
	var src, rnd, env, free, mod;
	free = EnvGen.ar(Env.sine(dec2),doneAction:2);
	rnd = {arg rt,low,high; LFNoise2.ar(rt!2).range(low,high)};
	env = {arg dec; Decay.ar(Impulse.ar(0),dec!2,1-ground)+ground};
	//mod = Splay.arFill(8, {Pulse.ar(rrand(freq,freq*4)*(env.(dec1)*pitchE))})*env.(dec2);
	//mod = Splay.arFill(8, {Blip.ar(rrand(freq,freq*4)*(env.(dec1)*pitchE),100)})*env.(dec2);
	//mod = Splay.arFill(8, {HenonC.ar(rrand(freq*4,freq*16)*(env.(dec1)*pitchE))})*env.(dec2);
	src = GrainSin.ar(
		2, Dust.ar(freq*(env.(dec1)*pitchE)!2), // Channels & Trig
		rnd.(freq*IRand(-2,2),gDur/2,gDur*2), // Grain Duration
		rnd.(dec2,freq/4,freq), // Grain Freq
		0,-1,1024,0.1 // Pan, Env, MaxGrain, Mul
	);
	src = src*env.(dec2)*gain;
	src = LPF.ar(src.fold(-0.5,0.5),250,0.25);
	src = FreqShift.ar(src,freq*IRand(1,4)*(env.(dec1)*pitchE));
	src = src ring2: mod;
	src = HPF.ar(src,100).tanh;
	Out.ar(0,src*0.25);
}).store
)
(
Pdef(\seq1,
	Pbind(
		\instrument, \perc1,
		\dec1, Pseq(Array.geom(3,0.125,1.25),inf), // Pitch Env
		\dec2, Pseq(Array.geom(5,0.25,1.25),inf), // Volume doneAction Env
		\gDur, Pseq(Array.geom(9,0.005,2),inf), // Average Grain Duration
		\freq, Pseq(Array.geom(7,250,1.5),inf), // Average Freq
		\gain, Pseq(Array.geom(6,25,2),inf), // Gain for distortion
		\pitchE, Pseq(Array.geom(11,1,0.75),inf), // Pitch Envelope Amount
		// \ground, Pseq([0.25,0.125,0.067,0],inf), // Lowest volume
		\dur, 0.125 // Duration
)).play
)
(
Pdef(\rndSeq,
	Pbind(
		\instrument, \perc1,
		\dur, 0.125,
		\dec2, 0.125,
		\dec1, Pwhite(0.025,1),
		\gDur, Pwhite(0.00005,0.5),
		\freq, Pwhite(5,750),
		\gain, Pwhite(25,500),
		\pitchE, Pwhite(0.5,1),
		\ground, Pwhite(0,0.125)
)).play
)
