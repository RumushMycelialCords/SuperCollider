(// Synth Defs - Run First
SynthDef(\clock, {arg rt=2;
	Out.kr(0,Impulse.kr(rt))
}).add;
SynthDef(\click, {arg rt=0.5, speed=1, open=0.1;
	var src, seq;
	seq = Demand.kr(In.kr(0),0,Drand([Dseq([4],4),Dseq([2],2),1,2],inf))/speed;
	src = PinkNoise.ar()*LFPulse.kr(seq,0,LFSaw.kr(rt).range(0.001,open)) ring1: SinOsc.ar(LFSaw.kr(rt*1.45).range(100,10000));
	src = (src*LFSaw.kr(rt*2,1).range(1,10)).fold(-1,1);
	src = Pan2.ar(src,LFSaw.kr(rt*1.8,0,0.25)+LFNoise1.kr(rt,0.75));

	Out.ar(0,src*0.01)
}).add;
SynthDef(\bass, {arg rt=0.5, speed=1, rel=0.5;
	var src, seq;
	seq = Demand.kr(In.kr(0),0,Drand([4,Dseq([2],2),8,2,Dseq(2!3++6)],inf))/speed;
	src = SinOsc.ar(60+Decay.kr(PulseDivider.kr(Impulse.kr(seq),2),LFSaw.kr(rt*0.7).range(rel/8,rel/4),720));
	src = src*Decay.kr(Impulse.kr(seq),LFSaw.kr(rt*1.8).range(rel/4,rel));
	src = (src*LFSaw.kr(rt*2,1).range(5,25)).tanh;
	src = LPF.ar(src,250+Decay.kr(Impulse.kr(seq),LFSaw.kr(rt*1.8).range(rel/4,rel)*0.1,10000));
	src = Pan2.ar(src,0);

	Out.ar(0,src*0.5)
}).add;
SynthDef(\pad, {arg freq=1000, lpf=500, rt=0.125, div=4;
	var src, env;
	env = EnvGen.kr(Env.linen(0.125,0.25,0.125),PulseDivider.kr(In.kr(0),div));
	src = SinOsc.ar(freq) ring1: LFTri.ar(freq*TIRand.kr(1,3!2,Impulse.kr(rt)));
	src = LPF.ar(
		src,LFSaw.kr(rt*0.6).range(lpf/2,lpf*2)+LFTri.kr(rt*16).range(lpf/8,lpf/4)
	);
	src = src*env;

	Out.ar(15,src*0.025);
}).add;
SynthDef(\crash, {arg div=8;
	var src, env;
	env = EnvGen.kr(Env.linen(0.001,0,2.5),PulseDivider.kr(In.kr(0),div));
	src = PinkNoise.ar();
	src = src*env;
	src = Pan2.ar(src);

	Out.ar(0,src*0.05);
}).add;
SynthDef(\delay, {
	var in, loc;
	in = In.ar(15,2);
	loc = LocalIn.ar(2)+in;
	loc = DelayC.ar(loc,0.5,0.25);

	LocalOut.ar(loc*0.75);
	Out.ar(0,Limiter.ar(loc))
}).add;
)
(// Composition Routine - It doesn't always play 'pad' function, I usually have to run it two or three times. I don't know why.
var clicks = Group.new;
var pads = Group.new;
var click = {arg mod1, mod2, mod3; Routine{
	var rt = [1,0.25,0.4]*mod1;
	var speed = [3,8,0.5]*mod2;
	var open = [0.1,0.05,0.25]*mod3;
	var tim = [4,8,8];
	3.do{arg i;
		Synth(\click,[\rt, rt[i], \speed, speed[i], \open, open[i]],clicks);
		tim[i].wait;
	};
}};
var pad = {arg notes=[48,51,55,62], div=[4,9,6,15]; Routine{
	(notes.size).do{arg i;
		Synth(\pad,[\freq, notes[i].midicps, \div, div.wrapAt(i)],pads);
	};
}};
fork{
	~clock = Synth(\clock);
	~del = Synth(\delay);
	pad.([48,51,55,58,62],[5,9,6,15]).play;
	16.wait;
	2.do{
		click.(rrand(1,4),rrand(1,4),rrand(1,4)).play;
		16.wait;
	};
	clicks.free;
	~bass = Synth(\bass);
	~crash = Synth(\crash);
	32.wait;
	pads.free;
}
)
