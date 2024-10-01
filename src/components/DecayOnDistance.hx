package components;

class DecayOnDistance{
    public var lastPosition:Position;
    public var distanceRemaining:Float;
    public function new(distanceUntilDecy:Float,lastPosition:Position=null){
        this.distanceRemaining = distanceUntilDecy;
        this.lastPosition = lastPosition;
    }
}