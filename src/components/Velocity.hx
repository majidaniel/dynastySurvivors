package components;

//Component that keeps track of an entity's velocity for use in movement systems
class Velocity {
	public var x:Float;
	public var y:Float;

	public function new(_x, _y) {
		x = _x;
		y = _y;
	}
}
