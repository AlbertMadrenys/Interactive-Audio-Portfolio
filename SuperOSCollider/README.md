# SuperOSCollider
SuperOSCollider is a demonstration of the capabilities of SuperCollider, OSC messages, and the use
of AI processing to modify musical elements. This demo is not intended to be artistic but will focus
more on the technology and structural principles of designing a complex system. This system will
includes different processes communicating with each other using OSC messages. As a result, the
audio design will be kept simple to make it easier to detect and understand what is happening behind
the scenes.

* SuperCollider
* OSC
* Wekinator AI
* Xbox 360 controller
* Face detection

## Credits

Some elements of the project are not uploaded in this repository because it is not original work:

### Face Detection
Contributors: Daniel Shiffman, Greg Borenstein, Jordi Tost, Rebecca Fiebrink
Source code: http://www.wekinator.org/examples/#VideoWebcam

### Xbox 360 controller
Contributors: Scott H. Hawley, Rebecca Fiebrink, Peter Lager 
Source code: https://gist.github.com/drscotthawley/dd74db91dd2f8ec3c810a87d4d26b576

Minor modification made by the author to the `sendOsc()` method. The sent values have been normalized from 0 to 1.
```
void sendOsc() {
  OscMessage msg = new OscMessage("/x360Controller/outputs");
  
  // Modified by Albert Madrenys to map the OSC message
  // values correctly for SuperOSCollider
  msg.add(map(pupilPosX, -34.2, 34.2, 0.0, 1.0)); 
  msg.add(map(pupilPosY, -34.2, 34.2, 0.0, 1.0));
  msg.add(map(lidPos, 0.6283186, 2.8902655, 0.0, 1.0));
  msg.add(map(pupilSize, 37.8, 50.4, 0.0, 1.0));
  oscP5.send(msg, dest);
}
```

## Documentation

Comprenhensive and extensive documentation can be found [here](../docs/Interactive_Systems_Portfolio-Albert_Madrenys_Planas.pdf)

## Media

Video demostrations of the the project:

