s.recHeaderFormat = "wav";
s.prepareForRecord; // you have to call this first
s.record;
MIDIIn.connectAll
(
Ndef(\sound,{
	//I've prepared a couple of arguments to qucikly change the sound, but don't hesitate to add more
	/*
	tempo= lfos and delay time, dist= max distortion, octRange= octave range, octOffset= first degree,
	filtSpeef = speed of LPF modulation by LFTri, delLen= how many 4th notes the delay lasts,
	grainDur= max duration of a grain, grainSpeed= max speed of Impulse multiplied by tempo
	*/
	arg octRange=6, octOffset=36,
	dryWet=20, amp=0.0,
	lfo1S=0.5, lfo2S=0.1,
	grainSpeed=16, grainDur=0.1,
	carF=440, index=4,
	lpfF=1000,
	feedback=0.1;
	var lfo1, lfo2, winenv, env, scale, note, degreeNum, src, loc, out;
	lfo1 = {arg rt,lw,hg; LFNoise1.ar(rt).range(lw,hg)};//Arguments - Rate, Lowest Value, Highest Value
	lfo2 = {arg rt,lw,hg; SinOsc.kr(rt).range(lw,hg)};
	/*
	Pitch Control
	*/
	scale = Scale.melodicMinor; //Sets the scale
	degreeNum = scale.size-1; //Gets the number of degrees for the scale, I subtract 1 because the lfo works from 0.
	note = DegreeToKey.ar(scale.as(LocalBuf),
		lfo1.(lfo1S,0,degreeNum*octRange).round(lfo1.(lfo1S/2,1,7).round(1)),//lfo1.(rate=2,lowNum=0,highNum=degreeNum*4(4 octaves),round=another lfo
		scale.stepsPerOctave,1,octOffset).midicps;
	/*
	Source
	*/
	winenv = Env([0,0.5,0.25,1,0],[0.5,0.25,0.5],[8,-8]);
	env = Buffer.sendCollection(s,winenv.discretize,1);
	/*src = GrainFM.ar(2,
		Impulse.ar(lfo1.(tempo/4,tempo*(grainSpeed/8),tempo*grainSpeed,tempo)),
		lfo1.(tempo*3,grainDur/16,grainDur,grainDur/16),note,lfo1.(tempo*4,-1,1,0.1),
		env, 1024, 0.5);*/
	src = GrainFM.ar(2,
		Impulse.ar(lfo1.(lfo1S+0.1.rand,grainSpeed*0.5,grainSpeed)), grainDur,
		note,lfo1.(lfo1S,carF*0.1,carF),
		lfo2.(lfo2S+0.05.rand,0.0,index),LFNoise1.ar(lfo1S),env);
	/*
	Feedback
	*/
	loc = LocalIn.ar(2)+src;
	loc = DelayL.ar(loc,1,0.75+lfo1.(lfo1S!2,0.005,0.01)); //delLen 4th Notes at a given tempo (90BPM in this case)
	loc = LPF.ar(loc,lfo1.(lfo1S,lpfF*0.5,lpfF));
	loc = LeakDC.ar(loc);
	LocalOut.ar(loc*feedback);

	/*
	Output
	*/
	out = src*dryWet.linlin(0,127,1.0,0.0)+(loc*dryWet.linlin(0,127,0.0,1.0));
	Limiter.ar(out)*amp
}).play;
/*
I use Novation SL25 reMOTE MIDI controller, so change the numbers according to your gear.
*/
MIDIdef.cc(\vol, {arg ...args;
	switch(args[1],
		32, {Ndef(\sound).set(\dryWet, args[0])},
		33, {Ndef(\sound).set(\amp, args[0].lincurve(0,127,0.0,1.0,4))}
	)
},([32,33]));
MIDIdef.cc(\grainControl, {arg ...args;
	switch(args[1],
		24, {Ndef(\sound).set(\lfo1S, args[0].lincurve(0,127,0.05,128,4))},
		25, {Ndef(\sound).set(\lfo2S, args[0].lincurve(0,127,0.005,12.8,4))},
		26, {Ndef(\sound).set(\grainSpeed, args[0].lincurve(0,127,1,256,4))},
		27, {Ndef(\sound).set(\grainDur, args[0].lincurve(0,127,0.005,1,4))},
		28, {Ndef(\sound).set(\index, args[0].lincurve(0,127,0,100,4))}
	)
},((24..28)));
MIDIdef.cc(\feedbackControl, {arg ...args;
	switch(args[1],
		29, {Ndef(\sound).set(\lpfF, args[0].lincurve(0,127,100,10000,4))},
		30, {Ndef(\sound).set(\feedback, args[0].lincurve(0,127,0.0,1.25,-4))}
)},([29,30]));
)
