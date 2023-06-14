s.boot;

// ... MIDI files
m = SimpleMIDIFile.read("./lfo.mid");

// ... SynthDefs
(
   SynthDef(\dds, {
      arg bus, freq=440, out=0, level=2, amp = 0.5, attack=0.1, sustain = 1, release = 0.25;
      var dds, sig, env;
      var e = In.kr(bus);
      var s = 2.0;
      var r = 30.0;
      var g = 1.0;
      var l = 1.0;

      env = EnvGen.kr(Env.new([0, 1, 1, 0], [attack, sustain, release]), doneAction: Done.freeSelf);
      dds = DDS.ar(freq, level*amp, e, s, r, g, l);
      sig = dds * amp * env;

      Out.ar(out, sig.dup);
   }).add;
)

// ... LFO
(
   SynthDef(\lfo, { arg bus = 0, freq=0.1, max=1.0, min = -1.0;
       var offset, range, sig;

       offset = min;
       range = max - min;
       sig = SinOsc.kr(freq, 0, range, offset);

       Out.kr(bus, sig);
   }).add;

   SynthDef(\lfo2, { arg bus = 0, freq=0.1, max=1.0, min = -1.0;
       var offset, range, sn;
       var e, s, r, g, l;

       e = 0.9;
       s = 2;
       r = 30;
       g = 1;
       l = 1;

       offset = min;
       range = max - min;
       sn = DDS.ar(freq, range, e, s, r, g, l);

       Out.kr(bus, offset + sn);
   }).add;
)

// ... play
b = Bus.control(s, 1);
y = Pbindf(m.p, \instrument, \dds, \bus, b);

b.set(0.0);
y.play;
b.set(0.8);

p = Synth.new(\lfo, [ \bus, b, \freq, 0.19, \min, 0.375, \max, 0.45 ]);
q = Synth.new(\lfo2,[ \bus, b, \freq, 0.23, \min, 0.375, \max, 0.45 ]);

p.free;
q.free;

m.p(\dds).play;

// ... cleanup
b.free;
