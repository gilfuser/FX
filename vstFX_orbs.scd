q.numOrbs = q.numOrbs ? 4;
(
fork{
    s.sync;
    wait(1);
    q.numOrbs.do{|i|
        Ndef(format("orb%",i).asSymbol)[200] = \vstFilter -> { |in| VSTPlugin.ar(in, 2) };
        Ndef(format("orb%",i).asSymbol)[210] = \vstFilter -> { |in| VSTPlugin.ar(in, 2) };
        wait(0.1);
        q[ (format("talVerb%",i).asSymbol) ] = VSTPluginNodeProxyController( Ndef(format("orb%",i).asSymbol), 200 ).open("TAL-Reverb-4.vst3", editor: true);
        q[ (format("roughRider%",i).asSymbol) ] = VSTPluginNodeProxyController( Ndef(format("orb%",i).asSymbol), 210 ).open("RoughRider3.vst3", editor: true);
        wait(0.2);
    };
    wait(0.3);

    z = Routine(
        {
            q.numOrbs.do{|i|
                wait(0.75);
                // q[ (format("roughRider%",i).asSymbol) ].editor;
                wait(0.75);
                // q[ (format("talVerb%",i).asSymbol) ].editor;
                wait(0.75);
                // q[ (format("talVerb%",i).asSymbol) ].readProgram( format("/home/skmecs/vst/orb%verb.fxp",i).asString );
                wait(0.75);
                // q[ (format("roughRider%",i).asSymbol) ].readProgram( format("/home/skmecs/vst/roughRider%.fxp", i).asString );
            }
        }
    );
    wait(0.2);
    AppClock.play(z);

};
// q.roughRider0.editor;

)
