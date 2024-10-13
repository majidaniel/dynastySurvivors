package game;

class EnemySpawn {
	public var type:EnemyType;
	public var probability:Float;

	public function new(jsonInput:Dynamic) {
		this.type = jsonInput.type;
		this.probability = jsonInput.probability;
	}
}

class WaveData {
	public var waveType:WaveType;
	public var enemyDistribution:Array<EnemySpawn> = new Array();

	public function new(jsonInput:Dynamic<>) {
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

	public function new(jsonInput:Dynamic) {
		this.waveType = jsonInput.waveType;
		this.startingThreat = jsonInput.startingThreat;
	}
}
