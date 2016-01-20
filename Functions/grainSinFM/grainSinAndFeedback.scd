(
{
	//I've prepared a couple of arguments to qucikly change the sound, but don't hesitate to add more
	/*
	tempo= lfos and delay time, dist= max distortion, octRange= octave range, octOffset= first degree,
	filtSpeef = speed of LPF modulation by LFTri, delLen= how many 4th notes the delay lasts,
	grainDur= max duration of a grain, grainSpeed= max speed of Impulse multiplied by tempo
	*/
	arg tempo = 1.5, dist=0.05, octRange=4, octOffset=24, filtSpeed=0.5, delLen=16, grainDur=0.1, grainSpeed=512;
	var lfo1, winenv, env, scale, note, degreeNum, src, loc;
	lfo1 = {arg rt,lw,hg,rd; LFNoise0.ar(rt).range(lw,hg).round(rd)};//Arguments - Rate, Lowest Value, Highest Value, Round
	/*
	Pitch Control
	*/
	scale = Scale.melodicMinor; //Sets the scale
	degreeNum = scale.size-1; //Gets the number of degrees for the scale, I subtract 1 because the lfo works from 0.
	note = DegreeToKey.ar(scale.as(LocalBuf),
		lfo1.(tempo*2,0,degreeNum*octRange,lfo1.(tempo/2,1,7,1)),//lfo1.(rate=2,lowNum=0,highNum=degreeNum*4(4 octaves),round=another lfo
		scale.stepsPerOctave,1,octOffset).midicps;
	/*
	Source
	*/
	winenv = Env([0,0.5,0.25,1,0],[0.5,0.25,0.5],[8,-8]);
	env = Buffer.sendCollection(s,winenv.discretize,1);
	src = GrainSin.ar(2,
		Impulse.ar(lfo1.(tempo/4,tempo*(grainSpeed/8),tempo*grainSpeed,tempo)),
		lfo1.(tempo*3,grainDur/16,grainDur,grainDur/16),note,lfo1.(tempo*4,-1,1,0.1),
		env, 1024, 0.5);
	/*
	Feedback
	*/
	loc = LocalIn.ar(2)+src;
	loc = DelayL.ar(loc,1/tempo*delLen,1/tempo*delLen); //delLen 4th Notes at a given tempo (90BPM in this case)
	loc = loc + //Loc + Filtered/FrequencyShifted/Distorted Loc Parameters are modulated with lfo1 function (LFNoise0)
	LPF.ar(
		FreqShift.ar(
			((loc*lfo1.(tempo*2,1,25,1)).softclip*LFSaw.ar(tempo/16,0,dist).abs)
			,lfo1.(tempo/4,-1,1,1)*note*4),
		3000);
	loc = LPF.ar(loc, LFTri.ar(tempo*filtSpeed,0,2500,2500).abs); //Simple Low Pass Filter, Freq controlled by Triangle Wave
	1.do{loc = AllpassC.ar(loc,0.5,LFNoise1.ar(0.0005!2,0.05,0.125).abs,1)}; //Higher/Lower 'do' value will result in more/less noisy sound
	loc = LeakDC.ar(loc);

	LocalOut.ar(loc*1.25);
	Limiter.ar(loc)*0.85
}.play
)
