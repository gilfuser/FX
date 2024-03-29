// here you can see the effect order:
/*
~dirt.modules;

// OPTIONAL: you can reorder the effects, if you want e.g. the lpf to come after the delay:
~dirt.orderModules(['satur', 'hpf', 'klm']);
*/

/*
(
SynthDef("greyhole" ++ ~dirt.numChannels, { | out htime = 1 hdamp = 0.5 hsize = 0.7 hdiff = 0.125  hfb = 0.25  hole = 1 delta cps cycle sustain |
	var signal, holed, drywet;
	signal = In.ar(out, ~dirt.numChannels);
	holed = Greyhole.ar( signal, htime * cps, hdamp, hsize.lag(0.2), hdiff, hfb );
	// signal = signal * 0.2 + (saturated * 2); // this controls wet/dry
	drywet = XFade2.ar(signal, holed, hole * 2 - 1);
	ReplaceOut.ar(out, holed)
}).add;
);
*/
var numChannels = ~dirt.numChannels;

if (currentEnvironment.class == ProxySpace) {p.pop};
(
~dirt.addModule('saturator', { |dirtEvent|
	dirtEvent.sendSynth('saturator' ++ ~dirt.numChannels,
		// OPTIONAL
		// passing this array of parameters could be left out,
		// but it makes it clear what happens
	);
}, { ~sind.notNil or: { ~satur.notNil } }); // play synth only if at least one of the two was given
);
(
SynthDef( "saturator" ++ ~dirt.numChannels, { | out sind = 4 smul = 0.25 satur = 1 sustain |
	var signal, saturated, drywet;
	// (smul).poll(Impulse.kr(0.0), label: "smul");
	signal = In.ar(out, ~dirt.numChannels);
	saturated = AudioMSG.ar( signal, sind, mul:smul);
	drywet = XFade2.ar(signal, saturated, satur * 2 - 1);
	ReplaceOut.ar(out, drywet)
}).add;
);
/*
~dirt.orderModules(['skm-tape', 'hpf']);

(
~dirt.addModule('skm-tape', { |dirtEvent|
	dirtEvent.sendSynth('skm-tape' ++ ~dirt.numChannels,

		[
			tdur: ~tdur,
			tphase: ~tphase,
			tdepth: ~tdepth,
			toffset: ~toffset,
			tape: ~tape,
			cps: ~cps,
			cycle: ~cycle,
			sustain: ~sustain,
			out: ~out
		]

	)
}, { ~tdur.notNil or: { ~tphase.notNil } or: { ~tdepth.notNil } or: { ~toffset.notNil } or:  { ~tape.notNil }  });
);
(
SynthDef("skm-tape" ++ ~dirt.numChannels, { | out tdur = 2 tphase = 0 tdepth = 0.5 toffset = 0 tape = 1 cps = -1 cycle = -1 sustain |
	var signal, curve, taped, drywet;
	// (tdur).poll(Impulse.kr(0), label: "tdur");
	signal = In.ar(out, ~dirt.numChannels);
	curve = SinOsc.kr( (tdur * cps).reciprocal, ( /*tdur * */tphase * (2pi * (cycle % 1) ) + 1.5pi) % 2pi, tdepth, toffset );
	taped = DelayL.ar(signal, 2, curve, 1, signal);
	drywet = XFade2.ar(signal, taped, tape  * 2 - 1);
	ReplaceOut.ar(out, drywet)
}).add;
);
*/

/*(
~dirt.addModule('skm-lfo', { |dirtEvent|
	dirtEvent.sendSynth('skm-lfo' ++ ~dirt.numChannels,
		/*
		[
			sisap: ~sisap,
			ldur: ~ldur,
			iphase: ~~eqOrb2,
			lwidth: ~lwidth,
			midfreq: ~midfreq,
			hifreq: ~hifreq,
			llfo: ~llfo,
			cps: ~cps,
			cycle: ~cycle,
			sustain: ~sustain,
			out: ~out
		]
		*/
	)
}, { ( ~ldur.notNil ) or: { ~iphase.notNil } or: { ~lwidth.notNil } or: { ~llfo.notNil } or: { ~sisap.notNil } });
);
(
SynthDef("skm-lfo" ++ ~dirt.numChannels, { | out sisap=0 ldur=2 iphase=0 lwidth=0.25 midfreq=60 hifreq=2000 llfo = 1 cps = -1 cycle = -1 delta sustain |
	var signal, lfoed, drywet;
	var tempoChange = (ldur * cps).reciprocal.lag(0.2);
	var mod = Select.ar(sisap, [
			SinOsc.ar( tempoChange, ( /*ldur * */iphase * (cycle%1) * 2pi + 1.5pi) % 2pi),
			LFSaw.ar( tempoChange, iphase % 2, lwidth ), // change to LFTri
			LFPulse.ar(tempoChange, (ldur * iphase) % 1, lwidth.clip(0.02, 0.998) )*2-1,
		]);
	signal = In.ar(out, ~dirt.numChannels);
	lfoed = BLowPass.ar(signal, mod.lag2(0.05).exprange(midfreq.lag(0.1), hifreq.lag(0.1)));
	drywet = XFade2.ar(signal, lfoed, llfo * 2 - 1);
	ReplaceOut.ar(out, drywet)
}).add;
);*/

