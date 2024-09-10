////////////////////////////////////////////////////////////////////
// Title: SuperOSCollider - SuperCollider code
// Author: Albert Madrenys
//
// MU617A — Interactive Systems
// Maynooth University
/////////////////////////////////////////////////////////////////////

s.boot();

(

// Audio processing

SynthDef(\shortBeep, {
    arg out = 0, freq = 440, amp = 0.2, dur = 0.1, pan = 0.0;
	var env, sig;
    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    sig = SinOsc.ar(freq) * env * amp;
	sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
}).add;

~sBAmp = PatternProxy(0.2);
~sBFreq = PatternProxy(300);
~sBFreqFactor = PatternProxy(1.5);

~sBPattern = Pbind(
    \instrument, \shortBeep,
	\freq, Pwhite(~sBFreq, ~sBFreq*~sBFreqFactor, inf),
    \amp, ~sBAmp,
    \dur, Pwhite(0.075, 0.125, inf),
	\pan, Pwhite(-1.0, 1.0, inf)
).play;

SynthDef(\FMSynth,
	{
	arg out = 0, amp = 0.2, carFreq = 110, modFreq = 110, modIndex = 0.5;
	var sig, mod, pan;

	mod = SinOsc.ar(modFreq, pi, modFreq*modIndex); // cosine modulator
	sig = SinOsc.ar(carFreq + mod,0,amp);


	pan = SinOsc.kr(0.5, 0,0.75);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);

	}

).add;

~fMSynth = Synth.new(\FMSynth);

// OSC Messages Handling

thisProcess.openUDPPort(57121);
~receiverX360.free; //free the old reciever if it already exists
~receiverX360 = NetAddr.new("127.0.0.1", 57121);
~responderX360.free; //if there is an old responder ... then free it first
~responderX360 = OSCFunc(
	{
		arg msg;
		var specs = Array.newClear(5);

		//msg.postln;
		specs[0] =  ControlSpec(300, 500,\exp);
		specs[1] =  ControlSpec(1, 2,\lin);
		specs[2] =  ControlSpec(300, 500,\exp);
		specs[3] =  ControlSpec(0.5, 3,\lin);

		~sBFreq.source = specs[0].map(msg[1]);
		~sBFreqFactor.source = specs[1].map(msg[2]);

		~fMSynth.set(\modFreq, specs[2].map(msg[3]));
		~fMSynth.set(\modIndex, specs[3].map(msg[4]));
	},
'/x360Controller/outputs');

// No need to open UPD port 57120, since it's a language port
~receiverWek.free;
~receiverWek = NetAddr.new("127.0.0.1", 57120);
~responderWek.free;
~responderWek = OSCFunc(
	{
		arg msg;
		var amp;

		msg.postln;
		amp = ControlSpec(0, 1,\lin).map(msg[1]);

		// When the amplitude of one element increases, the other decreases
		~sBAmp.source = amp;
		~fMSynth.set(\amp, 1-amp);
	},
'/wek/outputs');

)