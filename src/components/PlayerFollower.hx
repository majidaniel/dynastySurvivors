package components;

class PlayerFollower{
    public var relativePosition:Vector;
    public var maxSpeed:Float;
	public var acceleration:Float;

    public function new(relativePosition:Vector,maxSpeed:Float, acceleration:Float){
        this.relativePosition = relativePosition;
        this.maxSpeed = maxSpeed;
		this.acceleration = acceleration;
    }
}