package components;

class DecayOnDistance{
    public var lastPosition:Position;
    public var distanceRemaining:Float;
    public var triggerDecomposeEffects:Bool;
    public function new(distanceUntilDecy:Float,lastPosition:Position=null,triggerDecomposeEffects:Bool=false){
        this.distanceRemaining = distanceUntilDecy;
        this.lastPosition = lastPosition;
        this.triggerDecomposeEffects=triggerDecomposeEffects;
    }
}