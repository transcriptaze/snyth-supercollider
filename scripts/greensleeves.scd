s.boot;

// ... curves
Env.new([0, 1, 1, 0], [0.1, 1.0, 0.25]).plot

{ DDS.ar(440, 1.0, 1.0,  0.5, 2, 30, 1) }.plot;
{ DDS.ar(440, 1.0, 1.0, -0.8, 1, 45, 0) }.plot;

// ... MIDI files
m = SimpleMIDIFile.read("./midi/greensleeves.mid" );

// ... SynthDefs
(
   SynthDef( "organ", { |freq = 440, sustain = 1, amp = 0.1|
      var sig;
        sig = LFPar.ar( freq * [1,2,3,5], 0, amp/[2,4,5,7] );
        Out.ar( 0, Env([0,1,1,0], [0.025,sustain,0.025]).kr(2) * sig.dup )
   }).add;
);

(
   SynthDef(\sn, {
      arg freq=440, out=0, level=10, amp = 0.4, attack=0.1, sustain = 1, release = 0.25;
      var sig,env;

      env = EnvGen.kr(Env.new([0, 1, 1, 0], [attack, sustain, release]), doneAction: Done.freeSelf);
      sig = SN.ar(freq, level, level* amp, sustain);
      sig = sig * amp * env;

      Out.ar(out, sig.dup);
   }).add;
)

(
   SynthDef(\dds, {
      arg freq=440, out=0, level=2, amp = 0.5, attack=0.1, sustain = 1, release = 0.25,
          e = 0.8,
          s = 2,
          r = 30,
          g = 1.0,
          l = 1.0;
      var lfo,dds, sig,env;

      env = EnvGen.kr(Env.new([0, 1, 1, 0], [attack, sustain, release]), doneAction: Done.freeSelf);
      lfo = DDS.kr(2,1,0.9,2,30);
      dds = DDS.ar(freq, level*amp, e + (0.1*lfo), s, r, g, l);
      sig = (0.25*lfo + 0.5) * dds * amp * env;

      Out.ar(out, sig.dup);
   }).add;
)

(
   SynthDef(\ddx, {
      arg freq=440, out=0, level=2, amp = 0.75, attack=0.1, sustain = 0.9, release = 0.25,
          e = 0.7,
          s = 2.5,
          r = 30,
          g = 1.0,
          l = 1.0;
      var sig,sig1,sig2,sig3,lfo,env;

      env = EnvGen.kr(Env.new([0, 1, 1, 0], [attack, sustain, release]), doneAction: Done.freeSelf);
      lfo = DDS.kr(0.5,1,0.9,2,30);
      sig1 = DDS.ar(freq, level*amp, e + (0.25*lfo), s, r + (20*lfo), g, l);
      sig2 = DDS.ar(2*freq, 0.2*level*amp, 0.4 - (0.25*lfo), 3, 60, g, l);
      sig3 = 0.25*lfo + 0.5;
      sig = (sig3*(sig1 + sig2)) * amp * env;

      Out.ar(out, sig.dup);
   }).add;
)

(
   SynthDef(\ddq, {
      arg bus, freq=440, out=0, level=2, amp = 0.5, attack=0.1, sustain = 1, release = 0.25,
          s = 2,
          r = 30,
          g = 1.0,
          l = 1.0;
      var dds, sig, env;
      var e;

      e = In.kr(bus);

      env = EnvGen.kr(Env.new([0, 1, 1, 0], [attack, sustain, release]), doneAction: Done.freeSelf);
      dds = DDS.ar(freq, level*amp, e, s, r, g, l);
      sig = dds * amp * env;

      Out.ar(out, sig.dup);
   }).add;
)

// ... play
m.p(\sn).play;
m.p(\dds).play;
m.p(\dds).poll.play;
m.p(\dds).trace.play;
m.p(\ddx).play;

// ... bus
m.p(\ddq, 0.2).play;

b = Bus.control(s, 1);
x = m.p;
y = Pbindf(m.p, \instrument, \ddq, \bus, b);

b.set(0);
y.play;
b.set(0.8);
b.free;

