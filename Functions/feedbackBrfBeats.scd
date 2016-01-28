(
{
	var src, loc, lfo, bFreq, mFreq;
	var num=12, sLen=4; // Number of SinOsc in different Mix.fills and number of BRF in a series

	bFreq = Array.series(num,1000,1500); // Base Frequency of a BRF
	mFreq = Array.series(num,500,1000); // Modulation Frequecy of a BRF
	lfo = {arg rt,ml; LFNoise1.ar(rt,ml)};
	// Mix.fill - SinOsc with semi-random frequencies and decay envelopes controlled by Impulse with random freq
	src = Mix.fill(num*0.25,{SinOsc.ar(60,0,1/num*4)*Decay.ar(Impulse.ar(1.0.rand).round(0.25),1.0.rand)});
	src = src + (
		Mix.fill(num*0.5,{SinOsc.ar(600.rand.round(60),0,1/num*2)*Decay.ar(Impulse.ar(1.0.rand).round(0.25),0.1.rand)})*Duty.ar(sLen,0,Dseq([0,0.25],inf)
	));
	src = src + (
		Mix.fill(num,{SinOsc.ar(6000.rand.round(60),0,1/num)*Decay.ar(Impulse.ar(1.0.rand).round(0.25),0.05.rand)})*Duty.ar(sLen*2,0,Dseq([0,0.25],inf)
	));
	loc = LocalIn.ar(2)+src;
	loc = DelayC.ar(loc,1,1); // 1 Sec Delay, pulse of the beat
	//loc = DelayC.ar(loc,1,Duty.ar(sLen,0,Drand([0.5,1],inf)));
	loc = LPF.ar(loc.fold(-1,1),15000); // Distortion and cutoff so it's more pleasant to listen to
	num.do{arg i; loc = BRF.ar(loc,bFreq[i]+lfo.(1!2,mFreq[i]),0.5)}; // BRF Series
	loc = loc*Duty.ar(sLen*8,0,Dseq([1,0.75],inf))+(AllpassC.ar(loc,0.2,0.1,0.25)*Duty.ar(sLen*8,0,Dseq([0,0.25],inf)));
	loc = LeakDC.ar(loc);

	LocalOut.ar(loc*Duty.ar(Dseq([sLen*0.75,sLen*0.25],inf),0,Dseq([Dseq([1.2,0.9],32),Dseq([1.1],inf)],inf)));
	Limiter.ar(loc)*0.99
}.play
)
