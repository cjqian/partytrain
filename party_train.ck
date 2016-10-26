public class PartyTrain
{
    8 => int NUM_BEATS;
    .25::second => dur DEFAULT_SPEED;
    .25::second => dur beatLength;
    0 => int doPlayAll;
    0 => int doPlayHorn;
    
    // Volume probabilities
    .1 => float NOISE_VOLUME;
    .3 => float BEATS_VOLUME;
    .6 => float HORN_VOLUME;
    
    // Master noise
    Dyno d;
    d.limit();
    
    // Snare and white noise make up the train sound
    SndBuf snare => LPF snareLPF;
    snareLPF.freq(1000);
    
    [1, 1, 1, 1, 1, 1, 1, 1] @=> int snareRhythm[];
    snare.read(me.dir() + "808_sounds/snare.aif");
    snare.gain(0.0);
    
    // White noise
    Noise noise => LPF noiseLPF;
    noiseLPF.freq(500);
    noise.gain(0);
    
    // Cowbell
    SndBuf cowbell;
    [0, 0, 0, 0, 0, 0, 0, 0] @=> int cowbellRhythm[];
    cowbell.read(me.dir() + "808_sounds/cowbell.aif");
    cowbell.gain(0.0);
    
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
    
    public void playCowbell(float amp, float rate){
        cowbell.gain(amp);
        cowbell.pos(0);
        cowbell.rate(rate);
    }
    
    public void playSnare(float amp, float rate){
        snare.gain(amp);
        snare.pos(0);
        snare.rate(rate);
    }

    // Set functions
    public void setCowbell(int rhythm[]){
        rhythm @=> cowbellRhythm;
    }

    // General functions
    public void connect (UGen ug)
    {
        cowbell => d => ug;
        snareLPF => d => ug;
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
                spork ~playSnare(.4 * BEATS_VOLUME, 1.0);
            } else {
                spork ~playSnare(.2 * BEATS_VOLUME, 1.0);
            }
            
            // Play the cowbell
            if (cowbellRhythm[curBeat]){
                spork ~playCowbell(.2 * BEATS_VOLUME, .5);
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

// Send cowbell list
OSCin.event("/cowbellList,i,i,i,i,i,i,i,i") @=> OscEvent cowbellListEvent;
spork~ receiveCowbellListEvent();

fun void receiveCowbellListEvent(){
    <<<"Cowbell event received!">>>;
    while (true){
        cowbellListEvent => now;
        while (cowbellListEvent.nextMsg() != 0){
            [cowbellListEvent.getInt(), 
            cowbellListEvent.getInt(),
            cowbellListEvent.getInt(),
            cowbellListEvent.getInt(),
            cowbellListEvent.getInt(),
            cowbellListEvent.getInt(),
            cowbellListEvent.getInt(),
            cowbellListEvent.getInt()] @=> int cowbellRhythm[];
            
            partyTrain.setCowbell(cowbellRhythm);
            <<< "Received cowbell." >>>;
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
