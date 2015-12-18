(// Minor
~rep = 0; // Used to change the '~root' note
Tdef(\amb, {
	11.do{
		~tim = 16; // Time it takes for it to repeat, also affects lfos speed etc.
		~notes = Array.series(11,48,1); // C2 to B2
		~root = ~notes[~rep]; // Root Note
		~root.postln;
		~rep = ~rep+1;
		play
		{
			var env = Line.ar(0,1,~tim*1.01,1,0,2); // Used to free the synth

			var src = Mix.fill(8,{arg i; // Creates the evolving chord
				var chord = [0,3,7,12,15,19,22,24]; // Array of notes that get added to '~root' based on 'i.rand'
				Blip.ar((~root+chord[i.rand]).midicps,exprand(5,10)*LFNoise1.ar(1/~tim*rrand(2,4)).abs,1/32*SinOsc.ar(1/(~tim*rrand(0.5,4.0)),rrand(0,25)).abs)!2
			}); // Harmonics and Volume are modulated by LFNoise1 to make the chord change over time, their speed is affected by '~tim'
			var out = Splay.arFill(8, {// Adds some noise to 'src' and spreads it across stereo 
				src+BPF.ar(
					PinkNoise.ar(0.125*SinOsc.ar(1/(~tim*rrand(0.5,4.0)),rrand(0,25)).abs),~root.midicps*rrand(2,16),0.5)});
			out.softclip*EnvGen.ar(Env.linen(0.005,~tim*0.9,~tim*0.1))
	};(~tim*1.01).wait
	}
}).play
)
(// Major
~rep = 0;
Tdef(\amb, {
	11.do{
		~tim = 16;
		~notes = Array.series(11,48,1);
		~root = ~notes[~rep];
		~root.postln;
		~rep = ~rep+1;
		play
		{
			var env = Line.ar(0,1,~tim*1.01,1,0,2);

			var src = Mix.fill(8,{arg i;
				var chord = [0,4,7,12,16,19,23,24];
				Blip.ar((~root+chord[i.rand]).midicps,exprand(5,10)*LFNoise1.ar(1/~tim*rrand(2,4)).abs,1/32*SinOsc.ar(1/(~tim*rrand(0.5,4.0)),rrand(0,25)).abs)!2
			});
			var out = Splay.arFill(8, {
				src+BPF.ar(
					PinkNoise.ar(0.125*SinOsc.ar(1/(~tim*rrand(0.5,4.0)),rrand(0,25)).abs),~root.midicps*rrand(2,16),0.5)});
			out.softclip*EnvGen.ar(Env.linen(0.005,~tim*0.75,~tim*0.25))
	};(~tim*1.01).wait
	}
}).play
)
