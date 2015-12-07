(// Careful it can get loud!
Ndef(\fdbk2, {
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
