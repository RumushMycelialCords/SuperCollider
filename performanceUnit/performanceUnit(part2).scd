MIDIIn.connectAll
(
/*
Global Variables
*/
~len = 8;
~gBuf1 = Buffer.alloc(s, s.sampleRate*~len);
~gBuf2 = Buffer.alloc(s, s.sampleRate,*~len);
~gBuf3 = Buffer.alloc(s, s.sampleRate*~len);
~gBuf4 = Buffer.alloc(s, s.sampleRate,*~len);
~buf1 = Buffer.alloc(s, s.sampleRate*~len, 2);
~buf2 = Buffer.alloc(s, s.sampleRate*~len, 2);
~buf3 = Buffer.alloc(s, s.sampleRate*~len, 2);
~buf4 = Buffer.alloc(s, s.sampleRate*~len, 2);

/*
SynthDefs
*/
SynthDef(\tone1, {
	arg gate = 1, freq = 440, out = 2, index=100, modMix = 0, dur;
	var env = EnvGen.ar(Env.linen(0.0005, dur-0.001, 0.0005, 1, IRand(-8,-4)), gate, doneAction:2);
	var mod = SinOsc.ar(freq*Rand(0.25,2),0,index-(index*modMix))+HenonC.ar(freq*IRand(4,8),mul:index*modMix);
	var src = SinOsc.ar(freq+mod,0,0.125);

	Out.ar([out, out+1], src*env)
}).add;
SynthDef(\grain1, {
	arg gate = 1, out = 0, dur, freq=16, lfo=2, lfo2=1;
	var env = EnvGen.ar(Env.linen(0.0005, dur-0.001, 0.0005, 1, IRand(-8,4)), gate, doneAction:2);
	var src = GrainBuf.ar(2, Impulse.ar(freq), LFNoise0.ar(lfo).range(0.005,0.125), ~gBuf1,
		LFNoise0.ar(lfo2).range(-1,1), LFNoise0.ar(lfo).abs, 2, LFNoise0.ar(lfo2), -1, 1024, 0.25);
	Out.ar(out, src*env)
}).add;
SynthDef(\grain2, {
	arg gate = 1, out = 0, dur, freq=16, lfo=2, lfo2=1;
	var env = EnvGen.ar(Env.linen(0.0005, dur-0.001, 0.0005, 1, IRand(-8,4)), gate, doneAction:2);
	var src = GrainBuf.ar(2, Impulse.ar(freq), LFNoise0.ar(lfo).range(0.005,0.025), ~gBuf2,
		LFNoise0.ar(lfo2).range(-1,1), LFNoise0.ar(lfo).abs, 2, LFNoise0.ar(lfo2), -1, 1024, 0.25);
	Out.ar(out, src*env)
}).add;
SynthDef(\grain3, {
	arg gate = 1, out = 0, dur, freq=16, lfo=2, lfo2=1;
	var env = EnvGen.ar(Env.linen(0.0005, dur-0.001, 0.0005, 1, IRand(-8,4)), gate, doneAction:2);
	var src = GrainBuf.ar(2, Impulse.ar(freq), LFNoise0.ar(lfo).range(0.005,0.025), ~gBuf3,
		LFNoise0.ar(lfo2).range(-1,1), LFNoise0.ar(lfo).abs, 2, LFNoise0.ar(lfo2), -1, 1024, 0.25);
	Out.ar(out, src*env)
}).add;
SynthDef(\grain4, {
	arg gate = 1, out = 0, dur, freq=16, lfo=2, lfo2=1;
	var env = EnvGen.ar(Env.linen(0.0005, dur-0.001, 0.0005, 1, IRand(-8,4)), gate, doneAction:2);
	var src = GrainBuf.ar(2, Impulse.ar(freq), LFNoise0.ar(lfo).range(0.005,0.025), ~gBuf4,
		LFNoise0.ar(lfo2).range(-2,2), LFNoise0.ar(lfo).abs, 2, LFNoise0.ar(lfo2), -1, 1024, 0.25);
	Out.ar(out, src*env)
}).add;

/*
Patterns
*/
Pdef(\seq1,
	Pbind(\instrument, \tone1,
		\dur, Prand([0.5,0.5,1],8),
		\freq, Pwhite(25,12500,inf),
		\index, Pwhite(10,1000,inf),
		\modMix, Pwhite(0.0,1.0,inf),
		\out, Prand([2, 4, 6], inf)
)).play;
Pdef(\seq2,
	Pbind(\instrument, \grain1,
		\dur, Prand([1,0.25,0.25],inf),
		\freq, Pwhite(1,512,inf),
		\lfo, Pwhite(0.5,16,inf),
		\lfo2, Pwhite(0.25,1,inf),
		\out, Prand([0], inf)
)).play;
Pdef(\seq3,
	Pbind(\instrument, \grain2,
		\dur, Prand([1,0.5,0.5],inf),
		\freq, Pwhite(1,1024,inf),
		\lfo, Pwhite(0.5,16,inf),
		\lfo2, Pwhite(0.25,1,inf),
		\out, Prand([0], inf)
));
Pdef(\seq4,
	Pbind(\instrument, \grain3,
		\dur, Prand([1,1,0.5],inf),
		\freq, Pwhite(1,512,inf),
		\lfo, Pwhite(8,160,inf),
		\lfo2, Pwhite(2.5,10,inf),
		\out, Prand([0], inf)
));
Pdef(\seq5,
	Pbind(\instrument, \grain4,
		\dur, Prand([0.125,0.25,0.125],inf),
		\freq, Pwhite(1,128,inf),
		\lfo, Pwhite(0.5,16,inf),
		\lfo2, Pwhite(0.25,1,inf),
		\out, Prand([0], inf)
));

/*
Ndefs
*/
Ndef(\rd1, {
	arg note=36, vol = 0.125, rt = 1, rAmt = 127.rand;
	var rate = rt.linlin(0,127,-1.0,1.0).round(0.5);
	var bufWr = Phasor.ar(0,1,0,s.sampleRate*(~len-(~len*rAmt.linlin(0,127,0.0,1.0))))+(LFNoise2.ar(0.2!2).abs*(s.sampleRate*(~len*rAmt.linlin(0,127,0.0,1.0))));
	var src = BufRd.ar(2,~buf1,Phasor.ar(0,rate,0,s.sampleRate*~len));
	BufWr.ar(In.ar(2,2)*vol+src,~buf1,bufWr);
	BufWr.ar(In.ar(2,1)*vol+Mix.new(src),~gBuf1,bufWr);
	src
});
Ndef(\rd2, {
	arg note=36, vol = 0.125, rt = 1, rAmt = 127.rand;
	var rate = rt.linlin(0,127,-1.0,1.0).round(0.5);
	var bufWr = Phasor.ar(0,1,0,s.sampleRate*(~len-(~len*rAmt.linlin(0,127,0.0,1.0))))+(LFNoise2.ar(0.2!2).abs*(s.sampleRate*(~len*rAmt.linlin(0,127,0.0,1.0))));
	var src = BufRd.ar(2,~buf2,Phasor.ar(0,rate,0,s.sampleRate*~len));
	BufWr.ar(In.ar(4,2)*vol+src,~buf2,bufWr);
	BufWr.ar(In.ar(4,1)*vol+Mix.new(src),~gBuf2,bufWr);
	src
});
Ndef(\rd3, {
	arg note=36, vol = 0.125, rt = 1, rAmt = 127.rand;
	var rate = rt.linlin(0,127,-1.0,1.0).round(0.5);
	var bufWr = Phasor.ar(0,1,0,s.sampleRate*(~len-(~len*rAmt.linlin(0,127,0.0,1.0))))+(LFNoise2.ar(0.2!2).abs*(s.sampleRate*(~len*rAmt.linlin(0,127,0.0,1.0))));
	var src = BufRd.ar(2,~buf3,Phasor.ar(0,rate,0,s.sampleRate*~len));
	BufWr.ar(In.ar(6,2)*vol+src,~buf3,bufWr);
	BufWr.ar(In.ar(6,1)*vol+Mix.new(src),~gBuf3,bufWr);
	src
});
Ndef(\rd4, {
	arg note=36, vol = 0.125, rt = 1, rAmt = 127.rand;
	var rate = rt.linlin(0,127,-1.0,1.0).round(0.5);
	var bufWr = Phasor.ar(0,1,0,s.sampleRate*(~len-(~len*rAmt.linlin(0,127,0.0,1.0))))+(LFNoise2.ar(0.2!2).abs*(s.sampleRate*(~len*rAmt.linlin(0,127,0.0,1.0))));
	var src = BufRd.ar(2,~buf4,Phasor.ar(0,rate,0,s.sampleRate*~len));
	BufWr.ar(In.ar(8,2)*vol+src,~buf4,bufWr);
	BufWr.ar(In.ar(8,1)*vol+Mix.new(src),~gBuf4,bufWr);
	src
});

/*
MIDI Control
*/
MIDIdef.noteOn(\notes, {arg ...args; args.postln;
	Ndef(\rd1).set(\note, args[1]);
	Ndef(\rd2).set(\note, args[1]);
	Ndef(\rd3).set(\note, args[1]);
	Ndef(\rd4).set(\note, args[1])
});
MIDIdef.cc(\vol, {arg ...args; args.postln;
	switch(args[1],
		0, {Ndef(\rd1).set(\vol, args[0]/4)};
		1, {Ndef(\rd2).set(\vol, args[0]/4)};
		2, {Ndef(\rd3).set(\vol, args[0]/4)};
		3, {Ndef(\rd4).set(\vol, args[0]/4)}
	);
},(0..3)); // match cc 0 to 3
MIDIdef.cc(\rate, {arg ...args; args.postln;
	switch(args[1],
		8, {
			Ndef(\rd1).set(\rt, args[0]);
			Ndef(\rd2).set(\rt, args[0]);
			Ndef(\rd3).set(\rt, args[0]);
			Ndef(\rd4).set(\rt, args[0])
		},
		9, {
			Ndef(\rd1).set(\rAmt, args[0]);
			Ndef(\rd2).set(\rAmt, args[0]);
			Ndef(\rd3).set(\rAmt, args[0]);
			Ndef(\rd4).set(\rAmt, args[0])
		}
	);
},(8..11)); // match cc 8 to 11

/*
Play
*/
Pdef(\seq1).play;
Pdef(\seq2).play;
Pdef(\seq3).play;
Pdef(\seq4).play;
Pdef(\seq5).play;
Ndef(\rd1).play;
Ndef(\rd2).play;
Ndef(\rd3).play;
Ndef(\rd4).play
)
