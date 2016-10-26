/* The 808 Party Train
 * Author: Crystal Qian
 * 10/26/2016
 *
 * This instrument is a drum machine and horn modelled after a party that might take place on a train.
 * There is ambient white noise with a filter to indicate background noise, the consistent movement of the train on the rails, and
 * additional sounds made by the interface. The speed of the train can also be changed.
 *
 * Usage: open up the party_train Max MSP file. The interface has a brief overview on unlocked presentation mode. Make sure that
 * this shred is added before interacting with the Max MSP visualization, because the visualization is not responsible for sound!
 */

public class PartyTrain
{
	// Volume distribution
	.01 => float NOISE_VOLUME;
	.39 => float BEATS_VOLUME;
	.6 => float HORN_VOLUME;

	// GLOBAL VARIABLES
	100::ms => dur ENVELOPE_DELAY;
	16 => int NUM_BEATS;
	150::ms => dur DEFAULT_BEAT_LENGTH;

	// Set the expected beat array input type string (ex: "i, i, i, i");
	"" => string EXPECTED_STRING;
	for (0 => int i; i < NUM_BEATS; i++)
	{
		EXPECTED_STRING + "i," => EXPECTED_STRING;
	}
	if (EXPECTED_STRING.length() > 0)
	{
		EXPECTED_STRING.substring(0, EXPECTED_STRING.length() - 1) => EXPECTED_STRING;
	}

	// Tracks if the drum machine (all) or horn is playing at any moment
	0 => int doPlayAll;
	0 => int doPlayHorn;

	150::ms => dur beatLength;

	// Master noise control
	Dyno d;
	d.limit();

	// A muted snare and white noise make up the constant train sound
	SndBuf snare => LPF snareLPF => Envelope snareEnvelope;
	snareLPF.freq(800);
	snareEnvelope.duration(ENVELOPE_DELAY);
	snare.read(me.dir() + "808_sounds/snare.aif");
	snare.gain(0.0);

	Noise noise => LPF noiseLPF;
	noiseLPF.freq(500);
	noise.gain(0);

	// Claves, high tom, cowbell, and handclap are the 808 sounds used in the drum machine
	// Claves
	SndBuf claves => Envelope clavesEnvelope;
	claves.read(me.dir() + "808_sounds/claves.aif");
	claves.gain(0.0);   
	clavesEnvelope.duration(ENVELOPE_DELAY);
	int clavesRhythm[NUM_BEATS];

	// HighTom
	SndBuf highTom => Envelope highTomEnvelope;
	highTom.read(me.dir() + "808_sounds/hightom.aif");
	highTom.gain(0.0);
	highTomEnvelope.duration(ENVELOPE_DELAY);
	int highTomRhythm[NUM_BEATS];

	// Cowbell
	SndBuf cowbell => Envelope cowbellEnvelope;
	cowbell.read(me.dir() + "808_sounds/cowbell.aif");
	cowbell.gain(0.0);
	cowbellEnvelope.duration(ENVELOPE_DELAY);
	int cowbellRhythm[NUM_BEATS];

	// Handclap
	SndBuf handclap => Envelope handclapEnvelope;
	handclapEnvelope.duration(ENVELOPE_DELAY);
	handclap.read(me.dir() + "808_sounds/handclap.aif");
	handclap.gain(0.0);   
	int handclapRhythm[NUM_BEATS];

	// Modelled after a Nathan M5 train horn, tuned to A major dominant 7th
	// We want it to sound like a steam train (hence blowhole)
	BlowHole horn1;
	horn1.freq(Std.mtof(49));
	horn1.gain(0);
	BlowHole horn2;
	horn2.freq(Std.mtof(52));
	horn2.gain(0);  
	BlowHole horn3;
	horn3.freq(Std.mtof(55));
	horn3.gain(0);
	BlowHole horn4;
	horn4.freq(Std.mtof(57));
	horn4.gain(0);
	BlowHole horn5;
	horn5.freq(Std.mtof(61));
	horn5.gain(0); 

	// The following methods play each instrument
	public void playClaves(float amp, float rate)
	{
		claves.gain(amp);
		clavesEnvelope.keyOn();
		claves.pos(0);
		claves.rate(rate);
		250::ms => now;
		clavesEnvelope.keyOff();
	}

	public void playHighTom(float amp, float rate)
	{
		highTom.gain(amp);
		highTomEnvelope.keyOn();
		highTom.pos(0);
		highTom.rate(rate);
		500::ms => now;
		highTomEnvelope.keyOff();
	}