/*
(
~dirt.addModule('skm-filter', { |dirtEvent|
	dirtEvent.sendSynth('skm-filter' ++ ~dirt.numChannels,
		/*
		[
			lbhnp: ~lbhnp,
			sfreq: ~sfreq,
			fres: ~fres,
			ffilter: ~ffilter,
			cps: ~cps,
			cycle: ~cycle,
			sustain: ~sustain,
			out: ~out
		]
		*/
	)
}, { ( ~lbhnp.notNil ) or: { ~sfreq.notNil } or: { ~fres.notNil } or: { ~ffilter.notNil } });
);
(
SynthDef("skm-filter" ++ ~dirt.numChannels, { | out lbhnp = 0 sfreq = 10000 fres= 0.5 ffilter = 1  cps = -1 cycle = -1 sustain |
	var signal, filtered, drywet;
	var lpf = Select.kr( lbhnp,
		[DC.kr(1), DC.kr(0), DC.kr(0), DC.kr(0), DC.kr(0) ]
	);
	var bpf = Select.kr(lbhnp,
		[DC.kr(0), DC.kr(1), DC.kr(0), DC.kr(0), DC.kr(0) ]
	);
	var hpf = Select.kr(lbhnp,
		[DC.kr(0), DC.kr(0), DC.kr(1), DC.kr(0), DC.kr(0) ]
	);
	var notch = Select.kr(lbhnp,
		[DC.kr(0), DC.kr(0), DC.kr(0), DC.kr(1), DC.kr(0) ]
	);
	var peak = Select.kr(lbhnp,
		[DC.kr(0), DC.kr(0), DC.kr(0), DC.kr(0), DC.kr(1) ]
	);
	signal = In.ar(out, ~dirt.numChannels);
	filtered = SVF.ar( signal, sfreq.lag(0.2), fres.lag(0.4), lpf, bpf, hpf, notch, peak );
	drywet = XFade2.ar(signal, filtered, ffilter * 2 - 1);
	ReplaceOut.ar(out, drywet)
}).add;
);
*/



(
~dirt.addModule('skm-comp', { |dirtEvent|
	dirtEvent.sendSynth('skm-comp' ++ ~dirt.numChannels,
		/*
		[
			cctrl: ~cctrl,
			thr: ~thr,
			slopeb: ~slopeb,
			slopea: ~slopea,
			clamp: ~clamp,
			relax: ~relax,
			ccomp: ~ccomp,
			delta: ~delta,
			sustain: ~sustain,
			out: ~out
		]
		*/
	)
}, { ( ~cctrl.notNil ) or: { ~thr.notNil } or: { ~slopeb.notNil } or: { ~slopea.notNil } or: { ~clamp.notNil } or: { ~relax.notNil } or: { ~ccomp.notNil } });
);

(
SynthDef("skm-comp" ++ ~dirt.numChannels, { | out  cctrl = 0 thr = 0.25 slopea = 0.5 clamp = 0.002 relax = 0.1 ccomp = 1 delta = -1 sustain |
	var comped, drywet;
	var signal = In.ar(out, ~dirt.numChannels);
	var control = Select.ar( cctrl, [
			In.ar( ~dirt.orbits[0].outBus, 2), In.ar( ~dirt.orbits[1].outBus, 2),
			In.ar( ~dirt.orbits[2].outBus, 2), In.ar( ~dirt.orbits[3].outBus, 2) ] );
	var comp = Compander.ar( signal, control, thr.linexp(0, 1, 0.001, 1), 1, slopea, clamp, relax * delta );
	// (slopea).poll(Impulse.kr(0.0), label: "slopea");
	drywet = XFade2.ar(signal, comp, ccomp * 2 - 1);
	ReplaceOut.ar(out, Limiter.ar( drywet ))
}).add;
);
/*

now you should be able to write in tidal:

d1 $ sound "can*4" # tsdelay "0 0.25 0.5 0.75 1" # xsdelay "3 124 3 12 62 2"



*/


// these are the global effects on each orbit
~dirt.orbits.do { |x| x.globalEffects.postln };

