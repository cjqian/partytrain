public class PartyTrain
{
    8 => int NUM_BEATS;
    0 => int doPlay;
    .125::second => dur beatLength;

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
    
    public void setBeatLength(dur length){
        length => beatLength;
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
}

// Input: we want to take in a snare array and a speed, which are variable
// Play
PartyTrain partyTrain;
partyTrain.connect(dac);

[1, 0, 1, 0, 1, 0, 1, 0] @=> int cowbellRhythm[];
partyTrain.setCowbell(cowbellRhythm);


spork~ partyTrain.start();
3::second=>now;
partyTrain.setCowbell([1, 0, 0, 0, 1, 0, 0, 0]);
2::second=>now;

partyTrain.stop();
2::second => now;

spork~ partyTrain.start();
2::second=>now;