	public void playCowbell(float amp, float rate)
	{
		cowbell.gain(amp);
		cowbellEnvelope.keyOn();
		cowbell.pos(0);
		cowbell.rate(rate);
		250::ms => now;
		cowbellEnvelope.keyOff();
	}

	public void playHandclap(float amp, float rate)
	{
		handclap.gain(amp);
		handclapEnvelope.keyOn();
		handclap.pos(0);
		handclap.rate(rate);
		250::ms => now;
		handclapEnvelope.keyOff();
	}

	public void playSnare(float amp, float rate)
	{
		snare.gain(amp);
		snareEnvelope.keyOn();
		snare.pos(0);
		snare.rate(rate);
		250::ms => now;
		snareEnvelope.keyOff();
	}

	// The following methods set the new rhythms
	public void setClaves(int rhythm[])
	{
		rhythm @=> clavesRhythm;
	}

	public void setHighTom(int rhythm[])
	{
		rhythm @=> highTomRhythm;
	}

	public void setCowbell(int rhythm[])
	{
		rhythm @=> cowbellRhythm;
	}

	public void setHandclap(int rhythm[])
	{
		rhythm @=> handclapRhythm;
	}

	// This connects all the noise-making devices
	public void connect (UGen ug)
	{
		// Drum machine
		clavesEnvelope => d => ug;
		highTomEnvelope => d => ug;
		cowbellEnvelope => d => ug;
		handclapEnvelope => d => ug;

		// Moving train
		snareEnvelope => d => ug;
		noiseLPF => d => ug;

		// Whistle
		horn1 => d => ug;
		horn2 => d => ug;       
		horn3 => d => ug;
		horn4 => d => ug;
		horn5 => d => ug;
	}

	// Changes the speed of the train.
	// KNOWN BUG: this affects volume on my machine. 
	public void setSpeed(int multiplier)
	{
		((100.0 - multiplier) / 50.0 / 1.33) + .5 => float percentage; // Range between .5 and 2 multiplier
		DEFAULT_BEAT_LENGTH * percentage => beatLength;
	} 

	// Starts the train and plays the indicated beats in a loop until we stop
	public void start()
	{
		0 => int curBeat;
		1 => doPlayAll;
		noise.gain(NOISE_VOLUME);

		while (doPlayAll){    
			// Play the snare (snare is the "track" here), with
			// slightly more emphasis at the start of each measure
			if (curBeat % 4 == 0){
				spork ~playSnare(.2 * BEATS_VOLUME, 1.0);
			} else {
				spork ~playSnare(.2 * BEATS_VOLUME, .8);
			}

			// Play the claves
			if (clavesRhythm[curBeat])
			{
				spork ~playClaves(.1 * BEATS_VOLUME, 1);
			}   

			// Play the highTom
			if (highTomRhythm[curBeat])
			{
				spork ~playHighTom(.1 * BEATS_VOLUME, 1.5);
			} 

			// Play the cowbell
			if (cowbellRhythm[curBeat])
			{
				spork ~playCowbell(.1 * BEATS_VOLUME, .5);
			}

			// Play the handclap
			if (handclapRhythm[curBeat])
			{
				spork ~playHandclap(.05 * BEATS_VOLUME, 1);
			}

			// Hold time
			beatLength => now;

			// Increment or reset the beat
			if (curBeat == NUM_BEATS - 1)
			{
				0 => curBeat;
			} 
			else {
				curBeat++;
			}
		}
	}

	public void toggleAll()
	{
		// Stops the machine, if it's already going
		if (doPlayAll == 1)
		{
			0 => doPlayAll;
			noise.gain(0);
		} 

		// Starts the machine
		else {
			spork ~start();
		}
	}

	public void toggleHorn()
	{
		// Silence the horns, if they were playing
		if (doPlayHorn == 1)
		{
			horn1.gain(0);
			horn2.gain(0);
			horn3.gain(0);
			horn4.gain(0);
			horn5.gain(0);

			0 => doPlayHorn;
		} 

		// Else, start playing
		else {
			1 => doPlayHorn;

			.1 => horn1.noteOn;
			.2 * HORN_VOLUME => horn1.gain;

			.1 => horn2.noteOn;
			.2 * HORN_VOLUME  => horn2.gain;

			.1 => horn3.noteOn;
			.2 * HORN_VOLUME  => horn3.gain;

			.1 => horn4.noteOn;
			.2 * HORN_VOLUME  => horn4.gain;

			.1 => horn5.noteOn;
			.2 * HORN_VOLUME  => horn5.gain;
		}
	}
}


// Initialize and connect the party train
PartyTrain partyTrain;
partyTrain.connect(dac);

