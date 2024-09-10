////////////////////////////////////////////////////////////////////
// Title: Connect 4ton - Arduino source code
// Author: Albert Madrenys
// 
// MU617A — Interactive Systems
// Maynooth University
/////////////////////////////////////////////////////////////////////

#include "MIDIUSB.h"    // include the MIDIUSB library

int MIDIVal[5] = {0, 0, 0, 0, 0};        // MIDI value
int prevMIDIVal[5] = {0, 0, 0, 0, 0};    // previous MIDI value
int MIDIChan = 0;       // MIDI channel. N.B. MIDI channel 1 is a value of zero

void setup() {
  Serial.begin(115200); // note baud rate
}

// a function that creates a controller change 
void controlChange(byte channel, byte control, byte value) {
  midiEventPacket_t event = {0x0B, 0xB0 | channel, control, value};
  MidiUSB.sendMIDI(event);
  //Serial.println("MIDI message sent");
}

void loop()
{
  for(int i = 0; i < 5; i++)
  {
    MIDIVal[i] = analogRead(i) >> 3;      // read analogue pin, shift from 10 bit to 7 bit

    if (MIDIVal[i] != prevMIDIVal[i]) {          // if controller has changed from previous pass...
      controlChange(MIDIChan, i+1, MIDIVal[i]);  // send a controller message. 
      MidiUSB.flush();
    }

    prevMIDIVal[i] = MIDIVal[i];
  }

  //Serial.println(MIDIVal[0]);
}
