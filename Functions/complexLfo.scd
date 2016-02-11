(
{
	var bpm = 80/60; // Tempo
	var num = [3,1,4,1,5,9,2,6,5,3,5,9]/32; // First 12 Digits of Pi - divided by 32 for slow change
	var sideChain = {arg src, clk, div, rel; Compander.ar(src, // Side-Chain Setup
		PulseDivider.ar(Impulse.ar(bpm*clk),div),0.05,1,0.1,0.0001,rel/bpm)
	};
	var mod = {arg off, oscT; // Three SinOsc added to each other, their rate is dependent upon 'BPM' and 'num' array. I wanted to simplify control, hence just one argument. It picks the numbers from 'num' thorugh foldAt then it gets divided by bpm to stay in sync
		var osc = [SinOsc,LFTri,Saw,Pulse];
		osc[oscT].kr(num.foldAt(off)/bpm,0,0.5)+
		osc[oscT].kr(num.foldAt(off*2)/bpm,0,0.25)+
		osc[oscT].kr(num.foldAt(off*3)/bpm,0,0.25)
	};
	var src = {arg freq,off,osc; XFade2.ar(LFTri.ar(freq),SinOsc.ar(freq*2),mod.(off,osc))};
	/*
	Arguments:
	sideChain.(src.(freq, lfoRate, lfoOsc)*amp, clockRate, clockDivision(How many triggers to pass through), side-chain release
	*/
	sideChain.(src.(100!2,0,0)*0.6,1,2,1)+
	sideChain.(src.(200!2,1,1)*0.2,2,3,0.5)+ // sideChain.(src.(400!2,LFNoise0.kr(8/bpm,8),0)*0.1,4,2,0.125)+ // Problem
	sideChain.(src.(300!2,2,1)*0.1,2,5,0.5);
}.play
)
