SynthDef(\mainFX, { | in out bypass = 0 |
    ReplaceOut.ar(out, VSTPlugin.ar( In.ar(in, 2 ), 2, bypass ));
}).add;
fork{
    q.mainFxGroup = q.mainFxGroup ?? Group.after(1); // after default group
    0.2.wait;
    q.mainComp = VSTPluginController( Synth( \mainFX, [ \in, 0, \out, 0 ], target: q.mainFxGroup , addAction: 'addToTail') );
    0.2.wait;
    // ~comp.open( "Auburn Sounds Couture.vst3" );
    q.mainComp.open( "RoughRider3.vst3" );

    1.wait;
    // s.sync;
    q.mainComp.readProgram("/home/skmecs/vst/roughRider.fxp");
    /*
    {q.mainComp.editor;}.defer(1);
    */
    "***** compressor on *****".post; ''.postln;
}