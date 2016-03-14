(
var loop1 = Buffer.read(s,// Add Sample);
Ndef(\beatRep, {arg rep=0, delay=0.25;
	var in, tog, del1, del2, loc;
	// in = BufRd.ar(2,loop1,Phasor.ar(0,BufRateScale.kr(loop1)*1,0,BufFrames.kr(loop1)));
	in = LFTri.ar(Stepper.ar(Impulse.ar(2),0,100,700,200),0,0.25);
	loc = LocalIn.ar(2)+(in*(1-rep));
	tog = ToggleFF.ar(Changed.ar(K2A.ar(delay)))-0.5*2;
	del1 = DelayC.ar(loc,1,delay.lag(0.01));
	del2 = DelayC.ar(loc,1,delay.lag(0.01));
	loc = XFade2.ar(del1,del2,tog.lag(0.01));
	loc = FreqShift.ar(loc, -5);

	LocalOut.ar(loc*rep);

	XFade2.ar(in,loc,rep.linlin(0,1,-1.0,1.0));
});
Ndef(\lfo1,{SinOsc.ar(32)});
)
(
var delT = Pseq([64.reciprocal,8.reciprocal,16.reciprocal],inf).asStream;
fork{
	1.do{Ndef(\beatRep).play};
	2.wait;
	inf.do{
		Ndef(\beatRep).set(\rep, 2.rand, \delay, delT.next*Ndef(\lfo1).kr);
		0.5.wait;
		Ndef(\beatRep).set(\rep, 1);
		0.5.wait;
		Ndef(\beatRep).set(\rep, 0, \delay, delT.next*Ndef(\lfo1).kr);
		0.5.wait;
		2.do{
			Ndef(\beatRep).set(\rep, rrand(0.0,1.0).postln);
			0.25.wait;
		}
	}
}
)
