////////////////////////////////////////////////////////////////////
// Title: Connect 4ton - Csound code
// Author: Albert Madrenys
// 
// MU617A — Interactive Systems
// Maynooth University
/////////////////////////////////////////////////////////////////////

<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr=44100
ksmps=32
nchnls=1
0dbfs=1

// Channels (used for debugging)
/*
chn_k "chn1",1
chn_k "chn2",1
chn_k "chn3",1
chn_k "chn4",1
chn_k "chn5",1
*/

instr 1
 
 // Input variables
 kmidiIn[] fillarray 0, 0, 0, 0, 0 								// Curent MIDI value for each input
 kmidiInPrev[] fillarray 0, 0, 0, 0, 0							// Previous MIDI value for each input
 kTrig[] fillarray 0, 0, 0, 0, 0									// Boolean table to know if a trigger has been triggered for the first time
 kEventFreq[] fillarray 220, 440, 660, 440, 330			// Frequency of the scheduled instrument 2 for each input trigger
 
 // Channel reading (used for debugging)
 /*
 kmidiIn[0] chnget "chn1"
 kmidiIn[1] chnget "chn2"
 kmidiIn[2] chnget "chn3"
 kmidiIn[3] chnget "chn4"
 kmidiIn[4] chnget "chn5"
 */
 
 // MIDI initialization
 initc7 1, 1, 0
 initc7 1, 2, 0
 initc7 1, 3, 0
 initc7 1, 4, 0
 initc7 1, 5, 0
 
 // MIDI reading
 kmidiIn[0] ctrl7 1, 1, 0, 127
 kmidiIn[1] ctrl7 1, 2, 0, 127
 kmidiIn[2] ctrl7 1, 3, 0, 127
 kmidiIn[3] ctrl7 1, 4, 0, 127
 kmidiIn[4] ctrl7 1, 5, 0, 127
 
 //printk2 kmidiIn[0]
 
 // DSP variables
 kflang init 0																// Initial and current flanger delay state
 iflangFinal init 0.01												// Final flanger half delay state
 ktempoIndex init 0														// Current tempo state
 ktempoArray[] fillarray 1, 1.2, 1.5						// Values for each tempo state
 kpitchIndex init 0														// Current pitch state
 kpitchArray[] fillarray 0.75, 1, 1.5						// Values for each pitch state
 
 // Trigger detection
 ki = 0
 while ki < 5 do
 	// Trigger detected if difference of current and previous MIDI value is large enough, 
 	// not triggered before and its not the first k-rate call
 	if kmidiIn[ki] - kmidiInPrev[ki] > 25 && kTrig[ki] == 0 && kmidiInPrev[ki] != 0 then
 		kTrig[ki] = 1
 		schedulek(2, 0, 5, kEventFreq[ki])
 		
 		// Change the state of the pitch, tempo or flanger delay depending on the input number
 		if ki == 0 || ki == 3 then
 			ktempoIndex = ktempoIndex+1
 		elseif ki == 1 || ki == 4 then
 			kpitchIndex = kpitchIndex+1
 		elseif ki == 2 then
 			kflang = iflangFinal
 		endif
 		
 	endif
 	
 	kmidiInPrev[ki] = kmidiIn[ki]
 	ki = ki+1
 od
 
 
 // Audio processing
 asig diskin "tetris.mp3", ktempoArray[ktempoIndex], 0, 1
 
 isiz = 2048 // frame size
 fsig pvsanal asig ,isiz,isiz/8,isiz,1 // pva, 1/8 overlap
 fpitch pvscale fsig, kpitchArray[kpitchIndex]/ktempoArray[ktempoIndex] // taking the tempo into consideration when scaling pitch
 asynth pvsynth fpitch
 
 abal balance asynth, asig
 
 adel = (oscili(kflang, 1))+kflang // oscillating from 0 to kflang*2
 afl flanger abal, adel, 0.1
 
 outs  afl * 0.3 * linsegr(0, 0.25, 0, 0.1, 1 ,0.2, 0)
endin


// Scheduling instrument 1 for the entire execution
schedule(1, 0, -1)

// Instrument 2 that will be scheduled when a trigger is detected
giMar ftgen 0, 0, 256, 1, "marmstk1.wav", 0, 0, 0		// Table of strike impulses for the marimba physical model
instr 2
 	asig marimba 0.9, p4, 0.9, 0.561, giMar, 6, 0.05, -1, 0.6
 	arev nreverb asig, 1, .1
 	outs arev*1.8
endin

</CsInstruments>
<CsScore>

</CsScore>

</CsoundSynthesizer>








<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>578</width>
 <height>228</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject type="BSBKnob" version="2">
  <objectName>chn1</objectName>
  <x>18</x>
  <y>23</y>
  <width>80</width>
  <height>80</height>
  <uuid>{a8d81680-799e-408b-8859-abe90c5511bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>chn2</objectName>
  <x>107</x>
  <y>24</y>
  <width>80</width>
  <height>80</height>
  <uuid>{e6d5af9f-c5bc-4d04-9113-9548a3b35f16}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>chn4</objectName>
  <x>281</x>
  <y>24</y>
  <width>80</width>
  <height>80</height>
  <uuid>{59ea4c0d-4f55-46d4-a854-3040477db1ab}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>chn3</objectName>
  <x>194</x>
  <y>24</y>
  <width>80</width>
  <height>80</height>
  <uuid>{ec9c3184-ea36-4289-8b2e-b0ef7baa91e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject type="BSBKnob" version="2">
  <objectName>chn5</objectName>
  <x>371</x>
  <y>24</y>
  <width>80</width>
  <height>80</height>
  <uuid>{7ab3e5ee-408e-44d4-8dc9-ea997bb46ca0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
