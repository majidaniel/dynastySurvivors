package components;

// Component that keeps track of an entity's velocity for use in movement systems
class Velocity {
	public var vector:Vector;

	public function new(_x, _y) {
		vector = new Vector(_x, _y);
	}
}
