class PitchDetect
{
    get pitchDetectMode()
    {
        return this._pitchDetectMode;
    }

    set pitchDetectMode(value)
    {
        this._pitchDetectMode = value;
    }
    //--------------------------------------------------------------------------
    get sampleRate()
    {
        return this._sampleRate;
    }
    set sampleRate(value)
    {
        this._sampleRate = value;
    }
    constructor(sampleRate, waveform)
    {
        this._sampleRate = sampleRate;
        this._corrolatedSignal = new Array(waveform.length).fill(0)

        this._autocorolateMaximaLimit = 10;
        this._localMaxima =  new Array(this._autocorolateMaximaLimit).fill(0);
        this._avgFreqWindow = new MovingAverageFilter(20);
        this._pitchDetectMode = false;
        this._currentFrequency = 0;
        this._detectionRmsThresh = 0.00;

    }
    //--------------------------------------------------------------------------
    getPitch(waveform)
    {

        console.log(waveform);
        if (this.getRms(waveform) > this._detectionRmsThresh)
        {
            let freq = (this._pitchDetectMode) ? this.getZeroCrossings(waveform): this.getAutocorellation(waveform);
            this._currentFrequency = this.getAverageFrequency(freq);
        }
        let midi_note = this.hz2midi(this._currentFrequency);
        let note = this.hz2note(this._currentFrequency);
        let cents = midi_note - Math.floor(midi_note + 0.5);

        return {
            frequency: this._currentFrequency,
            note: note,
            cents: cents
        };
    }
    //--------------------------------------------------------------------------
    getZeroCrossings(waveform)
    {
       
        let zeroCrossCounter = 0;
        for (let i = 1; i < waveform.length; i++)
        {
            if (waveform[i] < 0 && waveform[i - 1] > 0
                || waveform[i] > 0 && waveform[i - 1] < 0)
            {
                zeroCrossCounter++;
            }
        }

        return zeroCrossCounter;
    }

    getRms(waveform)
    {
        let mean = 0;
        for (let i = 0; i < waveform.length; i++)
        {
            mean += waveform[i] * waveform[i];
        }
        return Math.sqrt(mean / waveform.length);
    }

    getAutocorellation(waveform)
    {
        let maximaCount = 0;
        let maximaMean = 0;

        for (let l = 0; l < waveform.length; l++)
        {
            this._corrolatedSignal[l] = 0;
            for (let i = 0; i < waveform.length-l; i++)
            {
                this._corrolatedSignal[l] +=  waveform[i] * waveform[i + l];
            }
            if (l > 1)
            {
                if ((this._corrolatedSignal[l-2] - this._corrolatedSignal[l-1]) < 0
                    && (this._corrolatedSignal[l-1] - this._corrolatedSignal[l]) > 0)
                {
                    this._localMaxima[maximaCount] = (l-1);
                    maximaCount++;
                    if (!(maximaCount < this._autocorolateMaximaLimit))
                        break;
                }
            }
        }

        maximaMean += this._localMaxima[0];
        for (let i = 1; i < maximaCount; i++)
        {
            maximaMean += this._localMaxima[i] - this._localMaxima[i - 1];
        }
        return (this._sampleRate * maximaCount) / maximaMean ;
    }

    getAverageFrequency(frequency)
    {
        return this._avgFreqWindow.getNewAverage(frequency);
    }
    //--------------------------------------------------------------------------

    hz2midi(hz)
    {
        return 12.0 * Math.log2(hz / 440.0) + 69;
    }

    static midi2hz(midi)
    {
        return Math.pow(2, (midi - 69.0)/12.0) * 440.0;
    }

    static midi2note(midi)
    {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
        // Offset so that 50 cents is the switching point
        let  wholeNote = Math.floor(midi + 0.5);
        let index = (wholeNote) % 12;

        return notes[index];
    }

    static note2hz(note)
    {
        let pitch = (note.length === 2) ? note.substring(0, 1) : note.substring(0, 2);
        let octave = parseInt(note.substring(note.length - 1));
        let notes = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"];
        let noteHz = [ 13.75, 14.568, 15.434, 16.3516, 17.3239, 18.3540, 19.4454, 20.6017,
            21.8268, 23.1247, 24.4997, 25.956];
        let hz = 0;
        for (let i = 0; i < notes.length; i++)
        {
            if (pitch === (notes[i]))
            {
                hz = noteHz[i] * Math.pow(2, octave + 1);
                break;
            }
        }
        return hz;
    }

    hz2note(hz)
    {
        return PitchDetect.midi2note(this.hz2midi(hz));
    }
    //--------------------------------------------------------------------------
}


// // debug
// var p = new PitchDetect()
// console.log(PitchDetect.note2hz('C2'));
// console.log(p._localMaxima);