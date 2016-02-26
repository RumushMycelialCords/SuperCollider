s.prepareForRecord;
s.recHeaderFormat = 'wav';
(
fork({
	1.do{s.record};
	1.wait;
	1.do(play{ // Put you sound function between curly brackets

	});
	(48/~t).wait; // How many 4th notes to wait in a given tempo - 48 in this case
	1.do{s.stopRecording}
})
)
(
{
	var mel, freq, amp, env, src;
	~t = 75/60;
	mel = Dseq([Dseq([49,52,54,51,52],2),Drand([49,54,56],2),Dseq([49,52,54,57,56],2)],inf);
	freq = Duty.ar(0.25/~t,0,mel)+12;
	amp = Duty.ar(0.125/~t,0,Dseq([1,0,1,1,1,0],inf));
	env = EnvGen.ar(Env.perc(
		LFSaw.ar(2/~t).range(0.0001,0.01),
		LFNoise1.ar(0.125*~t).range(0.2,0.5)),
		Trig.ar(amp)
	);
	src = XFade2.ar(
		LFTri.ar(freq.midicps!2,0,1*env),
		HenonC.ar(freq.midicps!2*4,LFNoise1.ar(0.5*~t!2).range(1.2,1.4),0.3,0,0,0.75*env),
		LFNoise0.ar(~t!2).round(0.5).lag(0.01)
	);
	src = MoogFF.ar(src,LFNoise1.ar(~t!2).range(5000,10000),1);
	XFade2.ar(src,CombC.ar(src,1,0.25/~t,1),LFNoise0.ar(~t).round(1).lag(0.01))
}.play
)
(
{
	var chord, freq, src;
	~t = 75/60;
	chord = [[49,52,56],[52,56,59],[47,51,54],[56,59,63]];
	chord = Dseq(
		[Dseq([chord[0],chord[1]],2),Drand([chord[2],chord[3]],2),Dseq([chord[0],chord[3]],1)],
		inf);
	freq = Duty.ar(4/~t,0,chord).lag(1/~t);
	src = Splay.arFill(6,{arg i;
		var oct = (24!3)++(48!3);
		var amp = (0.6!3)++(0.3!3)/2;
		XFade2.ar( // Sound
			GbmanL.ar(
			(freq[i%3]+oct[i]).midicps!2,
			LFNoise1.ar(~t).range(0.5,1.5),
			LFNoise1.ar(~t).range(1.5,2.5),
			amp[i]/4),
			LFTri.ar(
			(freq[i%3]+oct[i]).midicps!2/3,0,
			amp[i]),
			LFNoise1.ar(~t))
		*LFTri.ar(~t/TIRand.ar(4,16,Impulse.ar(~t/8))) // Amp
	})
}.play
)
