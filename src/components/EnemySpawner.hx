package components;

class EnemySpawner {
	public var type:EnemyType;
	public var frequency:Float;
	public var directions:Array<Float>;
	public var velocity:Float;
    public var nextSpawn:Float=0;

	public function new(type:EnemyType, frequency:Float, directions:Array<Float>, velocity:Float) {
		this.type = type;
		this.frequency = frequency;
		this.directions = directions;
		this.velocity = velocity;
	}
}