// first you generate the synth defs for it
(
(1..SuperDirt.maxSampleNumChannels).do { |numChannels|
	SynthDef("dirt_global_modelay" ++ numChannels, { |dryBus, effectBus, gate = 1, modelay = 0, mdfb = 0.5, mdtime = 1, mdtimel = 1.5, mdtimer = 1, mdlock = 0, mdff = 800, mdfq = 3, mdamp = 1|
		var decaytime, decaytimeL, decaytimeR;
        var delayL, delayR, timeMod, eqMod;
        var maxDelayTime = 4;
		var signal = In.ar(dryBus, numChannels);
		mdamp = mdamp.clip(0, 4);
            mdfb = mdfb.clip(0, 0.99);
            mdtime = mdtime * if( mdlock, reciprocal(TempoClock.default.tempo), 1 );
            mdtime = mdtime.clip(0.014, maxDelayTime);
            decaytime = log2(-60.dbamp) / log2(mdfb) * mdtime;
            decaytime = decaytime.clip(0, 20);
            mdtimel = mdtimel * if(mdlock, reciprocal(TempoClock.default.tempo ), 1);
            mdtimel = mdtimel.clip(0.014, maxDelayTime); // just to be sure
            mdtimer = mdtimer * if(mdlock, reciprocal(TempoClock.default.tempo ), 1);
            mdtimer = mdtimer.clip(0.014, maxDelayTime);
            decaytimeL = log2(-60.dbamp) / log2(mdfb) * mdtimel;
            decaytimeL = decaytimeL.clip(0, 20);
            decaytimeR = log2(-60.dbamp) / log2(mdfb) * mdtimer;
            decaytimeR = decaytimeR.clip(0, 20);

            timeMod = { LFDNoise3.ar(5.5, 0.001) };
            eqMod = { LFDNoise3.kr(1, 0.25, 1) };

            signal = signal + (( [ LocalIn.ar(2)[0] * mdtimel.lincurve(0, 4, 0, 1, -16), LocalIn.ar(2)[1] * mdtimer.lincurve(0, 4, 0, 1, -16) ] )*modelay);

            delayL = CombC.ar( signal[0], maxDelayTime, mdtimel + timeMod, decaytimeL );
            delayL = BBandPass.ar( delayL, mdff.lag(0.1) * eqMod, mdfq.lag(0.1) );

            delayR = CombC.ar(signal[1], maxDelayTime, mdtimer + timeMod, decaytimeR );
            delayR = BBandPass.ar( delayR, mdff.lag(0.1) * eqMod, mdfq.lag(0.1) );

            signal = Limiter.ar( [ delayL, delayR] * mdamp.lag(0.01) );
        LocalOut.ar( AllpassN.ar(mdfb * signal, maxDelayTime, delaytime: mdtime /* + timeMod */ , decaytime: decaytime) );
        // signal;
		signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
		DirtPause.ar(signal.sum, graceTime:4);
		XOut.ar(effectBus, modelay, signal)
	}).add;
};
);

(
(1..SuperDirt.maxSampleNumChannels).do { |numChannels|
	SynthDef("dirt_global_wah" ++ numChannels, { |dryBus, effectBus, gate = 1, wrate = 1, wdepth = 0.5, sinsaw = 0, wphase = 0, jrate = 1, jdepth = 0, wah = 0|
		var  wring = 0.002, wrq = 0.8, ggain = 1.25;
        var jitter = LFNoise2.ar(jrate, jdepth);
        var mod = Select.kr(sinsaw, [
            SinOsc.ar( wrate, ( jitter * 2pi) % 2pi, wdepth).exprange(100, 5000),
            VarSaw.kr(wrate, jitter, 0.1, wdepth).lag(0.1).exprange(100, 5000),
        ]);
		var signal = In.ar(dryBus, numChannels);
        var ringz = Ringz.ar( signal, mod, wring );
        signal = RLPF.ar(ringz, mod, wrq.lag(0.1)) * ggain.tanh.lag(0.0003) / ggain.sqrt;
        signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
		DirtPause.ar(signal, graceTime:4);
		XOut.ar(effectBus, wah, signal)
	}).add;
};
);

(
~dirt.orbits.do { |x, i|
	fork{
        // i.postln;
	x.globalEffects = ~dirt.orbits[i].globalEffects.addFirst(
		GlobalDirtEffect(\dirt_global_wah, [\wah, \wrate, \wdepth, \sinsaw, \wphase, \jrate, \jdepth ])
	);
    wait(0.2);
        x.globalEffects = ~dirt.orbits[i].globalEffects.addFirst(
		GlobalDirtEffect(\dirt_global_modelay, [\modelay, \mdfb, \mdtime, \mdtimel, \mdtimer, \mdlock, \mdff, \mdfq, \mdamp])
	);
~dirt.orbits[i].initNodeTree;}
};
);

~dirt.orbits.do { |x| x.globalEffects.postln; " ----------".postln; };



">>> My Tidal FX loaded\n".postString
