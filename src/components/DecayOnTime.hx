package components;

class DecayOnTime{
    public var timeRemaining:Float;
    public var triggerDecomposeEffects:Bool;
    public function new(timeUntilDecay:Float=0,triggerDecomposeEffects:Bool=false){
        this.timeRemaining = timeUntilDecay;
        this.triggerDecomposeEffects=triggerDecomposeEffects;
    }
}