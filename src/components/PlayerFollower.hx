package components;

class PlayerFollower {
	public var relativePosition:Vector;
	public var maxSpeed:Float;
	public var acceleration:Float;
	public var radialLevel:Int = 0;

	public function new(maxSpeed:Float, acceleration:Float, radialLevel = 0) {
		// this.relativePosition = relativePosition;
		this.maxSpeed = maxSpeed;
		this.acceleration = acceleration;
		this.radialLevel = radialLevel;
	}
}
