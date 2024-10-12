package components;

class DecayOnTime{
    public var timeRemaining:Float;
    public function new(timeUntilDecay:Float=0){
        this.timeRemaining = timeUntilDecay;
    }
}