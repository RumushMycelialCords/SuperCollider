(// Careful ring1 and ring2 are much louder
{
	var note = Duty.ar(4,0,Dseq([60,62,58,56,55,63].midicps,inf)); // Melody
	var step = Stepper.ar(Impulse.ar(4),0,-1,8,1); // Octaves
	var step2 = PulseCount.ar(step,Impulse.ar(1/32)); // FB Amount
	var step3 = Stepper.ar(Impulse.ar(1),0,note,note*3,note*1.5); // Frequency
	var mod1 = SinOsc.ar(note/2,0,XLine.ar(0.1,2500,120,1,0,2)); // FM Mod
	var mod2 = Splay.arFill(4, {BPF.ar(GrayNoise.ar(0.5),note,0.25.rand)*LFTri.ar([0.1.rand,0.1.rand]).abs}); // Noise1
	var mod3 = Splay.arFill(4, {PinkNoise.ar(0.5)*LFTri.ar(1/rrand(10,20)).abs})*LFTri.ar([0.05,0.07]).abs; // Noise2
	// Output 4 ringmod types - uncomment to hear 
	//CombC.ar(SinOscFB.ar(step3*step+mod1,step2.fold(0,2),0.15!2),0.5,[0.05,0.051],2.5,0.5) ring1:mod3+mod2 // Louder
	//CombC.ar(SinOscFB.ar(step3*step+mod1,step2.fold(0,2),0.15!2),0.5,[0.05,0.051],2.5,0.5) ring2:mod3+mod2 // Louder
	CombC.ar(SinOscFB.ar(step3*step+mod1,step2.fold(0,2),0.15!2),0.5,[0.05,0.051],2.5,0.5) ring3:mod3+mod2
	//CombC.ar(SinOscFB.ar(step3*step+mod1,step2.fold(0,2),0.15!2),0.5,[0.05,0.051],2.5,0.5) ring4:mod3+mod2
}.play
)
