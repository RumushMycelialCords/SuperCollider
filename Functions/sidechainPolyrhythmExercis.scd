(
{
	var rt = Array.series(8,1,1);
	var freq = Array.geom(8,60,2);
	var amp = Array.geom(8,1,0.5).normalizeSum;
	Mix.fill(8,{arg i;
		var src = SinOsc.ar(freq[i],0,0.9)+WhiteNoise.ar(0.01)*amp[i];
		Compander.ar(src,Impulse.ar([rt[8.rand],rt[8.rand]],0,100),0.01,1,0.01,
			LFSaw.ar(1/rt[8.rand]).range(0.00001,0.001),
			LFSaw.ar(1/rt[8.rand]).range(0.01,1))
	})
}.play
)
(
{
	var num = 8;
	var rt = Array.series(num,1,1)*
	Duty.ar(Drand([Dseq([4],4),Dseq([2],4)],inf),0,Dseq([Dseq([2,4],2),Drand([2,3,4],2)],inf));

	var freq = Array.geom(num,60,2)*
	Duty.ar(Drand([Dseq([4],4),Dseq([2],4)],inf),0,Dseq([Dseq([1,1.25],2),Drand([1,1.25,1.5],2)],inf));

	var amp = Array.geom(num,1,0.5).normalizeSum*XLine.ar(1,8,64,1,0,2);
	var del = Array.fill(num/2,{-1})++Array.fill(num/2,{rrand(-0.5,1)});

	Mix.fill(num,{arg i;
		var src = XFade2.ar(
			XFade2.ar(
				MoogFF.ar(Saw.ar(freq[i],0.9),freq[i]*rrand(2,16),0),
				SinOsc.ar(freq[i],0,0.9),
				LFNoise1.ar(2.0.rand)),
			XFade2.ar(
				MoogFF.ar(HenonC.ar(freq[i],rrand(1.0,1.5),rrand(0.2,0.5),mul:0.9),freq[i]*rrand(8,16),2),
				SinOscFB.ar(freq[i],LFSaw.ar(rt[8.rand]).abs*XLine.ar(0.001,2,64,1,0,2),0.9),
				LFNoise1.ar(2.0.rand)),
			LFNoise1.ar(0.01.rand))
		+WhiteNoise.ar(0.01)*amp[i];
		src = Compander.ar(src,Impulse.ar([rt[8.rand],rt[8.rand]],0,LFNoise0.ar(1/rt[8.rand]).range(10,100)),0.01,1,0.01,
			LFSaw.ar(1/rt[8.rand]).range(0.00001,0.001),
			LFSaw.ar(1/rt[8.rand]).range(0.005,0.1));
		src = XFade2.ar(src,CombC.ar(src,1,0.25+LFNoise1.ar(0.01,0.05),rrand(1,4)),del[i])
	}).tanh

}.play
)
