package game;

class EnemySpawn {
	public var type:EnemyType;
	public var probability:Float;
	public var quantity:Int = 1;

	public function new(jsonInput:Dynamic) {
		this.type = jsonInput.type;
		this.probability = jsonInput.probability;
		if (jsonInput.quantity != null)
			this.quantity = jsonInput.quantity;
	}
}

class WaveData {
	public var waveType:WaveType;
	public var enemyDistribution:Array<EnemySpawn> = new Array();

	public function new(jsonInput:Dynamic) {
		this.waveType = jsonInput.waveType;
		var distributions:Array<Dynamic> = jsonInput.enemyDistribution;
		for (dist in distributions) {
			enemyDistribution.push(new EnemySpawn(dist));
		}
	}
}

class WaveSetup {
	public var waveType:WaveType;
	public var startingThreat:Float;
	public var spawnAt:Float;
	public var consumed:Bool = false;

	public function new(jsonInput:Dynamic) {
		this.waveType = jsonInput.waveType;
		if(jsonInput.startingThreat != null)
			this.startingThreat = jsonInput.startingThreat;
		if(jsonInput.spawnAt != null)
			this.spawnAt = jsonInput.spawnAt;
	}
}
