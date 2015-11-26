(
{
	var pulse = 0.25;
	var control = Duty.ar(1/pulse*4,0,Dseq([0,2,4,3,2,0],1),2);
	var del = DemandEnvGen.ar(Dbrown(0.05,0.25,0.005),Dseq([2,2,4,1,1,1,1],inf));
	var src1 = Blip.ar(pulse!2,control,0.25) ring4: Hasher.ar(LFSaw.ar(1,0,100).abs);
	var src2 = Blip.ar((pulse*2)!2,control+2,0.25) ring4: Hasher.ar(LFSaw.ar(2,0,100).abs);
	var src3 = Blip.ar((pulse+3.rand)!2,control+3,0.25) ring4: Hasher.ar(LFSaw.ar(3,0,100).abs);
	var src4 = Blip.ar((pulse*2.05)!2,control+4,0.25) ring4: Hasher.ar(LFSaw.ar(4,0,100).abs);
	var out = src1+src2+src3+src4*LFPulse.ar(pulse*2,0,0.5,0.75,0.25);
	out ring1: Splay.arFill(8,{Pulse.ar([rrand(300,500),rrand(300,500)])})
}.play
)
(
{
	var pulse = 0.25;
	var control = Duty.ar(1/pulse*4,0,Dseq([0,2,4,3,2,0],1),2);
	var del = DemandEnvGen.ar(Dbrown(0.05,0.25,0.005),Dseq([2,2,4,1,1,1,1],inf));
	var src1 = Blip.ar(pulse!2,control,0.25) ring4: Hasher.ar(LFSaw.ar(1,0,100).abs);
	var src2 = Blip.ar((pulse*2)!2,control+2,0.25) ring4: Hasher.ar(LFSaw.ar(2,0,100).abs);
	var src3 = Blip.ar((pulse+3.rand)!2,control+3,0.25) ring4: Hasher.ar(LFSaw.ar(3,0,100).abs);
	var src4 = Blip.ar((pulse*2.05)!2,control+4,0.25) ring4: Hasher.ar(LFSaw.ar(4,0,100).abs);
	var out = src1+src2+src3+src4*LFPulse.ar(pulse*2,0,0.5,0.75,0.25);
	var outC = CombC.ar(out*Decay.ar(Impulse.ar(pulse*2,2),0.25),0.5,del,16,0.5);
	out+outC ring1: Splay.arFill(8,{Pulse.ar([rrand(300,500),rrand(300,500)])})
}.play
)
(
{
	var pulse = 1;
	var control = Duty.ar(1/pulse*4,0,Dseq([0,2,4,3,2,0],1),2);
	var del = DemandEnvGen.ar(Dbrown(0.005,0.05,0.005),Dseq([2,2,4,1,1,1,1],inf));
	var src1 = Blip.ar(pulse!2,control,0.25) ring4: Hasher.ar(LFSaw.ar(1,0,100).abs);
	var src2 = Blip.ar((pulse*4.rand)!2,control+2,0.25) ring4: Hasher.ar(LFSaw.ar(2,0,100).abs);
	var src3 = Blip.ar((pulse*4.rand)!2,control+3,0.25) ring4: Hasher.ar(LFSaw.ar(3,0,100).abs);
	var src4 = Blip.ar((pulse*4.rand)!2,control+4,0.25) ring4: Hasher.ar(LFSaw.ar(4,0,100).abs);
	var out = src1+src2+src3+src4*LFPulse.ar(pulse*2,0,0.5,0.75,0.25);
	out ring3: Splay.arFill(8,{HenonC.ar([rrand(300,15000),rrand(300,15000)],rrand(1.0,1.4))})
}.play
)
(
{
	var pulse = LFNoise0.ar(4).range(0.5,20);
	var control = Duty.ar(1/pulse*4,0,Dseq([0,2,4,3,2,0],inf),2);
	var del = DemandEnvGen.ar(Dbrown(0.005,0.05,0.005),Dseq([2,2,4,1,1,1,1],inf));
	var src1 = Blip.ar(pulse!2,control,0.25) ring4: Hasher.ar(LFSaw.ar(1,0,100).abs);
	var src2 = Blip.ar((pulse*4.rand)!2,control+2,0.25) ring4: Hasher.ar(LFSaw.ar(2,0,100).abs);
	var src3 = Blip.ar((pulse*4.rand)!2,control+3,0.25) ring4: Hasher.ar(LFSaw.ar(3,0,100).abs);
	var src4 = Blip.ar((pulse*4.rand)!2,control+4,0.25) ring4: Hasher.ar(LFSaw.ar(4,0,100).abs);
	var out = src1+src2+src3+src4*LFPulse.ar(pulse*2,0,0.5,0.75,0.25);
	out ring3: Splay.arFill(16,{HenonC.ar([rrand(300,15000),rrand(300,15000)],rrand(1.0,1.4))})
}.play
)
(
{
	var pulse = LFNoise0.ar(16).range(50,250);
	var control = Duty.ar(1/pulse*4,0,Dseq([0,2,4,3,2,0],inf),2);
	var del = DemandEnvGen.ar(Dbrown(0.005,0.05,0.005),Dseq([2,2,4,1,1,1,1],inf));
	var src1 = Blip.ar(pulse!2,control,0.25) ring4: Hasher.ar(LFSaw.ar(1,0,100).abs);
	var src2 = Blip.ar((pulse*4.rand)!2,control+2,0.25) ring4: Hasher.ar(LFSaw.ar(2,0,100).abs);
	var src3 = Blip.ar((pulse*4.rand)!2,control+3,0.25) ring4: Hasher.ar(LFSaw.ar(3,0,100).abs);
	var src4 = Blip.ar((pulse*4.rand)!2,control+4,0.25) ring4: Hasher.ar(LFSaw.ar(4,0,100).abs);
	var out = src1+src2+src3+src4*LFPulse.ar(pulse*2,0,0.5,0.75,0.25);
	out ring3: Splay.arFill(16,{HenonC.ar([rrand(300,15000),rrand(300,15000)],rrand(1.0,1.4))})
}.play
)
