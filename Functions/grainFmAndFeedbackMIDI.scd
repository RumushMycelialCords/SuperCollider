MIDIIn.connectAll
(
Ndef(\sound,{
	//I've prepared a couple of arguments to qucikly change the sound, but don't hesitate to add more
	/*
	tempo= lfos and delay time, dist= max distortion, octRange= octave range, octOffset= first degree,
	filtSpeef = speed of LPF modulation by LFTri, delLen= how many 4th notes the delay lasts (0 to 16),
	grainDur= max duration of a grain, grainSpeed= max speed of Impulse multiplied by tempo
	*/
	arg octRange=4, octOffset=36, grainDur=0.25, grainSpeed=8, delLen=8, dist=1, filtSpeed=0.5, fdbk= 0.5, tempo= 1.5, index= 100, tRnd=0;
	var lfo1, tir, winenv, env, scale, note, degreeNum, src, loc;
	lfo1 = {arg rt,lw,hg,rd; LFNoise0.ar(rt).range(lw,hg).round(rd)};//Arguments - Rate, Lowest Value, Highest Value, Round
	tir = TIRand.kr(1,32,Dust.kr(tRnd));
	/*
	Pitch Control
	*/
	scale = Scale.melodicMinor; //Sets the scale
	degreeNum = scale.size-1; //Gets the number of degrees for the scale, I subtract 1 because the lfo works from 0.
	note = DegreeToKey.ar(scale.as(LocalBuf),
		lfo1.(tempo*tir,0,degreeNum*octRange,lfo1.(tempo/tir,1,7,1)),//lfo1.(rate=2,lowNum=0,highNum=degreeNum*4(4 octaves),round=another lfo
		scale.stepsPerOctave,1,octOffset).midicps;
	/*
	Source
	*/
	winenv = Env([0,0.5,0.25,1,0],[0.5,0.25,0.5],[8,-8]);
	env = Buffer.sendCollection(s,winenv.discretize,1);
	src = GrainFM.ar(2,
		Impulse.ar(lfo1.(tempo/tir,tempo*(grainSpeed/tir),tempo*grainSpeed,tempo)),
		lfo1.(tempo*3,grainDur/tir,grainDur,grainDur/tir),note,note/lfo1.(tempo*tir,1,8,0.25),index,lfo1.(tempo*tir,-1,1,0.1),
		env, 1024, 0.5);
	/*
	Feedback
	*/
	loc = LocalIn.ar(2)+src;
	loc = DelayL.ar(loc,8,delLen.lag(8)); //delLen 4th Notes at a given tempo (90BPsM in this case)
	loc = loc + //Loc + Filtered/FrequencyShifted/Distorted Loc Parameters are modulated with lfo1 function (LFNoise0)
	LPF.ar(
		FreqShift.ar(
			((loc*lfo1.(tempo*tir,1,25,1)).softclip*LFSaw.ar(tempo/tir,0,dist).abs)
			,-1*note),
		5000);
	loc = LPF.ar(loc, LFTri.ar(tempo*tir,0,2500,10000).abs); //Simple Low Pass Filter, Freq controlled by Triangle Wave
	//2.do{loc = AllpassC.ar(loc,0.5,LFNoise1.ar(0.005!2,0.05,0.125).abs,1)}; //Higher/Lower 'do' value will result in more/less noisy sound
	loc = LeakDC.ar(loc);

	LocalOut.ar(loc*fdbk);
	Limiter.ar(loc)*0.95
}).play;
/*
I use Novation SL25 reMOTE MIDI controller, so change the numbers according to your gear.
*/
MIDIdef.cc(\freqControl, {arg ...args;
	switch(args[1],
		0, {Ndef(\sound).set(\octRange, args[0])}, // Expected values - 1 to 8
		1, {Ndef(\sound).set(\tRnd, args[0]*2)},
		8, {Ndef(\sound).set(\octOffset, args[0])} // Expected values - 0 to 127
	)
},([0,8]));
MIDIdef.cc(\grainControl, {arg ...args;
	switch(args[1],
		24, {Ndef(\sound).set(\grainDur, args[0].lincurve(0,127,0.005,1.0,-4))},
		25, {Ndef(\sound).set(\grainSpeed, args[0].lincurve(0,127,1,64,-4))},
		11, {Ndef(\sound).set(\index, args[0].lincurve(0,127,0,1000,-4))}
	)
},([24,25,11]));
MIDIdef.cc(\feedbackControl, {arg ...args;
	switch(args[1],
		9, {Ndef(\sound).set(\delLen, args[0])}, // Expected values - 1 to 8
		10, {Ndef(\sound).set(\tempo, args[0].lincurve(0,127,0.5,5,-4))},
		26, {Ndef(\sound).set(\dist, args[0].lincurve(0,127,0.0,2.0,-4))},
		27, {Ndef(\sound).set(\fdbk, args[0].linlin(0,127,0.0,2.5))}
)},([9,10,26,27]));
)
