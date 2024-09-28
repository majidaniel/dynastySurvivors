package components;

// Indicates that attached entity should respond to player input.  Contains parameters around speed & acceleration
class PlayerControlled {
	public var acceleration = Constants.PLAYER_ACCELERATION;
	public var deceleration = Constants.PLAYER_DECELERATION;
	public var initialImpulse = Constants.PLAYER_INITIAL_IMPULSE;
	public var maxSpeed = Constants.PLAYER_MAX_SPEED;

	public function new() {};
}
