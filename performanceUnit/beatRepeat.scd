/*
2nd Draft
*/
(
// var loop1 = Buffer.read(s,); // Sample To Play Back
Ndef(\beatRep, {
	arg roll=0, delay=0.25, // Beat Rep Dry/Wet; Delay Time
	pShift=0, pDis=0, tDis=0, pShiMix=0, // Pitch Ratio; Pitch Dispersion; Time Disperion; Pitch Shift Dry/Wet
	fShift=64, fShiMix=0, // Frequency Shift, Freq Shift Dry/Wet
	lFreq=64, hFreq=64, bFreq=64, bRQ=0, // Low Pass Freq, High Pass Freq, Band Pass Freq, Band Pass Q
	lpMix=0, hpMix=0, bMix=0, // Low Pass Dry/Wet, High Pass Dry/Wet, BandPass Dry/Wet
	pan=64; // Panning 0=-1, 127=1

	var in, tog, del1, del2, loc;
	// Inputs
	// in = BufRd.ar(2,loop1,Phasor.ar(0,BufRateScale.kr(loop1)*1,0,BufFrames.kr(loop1))); // Sample Play Back
	in = Saw.ar(Demand.ar(Impulse.ar(8),0,Dseq([60,59,64,60,61,67,60,68,65].midicps,inf)),0.25);
	// Delay
	loc = LocalIn.ar(2)+(in*(1-roll));
	tog = ToggleFF.ar(Changed.ar(K2A.ar(delay)))-0.5*2; // Used for smoothing the delay change without getting pitch change - Needs Work
	del1 = DelayC.ar(loc,1,0.5/delay.lag(0.05)); // 0.5/delay because the loop is in 120BPM
	del2 = DelayC.ar(loc,1,0.5/delay.lag(0.05));
	loc = XFade2.ar(del1,del2,tog.lag(0.025));
	// Effects
	loc = LinXFade2.ar( // Pitch Shift
		loc,PitchShift.ar(loc,1,pShift.linlin(0,127,0.5,1.5),pDis.lincurve(0,127,0,1,4),tDis.lincurve(0,127,0,1,4)),
		pShiMix.linlin(0,127,-1,1));
	loc = LinXFade2.ar( // Freq Shift
		loc,FreqShift.ar(loc, fShift.lincurve(0,127,0,-10,10)),
		fShiMix.linlin(0,127,-1,1));
	loc = LinXFade2.ar( // Low Pass Filter
		loc,LPF.ar(loc, lFreq.lincurve(0,127,40,15000,4)),
		lpMix.linlin(0,127,-1,1));
	loc = LinXFade2.ar( // High Pass Filter
		loc,HPF.ar(loc, hFreq.lincurve(0,127,50,10000,4)),
		hpMix.linlin(0,127,-1,1));
	loc = LinXFade2.ar( // Band Pass Filter
		loc,BPF.ar(loc, bFreq.lincurve(0,127,100,10000,4), bRQ.lincurve(0,127,1,0.1,4)),
		bMix.linlin(0,127,-1,1));
	loc = OnePole.ar(loc,0.5);
	loc = OnePole.ar(loc,-0.1);

	LocalOut.ar(loc*roll); // Feedback

	Limiter.ar(Pan2.ar(XFade2.ar(in,loc,roll.linlin(0,1,-1.0,1.0)),pan.linlin(0,127,-1,1))); // Limited Output
});
)
(
var tim, delTArray, delT, roll,  // Variables
pitchShiftArray, pRatioS, pDisS, pTimeS, pMixS,
freqShiftArray, freqShiftS, freqMixS,
filterArray, filtFreqA, filtMixA, fFreqS, fMixS;

tim = 0.25; // Routine Wait Time
// Roll Variables
roll = Prand([Pseq([0,0.8,1,0],4),Pseq([0,1],2),Pseq([0.25,0.8,1,0.5],2),Pseq([0,1,0,1],2)],inf).asStream; // Roll Sequence
// Delay Time Variables
delTArray = Array.fill(11,{var arr = Array.geom(5,4,2); arr[5.rand]});
delT = Pseq(delTArray,inf).asStream;
// Pitch Shift Variables
pitchShiftArray = Array.fill(4,{Array.fill(10,{128.rand})}); // Creates 4 arrays with 10 values between 0 and 127 because there are 4 arguments for PitchShift. Same logic goes for FreqShift and Filters.
pRatioS = Pseq(pitchShiftArray[0],inf).asStream;
pDisS = Pseq(pitchShiftArray[1],inf).asStream;
pTimeS = Pseq(pitchShiftArray[2],inf).asStream;
pMixS = Pseq([Pseq([0],4),Pseq(pitchShiftArray[3],2)],inf).asStream.fold(0,32).round(16);
// Freq Shift Variables
freqShiftArray = Array.fill(2,{Array.fill(9,{128.rand})});
freqShiftS = Pseq(freqShiftArray[0],inf).asStream;
freqMixS = Pseq([Pseq([0],4),Pseq(freqShiftArray[1],2)],inf).asStream.round(32);
// Filter Variables
filterArray = Array.fill(3,{Array.fill(8,{128.rand})});
filtFreqA = [\lFreq,\hFreq,\bFreq];
filtMixA = [\lpMix,\hpMix,\bpMix];
fFreqS = Pseq(filterArray[0],inf).asStream;
fMixS = Pseq(filterArray[1],inf).asStream.round(64);

fork{
	1.do{Ndef(\beatRep).play};
	2.wait;
	inf.do{// Assigning values to different arguments based on variables above
		var filtC=3.rand;
		Ndef(\beatRep).set(
			\roll, roll.next, \delay, delT.next,
			\pShift, pRatioS.next, \pDis, pDisS.next, \tDis, pTimeS.next, \pShiMix, pMixS.next,
			\fShift, freqShiftS.next, \fShiftMix, freqMixS.next,
			filtFreqA[filtC], fFreqS.next, filtMixA[filtC], fMixS.next;
		);
		tim.wait;
	}
}
)
/*
1st Draft
*/
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
