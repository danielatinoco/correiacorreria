// this program block installs an OSC def that listens to OSC messages and triggers playing a buffer based on the arguments
(
s.waitForBoot({
    // variable to remember the most recently requested index
    ~next_index = nil;
    // flag to decide if new synth can start
    ~prevent_next = false;
	~fase = 1;
	~velo = 1;

    //free all previous buffers
    b.do{|x|
        x.free
    };

    // load some buffers"C:/Users/Atinoco/Documents/Arduino/data/pavuna.wav"
    b= [ //edit paths - any number of files - make sure mono
        Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/pavuna.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/pavuna.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/pavuna.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/pavuna.wav"),
	];

	c= [ //edit paths - any number of files - make sure mono
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/decisaoA1.wav"),
        Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/decisaoA1.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/decisaoA2.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/decisaoA2.wav"),
	];

	d= [ //edit paths - any number of files - make sure mono
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/caxias.wav"),
        Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/mare2.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/caxias.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/mare2.wav"),
	];

	e= [ //edit paths - any number of files - make sure mono
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/decisaoB.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/decisaoB.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/decisaoB.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/decisaoB.wav"),
	];

	f= [ //edit paths - any number of files - make sure mono
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/madureira.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/tijuca.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/madureira.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/tijuca.wav"),
	];

	g= [ //edit paths - any number of files - make sure mono
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/caxias.wav"),
        Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/ramos2.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/caxias.wav"),
		Buffer.read(s,"C:/Users/Atinoco/Documents/Arduino/data/ramos2.wav"),
	];

    SynthDef(\sample, {
        arg amp=5, out=0, buf, rate=1, da=2, pitch=1, t_trig= 1, start=0;
		var sig;
		sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, t_trig, start, doneAction:2)!2;
		sig = sig * amp;
		sig = PitchShift.ar(
			sig,	// stereo audio input
			0.1, 			// grain size
			pitch,	// mouse x controls pitch shift ratio
			0, 				// pitch dispersion
			0.004			// time dispersion
	);
        Out.ar(out, sig);
    }).add;

    s.sync;
	~synth = nil;

    // install an osc handler reacting to the playindex message; when an osc msg comes in, register the argumetn in ~next_index
	// n = NetAddr("127.0.0.1", 57120); // listen to messages on the local machine
    OSCdef(\playindex, {
        |msg, time, addr, recvPort|
		var fase = ~fase;
		~velo = msg[2];
        ~next_index = msg[1].asInteger;
        ~next_index.debug("Next index requested to play");
		~synth.set (\rate, msg[2], \pitch, msg [3]);

		if (fase == 4){
			~synth.set (\rate, 1, \pitch, 1);
		};

		if (fase == 2){
			~synth.set (\rate, 1, \pitch, 1);
		};
    }, '/playindex'); // def style


    // in a thread, check if a new index is ready to be played
    fork {
        while ({true}) {
            if (~next_index.notNil && ~prevent_next.not) {
				// var synth;
				//criar variavel pra fase
				var fase = ~fase;
                var index = ~next_index;
				var velo = ~velo;
                ~prevent_next = true;
                ~next_index = nil;
                index.debug("Start playing index");

				if (fase == 1) {
					"fase 1".postln;
					~synth = Synth (\sample, [\buf, b[index]]);

				};

				if (fase == 2) {
					"fase 2".postln;
					~synth = Synth (\sample, [\buf, c[index]]);
				};

				if (fase == 3) {
					"fase 3".postln;
					velo.postln;

					if (velo > 1.3){
						"fase 2a".postln;
						~synth = Synth (\sample, [\buf, d[index]])
					}{
							"fase 2b".postln;
							~synth = Synth (\sample, [\buf, g[index]]);
					};

					/*if (velo == 0.75){
						"fase 2a".postln;
						~synth = Synth (\sample, [\buf, d[index]])
					};

					if (velo == 1){
							"fase 2a".postln;
							~synth = Synth (\sample, [\buf, d[index]])
					};

					if (velo == 1.3){
							"fase 2a".postln;
							~synth = Synth (\sample, [\buf, d[index]])
					};

					if (velo == 1.5){
							"fase 2b".postln;
							~synth = Synth (\sample, [\buf, g[index]]);
					};

					if (velo == 1.7){
							"fase 2b".postln;
							~synth = Synth (\sample, [\buf, g[index]]);
					};

					if (velo == 2){
							"fase 2b".postln;
							~synth = Synth (\sample, [\buf, g[index]]);
					};*/
				};

				if (fase == 4) {
					"fase 4".postln;
					~synth = Synth (\sample, [\buf, e[index]]);
				};

				if (fase == 5) {
					"fase 5".postln;
					~synth = Synth (\sample, [\buf, f[index]]);
				};

                ~synth.onFree({

					if(fase%2 == 1){
					~velo = ~velo;
					};

					~fase = ~fase +1;
                    ~prevent_next = false;
                    "Ready for new index to be played.".postln;
                });
            };
            0.25.wait; // check every 0.25 seconds for a new buffer
        };
    };
});
)

// with the previous program running, we can send some messages to it to see if it works
// instead of sending things from inside supercollider, these could come from outside supercollider
/*(
m = NetAddr("127.0.0.1", 57120); // loopback
fork{
    m.sendMsg("/playindex", 1);
    1.wait;
    m.sendMsg("/playindex", 4); // check that this one is overwritten by the next one
    0.01.wait;
    m.sendMsg("/playindex", 2);
    5.wait;
    m.sendMsg("/playindex", 3);
};
)*/