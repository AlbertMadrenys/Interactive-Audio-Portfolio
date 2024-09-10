////////////////////////////////////////////////////////////////////
// Title: Electrobodhrán - Daisy source code
// Author: Albert Madrenys
// 
// MU617A — Interactive Systems
// Maynooth University
/////////////////////////////////////////////////////////////////////

#include "DaisyDuino.h"

DaisyHardware hw;
size_t num_channels;

Oscillator osc;
MoogLadder moog;
ReverbSc rev;
Port port;
Balance bal;

Switch button;
bool gate;
float vib;

float scale(int reading, float inMin, float inMax, float outMin, float outMax)
{
  float out = ((reading/(inMax - inMin)) * (outMax - outMin)) + outMin;
  return out;
}

void AudioCallback(float **in, float **out, size_t size)
{
  float vibSmooth, oscSig, moogSig, balSig, rev1Sig, rev2Sig;

  // smooth input
  button.Debounce();
  vibSmooth = port.Process(vib);

  for (size_t i = 0; i < size; i++)
  {
    // oscillator
    osc.SetAmp(vibSmooth * gate);
    oscSig = osc.Process();
    
    // moogladder filter
    moog.SetRes(vibSmooth);
    moogSig = moog.Process(oscSig);

    // balance signal
    balSig = bal.Process(moogSig, oscSig);

    // reverb
    rev.Process(balSig, balSig, &rev1Sig, &rev2Sig);

    // output
    out[0][i] = rev1Sig;
    out[1][i] = rev2Sig;
  }
}

void setup() {
  // initial general configuration
  Serial.begin(9600);
  float sample_rate;
  hw = DAISY.init(DAISY_SEED, AUDIO_SR_48K);
  num_channels = hw.num_channels;
  sample_rate = DAISY.get_samplerate();

  // initial input configuration
  button.Init(1000, true, 1, INPUT_PULLUP);

  // initial dsp configuration
  port.Init(sample_rate, 0.0005);

  osc.Init(sample_rate);
  osc.SetFreq(110);
  osc.SetAmp(0.5);
  osc.SetWaveform(osc.WAVE_SAW);

  moog.Init(sample_rate);
  moog.SetFreq(880);
  moog.SetRes(0.6);

  rev.Init(sample_rate);
  rev.SetFeedback(0.7);
  rev.SetLpFreq(4000);

  bal.Init(sample_rate);
  bal.SetCutoff(10);

  DAISY.begin(AudioCallback);
}

void loop()
{ 
  gate = button.Pressed();
  int potReading = analogRead(A0);
  vib = scale(potReading, 0, 1023, 0.0, 1.0);
}