// Initialize our receiver
OscRecv OSCin;
OscMsg msg;
1235 => OSCin.port;
OSCin.listen();

// Pressing the button starts/stops the train
OSCin.event("/playStopButton,i") @=> OscEvent playStopButtonEvent;
spork~ receivePlayStopButton();

// We need a counter because we changed the button to a pictctrl for 
// interface's sake. So, clicking is two actions: mouse up, mouse down.
// We only count one of these actions.
0 => int playStopButtonCounter;
fun void receivePlayStopButton()
{
	while (true)
	{
		playStopButtonEvent => now;

		while (playStopButtonEvent.nextMsg() != 0)
		{
			playStopButtonCounter++;

			if (playStopButtonCounter % 2 == 0){
				partyTrain.toggleAll();
			}

			<<< "Received playStopButton">>>;
		}
	}
}

// Dragging the slider changes the speed
OSCin.event("/speedSlider,i") @=> OscEvent speedSliderEvent;
spork~ receiveSpeedSlider();
fun void receiveSpeedSlider()
{
	while (true)
	{
		speedSliderEvent => now;
		while (speedSliderEvent.nextMsg() != 0)
		{
			speedSliderEvent.getInt() => int speedValue;
			partyTrain.setSpeed(speedValue);
			<<< "Received speedSlider: ", speedValue >>>;
		}
	}
}

// The following methods receive arrays for the drum machine

// Receive claves list
OSCin.event("/clavesList," + partyTrain.EXPECTED_STRING) @=> OscEvent clavesListEvent;
spork~ receiveClavesListEvent();
fun void receiveClavesListEvent()
{
	while (true)
	{
		clavesListEvent => now;

		while (clavesListEvent.nextMsg() != 0)
		{
			int clavesRhythm[partyTrain.NUM_BEATS];
			for (0 => int i; i < partyTrain.NUM_BEATS; i++)
			{
				clavesListEvent.getInt() => clavesRhythm[i];
			}

			partyTrain.setClaves(clavesRhythm);
			<<< "Received claves." >>>;
		}
	}
}

// Receive highTom list
OSCin.event("/highTomList," + partyTrain.EXPECTED_STRING) @=> OscEvent highTomListEvent;
spork~ receiveHighTomListEvent();

fun void receiveHighTomListEvent()
{
	while (true)
	{
		highTomListEvent => now;

		while (highTomListEvent.nextMsg() != 0)
		{
			int highTomRhythm[partyTrain.NUM_BEATS];
			for (0 => int i; i < partyTrain.NUM_BEATS; i++)
			{
				highTomListEvent.getInt() => highTomRhythm[i];
			}

			partyTrain.setHighTom(highTomRhythm);
			<<< "Received highTom." >>>;
		}
	}
}

// Receive cowbell list
OSCin.event("/cowbellList," + partyTrain.EXPECTED_STRING) @=> OscEvent cowbellListEvent;
spork~ receiveCowbellListEvent();
fun void receiveCowbellListEvent()
{
	while (true)
	{
		cowbellListEvent => now;

		while (cowbellListEvent.nextMsg() != 0)
		{
			int cowbellRhythm[partyTrain.NUM_BEATS];
			for (0 => int i; i < partyTrain.NUM_BEATS; i++)
			{
				cowbellListEvent.getInt() => cowbellRhythm[i];
			}

			partyTrain.setCowbell(cowbellRhythm);
			<<< "Received cowbell." >>>;
		}
	}
}

// Receive handclap list
OSCin.event("/handclapList," + partyTrain.EXPECTED_STRING) @=> OscEvent handclapListEvent;
spork~ receiveHandclapListEvent();
fun void receiveHandclapListEvent()
{
	while (true)
	{
		handclapListEvent => now;

		while (handclapListEvent.nextMsg() != 0)
		{
			int handclapRhythm[partyTrain.NUM_BEATS];
			for (0 => int i; i < partyTrain.NUM_BEATS; i++)
			{
				handclapListEvent.getInt() => handclapRhythm[i];
			}

			partyTrain.setHandclap(handclapRhythm);
			<<< "Received handclap." >>>;
		}
	}
}

// Pressing the horn button plays the horn
OSCin.event("/playHorn,i") @=> OscEvent playHornEvent;
spork~ receiveHorn();
fun void receiveHorn()
{
	while (true)
	{
		playHornEvent => now;

		while (playHornEvent.nextMsg() != 0)
		{
			partyTrain.toggleHorn();
			<<< "Toggling horn." >>>;
		}
	}
}

// Keep time while the program is going
while (true){
	1::second => now;
}
