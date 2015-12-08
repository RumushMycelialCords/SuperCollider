(// Careful it can get loud!
Ndef(\fdbk1, {
	var src, sr1, sr2, sr3, loc, freq, rt;
	src = Saw.ar([60,60.5,61]*XLine.ar(1,8,4),0.05).sum; // Simple detuned saw with freq envelope
	loc = LocalIn.ar(2)+src;
	loc = DelayC.ar(loc,4,4); // 4 second delay, try shorter/longer (I've been using 8 before, can get some nice rhythms
	// sr1 to sr3 are the effects LFPulse controls the volume being fed so you can get some rhythm
	sr1 = MoogFF.ar(loc*LFPulse.ar(1,0,0.125),LFNoise1.ar(0.125!2).range(250,15000),0);
	sr2 = FreqShift.ar(loc*LFPulse.ar(3,0,0.125),LFNoise1.ar(0.25!2).range(-10,10),0);
	sr3 = MoogFF.ar(loc*LFPulse.ar(4),LFNoise1.ar(0.5!2).range(250,15000),0);
	loc = sr1+sr2+sr3;
	// Filtering for control
	loc = LPF.ar(loc,7500);
	loc = HPF.ar(loc,40);
	// Feedback Gain
	LocalOut.ar(loc*25);
	loc = LPF.ar(loc.tanh,5000);

	loc*0.75
}).play
)
(
Ndef(\fdbk2, {
	var src, sr1, sr2, sr3, sr4, loc, rt, step;
	step = Stepper.ar(Impulse.ar(0.5),0,1,LFPulse.ar(0.75)*9+8,5); // Steps for pitch manipulation
	src = Saw.ar(LFNoise1.ar(0.5*step,100,200*(step%3)),0.05); // Source; Pitch Controlled by LFNoise1 and Stepper
	loc = LocalIn.ar(2)+src; // Beginning of a loop
	loc = DelayC.ar(loc,8,4); // 4 Sec Delay
	// Allpass Network - Source http://sccode.org/1-j
	2.do{loc=AllpassL.ar(loc,0.3,{0.29.rand+SinOsc.ar(0.5.rand,0,0.01).abs}!2,5)}; // Allpass Network
	loc = FreqShift.ar(loc,-25);
	loc = LPF.ar(loc,5000);
	loc = HPF.ar(loc,50);
	// loc = loc.softclip;
	loc = loc.tanh;
	// Feedback Gain
	LocalOut.ar(loc*2);
	loc = LPF.ar(Limiter.ar(loc),5000);

	loc*0.75
}).play
)
