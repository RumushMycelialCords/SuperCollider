s.recHeaderFormat = "wav";
s.prepareForRecord;
s.record;
(
Spec.add(\mFreq, [100,10000,\lin,100]);
Spec.add(\mDec, [0.01,0.5,\lin,0.01]);
Spec.add(\mDist, [10,10000,\exp,1]);
Spec.add(\fFreq, [500,10000,\exp]);
Ndef(\glitch,{
	var src = SinOsc.ar(TIRand.ar(50,\mFreq.kr,Dust.ar(LFNoise0.ar(2,60).abs)).round(1000),0,Decay.ar(Dust.ar(LFNoise0.ar(2!2,60).abs),LFNoise1.ar(14,\mDec.kr).abs));
	src = (src*LFNoise0.ar(6!2,\mDist.kr).abs).fold(-1,1);
	src = LPF.ar(src,\fFreq.kr);
	src
}).play;
Ndef(\glitch).gui
)
(
Spec.add(\rt1, [0.01,5,\exp,0.01]);
Spec.add(\rt2, [0.01,5,\exp,0.01]);
Spec.add(\freq, [50,250,\lin,50]);
Spec.add(\harm, [0,20,\lin,1]);
Spec.add(\do, [1,4,\lin,1]);
Ndef(\glitch2,{
	var rt1, rt2, freq, harm, blip, src;
	rt1 = \rt1.kr; rt2 = \rt2.kr; freq = \freq.kr; harm = \harm.kr;
	blip = {arg rt1, rt2, freq, harm; Blip.ar(LFNoise1.kr(rt1!2).range(freq,freq*2),SinOsc.kr(rt2).range(0,harm))};
	src = blip.(rt1, rt2, freq, harm) * 0.1;
	(\do.kr).do{arg i; src = src ring1: blip.(rt1-(0.1*(1+i)),rt2+(0.1*(1+i)),freq*(5+i),harm+(5*(1+i)))};
	LPF.ar(src,5000)
}).play;
Ndef(\glitch2).gui
)
(
Spec.add(\freq, [0,500,\lin,100]);
Spec.add(\pEnvRate, [1,16,\lin,1]);
Spec.add(\pSpeed, [1,16,\lin,0.25]);
Ndef(\back,{
	var src = Mix.fill(8, {arg i;
		CombC.ar(
			Pan2.ar(
				LFTri.ar(\freq.kr+rrand(100,2000).round(100)+Decay.ar(CoinGate.ar(0.01,Impulse.ar(\pEnvRate.kr)),0.1,1000)),
				LFTri.ar(1/rrand(10,20)*\pSpeed.kr)
			),0.5,rrand(0.05,0.25),4
		)/12
	});
	LPF.ar(src,5000)
}).play;
Ndef(\back).gui
)
(
Spec.add(\detune, [0,10,\lin,0.25]);
Spec.add(\lf1Speed, [0.25,16,\exp,0.25]);
Spec.add(\lf2Speed, [0.25,16,\exp,0.25]);
Ndef(\bass,{
	var bal = LFSaw.kr(0.1).range(0.05,0.125);
	var src = SinOscFB.ar(50+[0,\detune.kr],LFNoise1.ar((\lf2Speed.kr)!2,1.5).abs,1);
	src = LinXFade2.ar(
		src,
		src ring1: HenonC.ar(
			TIRand.ar(50,15000,Dust.ar(LFNoise0.ar(16,16).abs)).round(50),
			LFNoise1.ar((\lf1Speed.kr)!2).range(1.0,1.5),LFNoise1.ar((\lf1Speed.kr)!2).range(0.25,0.5)),
		LFNoise1.ar(1,bal)-(1-bal));
	Limiter.ar(src*0.5)
}).play;
Ndef(\bass).gui
)
