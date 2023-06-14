SN : UGen {
    *ar { arg freq = 440.0, level = 1.0, amp = 0.5, sustain = 1.0;
        ^this.multiNew('audio', freq, level, amp, sustain)
    }
    
    *kr { arg freq = 440.0, level = 1.0, amp = 0.5, sustain = 1.0;
        ^this.multiNew('control', freq, level, amp, sustain)
    }
}
