public class PartyTrain
{
    16 => int NUM_BEATS;
    // Set the expected string
    "" => string EXPECTED_STRING;
    for (0 => int i; i < NUM_BEATS; i++){
        EXPECTED_STRING + "i," => EXPECTED_STRING;
    }
    if (EXPECTED_STRING.length() > 0){
        EXPECTED_STRING.substring(0, EXPECTED_STRING.length() - 1) => EXPECTED_STRING;
    }
    <<< EXPECTED_STRING >>>;
    .25::second => dur DEFAULT_SPEED;
    .25::second => dur beatLength;
    0 => int doPlayAll;
    0 => int doPlayHorn;
    20::ms => dur ENVELOPE_DELAY;
    
    // Volume probabilities
    .01 => float NOISE_VOLUME;
    .39 => float BEATS_VOLUME;
    .6 => float HORN_VOLUME;
    
    // Master noise
    Dyno d;
    d.limit();
    
    // Snare and white noise make up the train sound
    SndBuf snare => LPF snareLPF => Envelope snareEnvelope;
    snareLPF.freq(800);
    snareEnvelope.duration(ENVELOPE_DELAY);
    
    [1, 1, 1, 1, 1, 1, 1, 1] @=> int snareRhythm[];
    snare.read(me.dir() + "808_sounds/snare.aif");
    snare.gain(0.0);
    
    // White noise
    Noise noise => LPF noiseLPF;
    noiseLPF.freq(500);
    noise.gain(0);
    
    // Claves
    SndBuf claves => Envelope clavesEnvelope;
    clavesEnvelope.duration(ENVELOPE_DELAY);
    
    int clavesRhythm[NUM_BEATS];
    claves.read(me.dir() + "808_sounds/claves.aif");
    claves.gain(0.0);   
    
     // Conga
     SndBuf conga => Envelope congaEnvelope;
     congaEnvelope.duration(ENVELOPE_DELAY);

     int congaRhythm[NUM_BEATS];
     conga.read(me.dir() + "808_sounds/conga1.aif");
     conga.gain(0.0);

    // Cowbell
    SndBuf cowbell => Envelope cowbellEnvelope;
    cowbellEnvelope.duration(ENVELOPE_DELAY);
    
    int cowbellRhythm[NUM_BEATS];
    cowbell.read(me.dir() + "808_sounds/cowbell.aif");
    cowbell.gain(0.0);
    
    // handclap
    SndBuf handclap => Envelope handclapEnvelope;
    handclapEnvelope.duration(ENVELOPE_DELAY);
    
    int handclapRhythm[NUM_BEATS];
    handclap.read(me.dir() + "808_sounds/handclap.aif");
    handclap.gain(0.0);

    // Nathan M5 horn
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
    
    public void playClaves(float amp, float rate){
        claves.gain(amp);
        clavesEnvelope.keyOn();
        claves.pos(0);
        claves.rate(rate);
        250::ms => now;
        clavesEnvelope.keyOff();
    }
    public void playConga(float amp, float rate){
        conga.gain(amp);
        congaEnvelope.keyOn();
        conga.pos(0);
        conga.rate(rate);
        250::ms => now;
        congaEnvelope.keyOff();
    }

    public void playCowbell(float amp, float rate){
        cowbell.gain(amp);
        cowbellEnvelope.keyOn();
        cowbell.pos(0);
        cowbell.rate(rate);
        250::ms => now;
        cowbellEnvelope.keyOff();
    }

    public void playHandclap(float amp, float rate){
        handclap.gain(amp);
        handclapEnvelope.keyOn();
        handclap.pos(0);
        handclap.rate(rate);
        250::ms => now;
        handclapEnvelope.keyOff();
    }

    public void playSnare(float amp, float rate){
        snare.gain(amp);
        snareEnvelope.keyOn();
        snare.pos(0);
        snare.rate(rate);
        250::ms => now;
        snareEnvelope.keyOff();
    }
    
    // Set functions
    public void setClaves(int rhythm[]){
        rhythm @=> clavesRhythm;
    }

    public void setConga(int rhythm[]){
        rhythm @=> congaRhythm;
    }

    public void setCowbell(int rhythm[]){
        rhythm @=> cowbellRhythm;
    }

    public void setHandclap(int rhythm[]){
        rhythm @=> handclapRhythm;
    }

    // General functions
    public void connect (UGen ug)
    {
        clavesEnvelope => d => ug;
        congaEnvelope => d => ug;
        cowbellEnvelope => d => ug;
        handclapEnvelope => d => ug;
        snareEnvelope => d => ug;
        noiseLPF => d => ug;
        
        horn1 => d => ug;
        horn2 => d => ug;       
        horn3 => d => ug;
        horn4 => d => ug;
        horn5 => d => ug;
    }
    
    public void setSpeed(int multiplier){
        DEFAULT_SPEED * (100 - multiplier) / 80 => beatLength;
    } 
    
