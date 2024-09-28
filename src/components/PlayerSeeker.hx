package components;

import Types.PlayerSeekingType;

class PlayerSeeker {
	public var seekingType:PlayerSeekingType;
	public var maxSpeed:Float;
	public var acceleration:Float;

	public function new(seekingType:PlayerSeekingType, maxSpeed:Float, acceleration:Float) {
		this.seekingType = seekingType;
		this.maxSpeed = maxSpeed;
		this.acceleration = acceleration;
	}
}
