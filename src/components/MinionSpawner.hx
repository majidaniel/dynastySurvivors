package components;

class MinionSpawner {
	public var type:MinionType;
	public var cost:Int;

	public var frequency:Float;
	public var nextSpawn:Float=0;


	public function new(type:MinionType, cost:Int = 0, frequency:Float=60,nextSpawn:Float=60) {
		this.type = type;
		this.cost = cost;
		this.frequency = frequency;
		this.nextSpawn = nextSpawn;
	}
}
