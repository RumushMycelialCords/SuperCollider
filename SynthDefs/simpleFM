(
SynthDef(\carrier, {
	|inbus = 2, outbus = 0,
	freq = 440, carPartial = 1, mul = 0.2
	att = 2, sus = 1, rel = 5, gate = 1|

	var mod;
	var car;
	var env;

	mod = In.ar(inbus, 1);
	env = EnvGen.kr(Env.asr(att, sus, rel -4), gate, doneAction:2);

	Out.ar(outbus, SinOsc.ar((freq * carPartial) + mod, 0, mul)*env);

}).store;

SynthDef(\modulator, {
	|outbus = 2,
	freq = 440, modPartial = 1, index = 3
	att = 2, sus = 1, rel = 5, gate = 1|

	var env;

	env = EnvGen.kr(Env.asr(att, sus, rel -4), gate, doneAction:2);

	Out.ar(outbus, SinOsc.ar(freq * modPartial, 0, freq)
		*
		LFNoise1.kr(Rand(3, 6).reciprocal).abs
		*
		index
	) *env;
}).store;
)
