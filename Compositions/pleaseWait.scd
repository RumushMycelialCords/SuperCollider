(
s.recHeaderFormat = "wav"; // You have to change the format before calling 'prepareForRecord'
s.prepareForRecord;
Tdef(\pleaseWait, {
	var pick1 = 0;
	1.do{
		s.record;
	};
	8.do{
	// Frequence, Index (FM) and Rate
		var freq = Array.series(8, 60, 60); 
		var index = [20, 60, 40, 100].choose * (8..64).choose; // Index is randomly chosen from the first array and then multiplied by random number from 8 to 64
		var rate = Array.geom(16, 0.125, 1.251); // Rate speeds up by unequal amount to get some 'Phase Music' inspired rhythms
		var tM = [4,8].choose; // tM stands for time multiplier, it tells the envolope for how long it should rise (t*tM)
		t = [5, 10, 15].choose; // t is the time it takes to repeat the function
		("pick1"+pick1).postln;
		if(pick1 > 10,
			{tM = 1; t = 30}
		);
		("t"+t).postln;
		("tM"+tM).postln;
		play{
			var mainEnv = EnvGen.kr(Env.sine(t*tM, 1), doneAction:2); // Simple sine envelope that controls 

			var lfo1 = Mix.fill(4, {
				Pan2.ar(Lag2.ar(LFSaw.ar(Array.geom(8, 5, Rand(1.5, 2)).choose, 0, 1, 1)), 1.rand2);
			});

			var mod1 = SinOsc.ar(14400, 0, index); // FM Mod No.1
			var mod2 = if(0.65.coin, // FM Mod No.2 - There 65% chance that SinOsc will play and 35% that Crackle will
				{SinOsc.ar(7200+mod1, 0, index*lfo1.range(0,1))},
				{Crackle.ar(Rand(1.75, 2)!2, index)}
			);

			var src1 = SinOsc.ar((60+mod1)!2, 0, 1/16); // Simple bass modulated with 'mod1'
			var src2 = SinOsc.ar([freq.choose, freq.choose]+mod2, 0, 1/32); // It randomly picks different frequencies for each channel from 'freq' array at the top
			var src3 = if(0.5.coin.postln,
				{Mix.fill(4, {// Random freq, FM on/off, Amp rhythm and SinOsc panning - rate chosen from rate array
					Pan2.ar(SinOsc.ar(freq.choose*IRand(4, 8)+(mod2*[1, 0].choose), 0, Lag.ar(LFPulse.ar(rate.choose), 0.25)), SinOsc.ar(rate.choose)) 
				})*(1/128)},
				{Mix.fill(4, {// Same as above, except for random comb delay modulated by SinOsc
					Pan2.ar(CombC.ar(Saw.ar(freq.choose*IRand(2, 8)+(mod2*[1, 0].choose), Lag.ar(LFPulse.ar(rate.choose), 0.25)), 0.25, [Rand(0.0675, 0.125), Rand(0.0675, 0.125)]+SinOsc.ar(rate.choose, 0, 0.0675).unipolar), SinOsc.ar(rate.choose))
				})*(1/256)}
			);

			pick1 = pick1+1; // Progresses pick1 so after 8 repetitions 't' and 'tM' isn't random by 30 and 1, respectively

			(src1+src2+src3)*mainEnv
		};t.wait;
	};
	1.do{
		play{// Here I have used similar techniques so I let the code speak for itself
			var env1, env2, freq, pulse, dec, lfo, mod, sound1, sound2;
			"section2".postln;
			env1 = EnvGen.ar(Env([0,0.5,0], [10,80], 8));
			env2 = EnvGen.ar(Env([0,1,0], [30,90], 8),1,doneAction:2);
			freq = Array.geom(16, 60, 2);
			pulse = Array.series(16, 1, 1.01);
			dec = {|r,d| Decay.ar(Impulse.ar(r), d)};
			lfo = {|r,w| LFPulse.ar(r, 0, w)};
			mod = Mix.fill(16, {|i, pan=0|
				var env = EnvGen.kr(Env.circle([0, 1, 0.5, 10], [1, 0.5, 0.5+(i*0.25)]));
				Pan2.ar(SinOsc.ar(freq[i], 0, env), pan)
			});
			sound1 = SinOsc.ar(60+(mod*10), 0, 0.5);
			sound2 = Mix.fill(16, {|i|
				SinOsc.ar((mod.(0, lfo.(pulse[2], 0.5)-0.5)*100)+240*dec.(pulse[i], 0.05), 0, 0.05)
			});

			sound1*env1+(sound2*env2)
		}
	};
	1.do{
		120.wait;
		s.stopRecording;
	}
}).play
)
