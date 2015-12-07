(
Ndef(\fdbk1, {
	arg pul=0.25; // Pul=Pulse
	var src, loc, chords;
	chords = Duty.ar(1/(pul*1.5),0,
		Dseq([[48,63,67,72],[51,55,58,75],[60,63,67,72],[44,60,51,65]],inf)+Drand([-12,0,12],inf)
	); // C minor progression
	src = VarSaw.ar(chords.midicps/TIRand.ar(1,4,Dust.ar(pul!2)),0,LFNoise1.ar((pul/2)!4).abs,0.1).sum; // Source
	loc = LocalIn.ar(2)+src;
	loc = DelayC.ar(loc,36.midicps.reciprocal,chords[0].midicps.reciprocal);
	loc = DelayC.ar(loc,2/pul,[2/pul,2/pul-0.05.rand]);
	//loc = loc.softclip; // Uncomment for Distortion
	loc = LPF.ar(loc,LFNoise1.ar(pul!2).range(500,7500)); 
	LocalOut.ar(loc*LFPulse.ar(pul/16,0,0.75).range(0.5,1.5)); // Mess around with the gain
	loc = Limiter.ar(loc);

	loc*0.25
}).play
)
