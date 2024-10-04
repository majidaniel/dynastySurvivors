package components;

class PlayerFollower {
	public var relativePosition:Vector;
	public var maxSpeed:Float;
	public var acceleration:Float;
	public var radialLevel:Int = 0;
	public var type:MinionType;

	public function new(type:MinionType, maxSpeed:Float, acceleration:Float, radialLevel = 0) {
		// this.relativePosition = relativePosition;
		this.maxSpeed = maxSpeed;
		this.acceleration = acceleration;
		this.radialLevel = radialLevel;
		this.type = type;
	}
}
