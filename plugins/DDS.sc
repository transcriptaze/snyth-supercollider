DDS : UGen {
    *ar { arg freq = 440.0, 
              amp = 1.0, 
              e = 0.0,
              s = 10.0,
              r = 0.0,
              g = 1.0,
              l = 1.0;
        ^this.multiNew('audio', freq, amp, e, s, r, g, l)
    }
    
    *kr { arg freq = 440.0, 
              amp = 1.0, 
              e = 0.0,
              s = 10.0,
              r = 0.0,
              g = 1.0,
              l = 1.0;
        ^this.multiNew('control', freq, amp, e, s, r, g, l)
    }
}
