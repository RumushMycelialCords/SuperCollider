(// freq=4 a=1, b=-0.5
{
	var trig = QuadC.ar(4!2,1,-0.5,-0.75).abs.round(1);
	var freq = Stepper.ar(trig,0,100,600,100)*Duty.ar(2,0,Dseq([Dseq([1]),Drand([0.5,2,0.25,3])],inf));
	CombC.ar(LFTri.ar(freq,0,0.25*LFSaw.ar(1).abs),1,0.25,4)
}.play
)
(// freq=4 a=0.5, b=-1
{
	var trig = QuadC.ar(4!2,0.5,-1,-0.75).abs.round(1);
	var freq = Stepper.ar(trig,0,100,600,100)*Duty.ar(2,0,Dseq([Dseq([1]),Drand([0.5,2,0.25,3])],inf));
	CombC.ar(LFTri.ar(freq,0,0.25*LFSaw.ar(1).abs),1,0.25,4)
}.play
)
(// freq=4 a=1, b=Duty.ar(8,0,Drand([-0.5,-0.75,-0.8,-0.85,-1],inf))
{
	var trig = QuadC.ar(4!2,1,Duty.ar(8,0,Drand([-0.5,-0.75,-0.8,-0.85,-1],inf)),-0.75).abs.round(1);
	var freq = Stepper.ar(trig,0,100,600,100)*Duty.ar(2,0,Dseq([Dseq([1]),Drand([0.5,2,0.25,3])],inf));
	CombC.ar(LFTri.ar(freq,0,0.25*LFSaw.ar(1).abs),1,0.25,4)
}.play
)
(// freq=4 a=Duty.ar(8,0,Drand([0.5,0.75,0.8,0.85,1],inf)), b=-1
{
	var trig = QuadC.ar(4!2,Duty.ar(8,0,Drand([0.5,0.75,0.8,0.85,1],inf)),-1,-0.75).abs.round(1);
	var freq = Stepper.ar(trig,0,100,600,100)*Duty.ar(2,0,Dseq([Dseq([1]),Drand([0.5,2,0.25,3])],inf));
	CombC.ar(LFTri.ar(freq,0,0.25*LFSaw.ar(1).abs),1,0.25,4)
}.play
)
(// freq=Duty.ar(4,0,Drand(Array.series(4,1,1),inf))
 // a=Duty.ar(8,0,Drand([0.5,0.75,0.8,0.85,1],inf)), b=Duty.ar(8,0,Drand([-0.5,-0.75,-0.8,-0.85,-1],inf))
{
	var trig = QuadC.ar(
		Duty.ar(4,0,Drand(Array.series(4,1,1),inf))!2,
		Duty.ar(8,0,Drand([0.5,0.75,0.8,0.85,1],inf)),
		Duty.ar(8,0,Drand([-0.5,-0.75,-0.8,-0.85,-1],inf)),
		-0.75).abs.round(1);
	var freq = Stepper.ar(trig,0,100,600,100)*Duty.ar(2,0,Dseq([Dseq([1]),Drand([0.5,2,0.25,3])],inf));
	CombC.ar(LFTri.ar(freq,0,0.25*LFSaw.ar(1).abs),1,0.25,4)
}.play
)

(// Short Piece 1 - QuadC as FM Mod and as Stepper trigger to control frequency
{
	var mod = QuadC.ar(100,LFSaw.ar(0.08).range(0.1,1.0),LFSaw.ar(0.05).range(-0.1,-1.0),-0.5);
	var trig = QuadC.ar(
		Duty.ar(4,0,Drand(Array.series(4,1,1),inf)),
		Duty.ar(8,0,Drand([0.5,0.75,0.8,0.85,1],inf)),
		Duty.ar(8,0,Drand([-0.5,-0.75,-0.8,-0.85,-1],inf)),
		-0.75).abs.round(1);
	var pan = [-1.0,-0.25,0.25,1.0];
	var freq = Stepper.ar(trig,0,0,1250,250);
	var src = Mix.fill(4,{arg i;
		Pan2.ar(SinOscFB.ar(
			100.rand+(mod*10000.rand*XLine.kr(0.1,1,60,1,0,2))+freq,
			rrand(1.0,2.0),
			0.1)*FSinOsc.kr(0.5.rand).abs,pan[i])/4;
	});
	var loc = LocalIn.ar(2)+src;
	loc = DelayC.ar(loc,1,0.5);
	loc = FreqShift.ar(loc,-5);
	loc = Pan2.ar(loc,SinOsc.kr(0.1));

	LocalOut.ar(loc*XLine.ar(0.1,1,60,1,0,2));
	Limiter.ar(loc)
}.play
)
(// Piece 2 - QuadC used as a index control for DegreeToKey UGen
{
	var src, loc, scale, aB, buffer, freq, amp, fT, aT;
	aB = XLine.kr(0.5,1.75,90,1,0,2); // a and b argument of QuadC that controls frequency

	scale = Scale.minor;
	fT = QuadC.ar(0.25,aB,aB.neg, // aB = from 1.0 to 2.0 over 90 seconds
		LFNoise0.kr(0.5).range(-0.0,-0.5).round(0.1),0,7 // c argument LFNoise0 control, from -0.0, -0.5
	).abs.round(1);
	freq = DegreeToKey.kr(scale.as(LocalBuf),fT,scale.stepsPerOctave,1,48).midicps;

	aT = QuadC.ar(2,1,-1,LFNoise0.kr(0.5).range(-0.25,-1.0).round(0.125)).abs.round(1); // Trigger for amp Stepper
	amp = Stepper.ar(aT,0,2,8,3).lag(0.25)/8;

	src = XFade2.ar(SinOscFB.ar(freq+LFNoise1.kr(0.5!2,2),LFTri.kr(0.25).range(0.0,1.0),0.1*amp),
		SinOscFB.ar(freq+LFNoise1.kr(0.5!2,2)*2,LFTri.kr(0.2).range(0.0,1.0),0.1*amp), LFNoise1.kr(0.1));

	loc = LocalIn.ar(2)+src;
	loc = DelayC.ar(loc,1,0.5);
	loc = FreqShift.ar(loc,-5);
	loc = Pan2.ar(loc,SinOsc.kr(0.1));
	loc = HPF.ar(loc,100);

	LocalOut.ar(loc*XLine.ar(0.1,0.95,90,1,0,2));
	LPF.ar(Limiter.ar(loc),15000)
}.play
)
