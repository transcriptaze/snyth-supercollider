#include "SC_PlugIn.hpp"

static InterfaceTable *ft;

const float PI = pi;
const int N = 360 * 16;

struct SN : public SCUnit {
  public:
    SN() {
        fs = sampleRate();
        frequency = in0(0);
        level = in0(1);
        amplitude = in0(2);
        sustain = in0(3);
        phase = 0;

        for (int i = 0; i < N; i++) {
            wavetable[i] = sin(i * 2 * PI / N);
        }

        if (isAudioRateIn(0)) {
            set_calc_function<SN, &SN::next_a>();
        } else {
            set_calc_function<SN, &SN::next_k>();
        }

        if (isAudioRateIn(0)) {
            next_a(1);
        } else {
            next_k(1);
        }

        amplitude = fmin(1.0, fmax(-1.0, amplitude));
    }

  private:
    double fs;
    double frequency;
    double level;
    double amplitude;
    double sustain;
    double phase;
    float wavetable[N];

    void next_a(int inNumSamples) {
        float *buffer = out(0);
        const float *freq = in(0);
        double phi = phase;

        const double delta = N * frequency / fs;

        for (int n = 0; n < inNumSamples; ++n) {
            const int ix = (int)floor(phi) % N;
            const int jx = (int)ceil(phi) % N;
            double i = 0;
            const double f = modf(phi, &i); // supercollider crashes if &intpart is NULL

            const double floorv = wavetable[ix];
            const double ceilv = wavetable[jx];
            const double v = ((1 - f) * floorv) + (f * ceilv);

            buffer[n] = amplitude * v;

            phi += delta;
            while (phi > N) {
                phi -= N;
            }
        }

        phase = phi;
    }

    void next_k(int inNumSamples) {
        float *buffer = out(0);
        double phi = phase;

        const double delta = N * frequency / fs;

        for (int n = 0; n < inNumSamples; ++n) {
            const int ix = (int)floor(phi) % N;
            const int jx = (int)ceil(phi) % N;
            double i = 0;
            double f = modf(phi, &i); // supercollider crashes if &intpart is NULL

            const double floorv = wavetable[ix];
            const double ceilv = wavetable[jx];
            const double v = ((1 - f) * floorv) + (f * ceilv);

            buffer[n] = amplitude * v;

            phi += delta;
            while (phi > N) {
                phi -= N;
            }
        }

        phase = phi;
    }
};

PluginLoad(SnythUGens) {
    ft = inTable;

    registerUnit<SN>(ft, "SN");
}
