#include "SC_PlugIn.hpp"

static InterfaceTable *ft;

const float PI = pi;
const float TAU = 2 * pi;

struct DDS : public SCUnit {
  public:
    DDS() {
        fs = sampleRate();
        frequency = in0(0);
        amplitude = in0(1);

        e = in0(2);    // eccentricity
        s = in0(3);    // sensitivity
        r = in0(4);    // rotation (degrees)
        g = in0(5);    // internal gain
        lock = in0(6); // lock

        alpha = 0.0; // instantaneous angle

        e = fmin(1.0, fmax(-1.0, e));
        s = fmin(20.0, fmax(0.0, s));
        r = fmin(90.0, fmax(-90.0, r));
        lock = fmin(1.0, fmax(0.0, lock));
        amplitude = fmin(1.0, fmax(-1.0, amplitude));

        // printf("DDS: a %f\n", amplitude);
        // printf("DDS: e %f\n", e);
        // printf("DDS: s %f\n", s);
        // printf("DDS: r %f°\n", r);
        // printf("DDS: g %f\n", g);
        // printf("DDS: l %f\n", lock);
        // printf("DDS: eccentricity %f\n", tanh(s * e));
        // printf("DDS: inputs  %d\n", numInputs());
        // printf("DDS: outputs %d\n", numOutputs());

        // ... set DDS 'next' function
        if (isAudioRateIn(0)) {
            set_calc_function<DDS, &DDS::next>();
        } else {
            set_calc_function<DDS, &DDS::next>();
        }

        // ... initialise 'out' buffers for downstream blocks
        if (isAudioRateIn(0)) {
            next(1);
        } else {
            next(1);
        }
    }

  private:
    double fs;        // sampling frequency
    double frequency; // oscillator frequency
    double amplitude;

    double e;    // eccentricity
    double s;    // sensivity
    double r;    // rotation
    double g;    // internal gain
    double lock; // lock

    double alpha; // instantaneous angle

    void next(int N) {
        frequency = in0(0);
        amplitude = in0(1);

        e = in0(2);    // eccentricity
        s = in0(3);    // sensitivity
        r = in0(4);    // rotation (degrees)
        g = in0(5);    // internal gain
        lock = in0(6); // lock

        float delta = frequency * TAU / fs;
        float *buffer = out(0);

        double e = tanh(this->s * this->e);
        double a = e < 0.0 ? sqrt(1 - e * e) : 1;
        double b = e > 0.0 ? sqrt(1 - e * e) : 1;
        double theta = r * pi / 180.0;
        double phi = lock * atan((-a / b) * tan(theta));
        double gain = g;

        for (int n = 0; n < N; ++n) {
            double alpha = this->alpha + phi;
            double x = a * cos(alpha) * cos(theta) - b * sin(alpha) * sin(theta);
            double y = a * cos(alpha) * sin(theta) + b * sin(alpha) * cos(theta);
            double radius = sqrt(x * x + y * y);

            double sample = y / radius;

            buffer[n] = gain * amplitude * sample;

            this->alpha += delta;
            while (this->alpha > TAU) {
                this->alpha -= TAU;
            }
        }
    }
};

PluginLoad(SnythUGens) {
    ft = inTable;

    registerUnit<DDS>(ft, "DDS");
}
