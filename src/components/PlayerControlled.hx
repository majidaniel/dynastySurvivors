package components;

//Indicates that attached entity should respond to player input.  Contains parameters around speed & acceleration
class PlayerControlled {
	public var acceleration = 1000;
	public var deceleration = 1000;
	public var initialImpulse = 0.8;
	public var maxSpeed = 200;

	public function new() {};
}
