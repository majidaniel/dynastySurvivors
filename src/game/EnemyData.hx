package game;

class EnemyData {
	public var type:EnemyType;
	public var maxSpeed:Float;
	public var acceleration:Float;
	public var hp:Float;
	public var playerDamage:Float;
	public var xpValue:Float;
	public var spawn:EnemyType;
	public var collisionGroup:CollisionGroup;
	public var collisionSize:Float;
	public var spawnOdds:Float;

	public function new(jsonInput:Dynamic) {
		this.type = jsonInput.type;
		this.maxSpeed = jsonInput.maxSpeed;
		this.acceleration = jsonInput.acceleration;
		this.hp = jsonInput.hp;
		this.playerDamage = jsonInput.playerDamage;
		this.xpValue = jsonInput.xpValue;
		this.spawn = jsonInput.spawn;
		this.collisionGroup = jsonInput.collisionGroup;
		this.collisionSize = jsonInput.collisionSize;
		this.spawnOdds = jsonInput.spawnOdds;
	}
}