    public void start(){
        0 => int curBeat;
        
        1 => doPlayAll;
        noise.gain(NOISE_VOLUME);
        
        while (doPlayAll){

            <<< curBeat >>>;
            
            // Play the snare (snare is the "track" here)
            if (curBeat % 4 == 0){
                spork ~playSnare(.2 * BEATS_VOLUME, 1.0);
                } else {
                    spork ~playSnare(.2 * BEATS_VOLUME, .8);
                }

            // Play the claves
            if (clavesRhythm[curBeat]){
                spork ~playClaves(.1 * BEATS_VOLUME, 1);
            }   

            // Play the conga
            if (congaRhythm[curBeat]){
                spork ~playConga(.2 * BEATS_VOLUME, 1);
            } 

            // Play the cowbell
            if (cowbellRhythm[curBeat]){
                spork ~playCowbell(.1 * BEATS_VOLUME, .5);
            }

            // Play the handclap
            if (handclapRhythm[curBeat]){
                spork ~playHandclap(.05 * BEATS_VOLUME, 1);
            }

            // Hold time
            beatLength => now;
            
            // Increment or reset the beat
            if (curBeat == NUM_BEATS - 1){
                0 => curBeat;
                } else {
                    curBeat++;
                }
            }
        }

        public void stop()
        {
            <<< "Stopping the party train. :( " >>>;
            0 => doPlayAll;

            noise.gain(0);
        }

        public void toggleAll()
        {
            if (doPlayAll == 1){
                stop();
                } else {
                    spork~ start();
                }
            }

            public void toggleHorn()
            {
                if (doPlayHorn == 1){
                    horn1.gain(0);
                    horn2.gain(0);
                    horn3.gain(0);
                    horn4.gain(0);
                    horn5.gain(0);
                    
                    0 => doPlayHorn;
                    } else {
                       1 => doPlayHorn;

                       .2 => horn1.noteOn;
                       .2 * HORN_VOLUME => horn1.gain;

                       .2 => horn2.noteOn;
                       .2 * HORN_VOLUME  => horn2.gain;
                       .2 => horn3.noteOn;
                       .2 * HORN_VOLUME  => horn3.gain;
                       .2 => horn4.noteOn;
                       .2 * HORN_VOLUME  => horn4.gain;
                       .2 => horn5.noteOn;
                       .2 * HORN_VOLUME  => horn5.gain;
                   }
               }
           }


// Input: we want to take in a snare array and a speed, which are variable
// Play
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

fun void receivePlayStopButton(){
    while (true){
        playStopButtonEvent => now;

        while (playStopButtonEvent.nextMsg() != 0){
            partyTrain.toggleAll();
            <<< "Received playStopButton">>>;
        }
    }
}

// Dragging the slider changes the speed
OSCin.event("/speedSlider,i") @=> OscEvent speedSliderEvent;
spork~ receiveSpeedSlider();

fun void receiveSpeedSlider(){
    while (true){
        speedSliderEvent => now;
        while (speedSliderEvent.nextMsg() != 0){
            speedSliderEvent.getInt() => int speedValue;
            partyTrain.setSpeed(speedValue);
            <<< "Received speedSlider: ", speedValue >>>;
        }
    }
}

// Send claves list
OSCin.event("/clavesList," + partyTrain.EXPECTED_STRING) @=> OscEvent clavesListEvent;
spork~ receiveClavesListEvent();

fun void receiveClavesListEvent(){
    while (true){
        clavesListEvent => now;
        
        while (clavesListEvent.nextMsg() != 0){
            int clavesRhythm[partyTrain.NUM_BEATS];
            for (0 => int i; i < partyTrain.NUM_BEATS; i++){
                clavesListEvent.getInt() => clavesRhythm[i];
            }
            
            partyTrain.setClaves(clavesRhythm);
            <<< "Received claves." >>>;
        }
    }
}

// Send claves list
OSCin.event("/congaList," + partyTrain.EXPECTED_STRING) @=> OscEvent congaListEvent;
spork~ receiveCongaListEvent();

fun void receiveCongaListEvent(){
    while (true){
        congaListEvent => now;
        
        while (congaListEvent.nextMsg() != 0){
            int congaRhythm[partyTrain.NUM_BEATS];
            for (0 => int i; i < partyTrain.NUM_BEATS; i++){
                congaListEvent.getInt() => congaRhythm[i];
            }
            
            partyTrain.setConga(congaRhythm);
            <<< "Received conga." >>>;
        }
    }
}

// Send cowbell list
OSCin.event("/cowbellList," + partyTrain.EXPECTED_STRING) @=> OscEvent cowbellListEvent;
spork~ receiveCowbellListEvent();

fun void receiveCowbellListEvent(){
    while (true){
        cowbellListEvent => now;
        
        while (cowbellListEvent.nextMsg() != 0){
            int cowbellRhythm[partyTrain.NUM_BEATS];
            for (0 => int i; i < partyTrain.NUM_BEATS; i++){
                cowbellListEvent.getInt() => cowbellRhythm[i];
            }
            
            partyTrain.setCowbell(cowbellRhythm);
            <<< "Received cowbell." >>>;
        }
    }
}

// Send handclap list
OSCin.event("/handclapList," + partyTrain.EXPECTED_STRING) @=> OscEvent handclapListEvent;
spork~ receiveHandclapListEvent();

fun void receiveHandclapListEvent(){
    while (true){
        handclapListEvent => now;
        
        while (handclapListEvent.nextMsg() != 0){
            int handclapRhythm[partyTrain.NUM_BEATS];
            for (0 => int i; i < partyTrain.NUM_BEATS; i++){
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

fun void receiveHorn(){
    while (true){
        playHornEvent => now;
        
        while (playHornEvent.nextMsg() != 0){
            partyTrain.toggleHorn();
            <<< "Toggling horn." >>>;
        }
    }
}
// Keep time for the reception
while (true){
    1::second => now;
}
