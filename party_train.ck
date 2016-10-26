public class PartyTrain
{
    8 => int NUM_BEATS;
    .25::second => dur DEFAULT_SPEED;
    .25::second => dur beatLength;
    0 => int doPlay;
    

    // Master noise
    Dyno d;
    d.limit();
    
    // Snare and white noise make up the train sound
    // Initialize snare
    SndBuf snare => LPF snareLPF;
    snareLPF.freq(1000);
    
    [1, 1, 1, 1, 1, 1, 1, 1] @=> int snareRhythm[];
    snare.read(me.dir() + "808_sounds/snare.aif");
    snare.gain(0.0);
    
    // White noise
    Noise noise => LPF noiseLPF;
    noiseLPF.freq(500);
    noise.gain(0);
    
    // Drum machine: 
    // Cowbell
    SndBuf cowbell;
    int cowbellRhythm[];
    cowbell.read(me.dir() + "808_sounds/cowbell.aif");
    cowbell.gain(0.0);
    
    // Play functions
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

    // Set funcions
    public void setCowbell(int rhythm[]){
        rhythm @=> cowbellRhythm;
    }

    // General functions
    public void connect (UGen ug)
    {
        cowbell => d => ug;
        snareLPF => d => ug;
        noiseLPF => d => ug;
    }
    
    public void setSpeed(int multiplier){
        DEFAULT_SPEED * (100 - multiplier) / 80 => beatLength;
    } 
    
    public void start(){
        0 => int curBeat;
        
        1 => doPlay;
        noise.gain(.2);
        
        while (doPlay){
            
            <<< curBeat >>>;
            
            // Play the snare (snare is the "track" here)
            if (curBeat % 4 == 0){
                spork ~playSnare(.5, 1.0);
            } else {
                spork ~playSnare(.25, 1.0);
            }
            
            // Play the cowbell
            if (cowbellRhythm[curBeat]){
                spork ~playCowbell(.25, .5);
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
        0 => doPlay;
        
        noise.gain(0);
    }
    
    public void toggle()
    {
        if (doPlay == 1){
            stop();
        } else {
            spork~ start();
        }
    }
}


// Input: we want to take in a snare array and a speed, which are variable
// Play
PartyTrain partyTrain;
partyTrain.connect(dac);

[1, 0, 1, 0, 1, 0, 1, 0] @=> int cowbellRhythm[];
partyTrain.setCowbell(cowbellRhythm);

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
                partyTrain.toggle();
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
// Keep time for the reception
while (true){
    1::second => now;
}
