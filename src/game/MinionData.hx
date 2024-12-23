package game;

import haxe.macro.Compiler.IncludePosition;

typedef MinionTier = {
	var numberToUpgradeTo:Int;
	var reloadSpeed:Float;
}

class MinionData {
	// var type:MinionType;
	public var reloadSpeed:Float;
	public var maxSpeed:Float;
	public var acceleration:Float;
	public var radialLevel:Int;

	public var numberToUpgrade:Int;
	public var upgradeMinion:MinionType;
	public var bulletType:BulletType;

	public var type:MinionType;

	public var upgradeQuantityFloor:Float;
	public var upgradeScaffoldingCount:Float;

	public var components:Array<Dynamic>;

	public var minionSpawn:MinionType;
	public var minionSpawnCost:Int;
	public var minionSpawnFrequency:Float;
	public var minionSpawnFrequencyStart:Float;

	public var bulletTargetingPriority:BulletTargetingPriority;

	public function new(jsonInput:Dynamic) {
		this.type = jsonInput.type;

		this.reloadSpeed = jsonInput.reloadSpeed;
		this.maxSpeed = jsonInput.maxSpeed;
		this.acceleration = jsonInput.acceleration;
		this.radialLevel = jsonInput.radialLevel;
		this.bulletType = jsonInput.bulletType;
		if (jsonInput.upgradesTo != null) {
			this.upgradeMinion = jsonInput.upgradesTo.upgradeMinionType;
			this.numberToUpgrade = jsonInput.upgradesTo.numberToUpgrade;
			this.upgradeQuantityFloor = jsonInput.upgradesTo.upgradeQuantityFloor;
			this.upgradeScaffoldingCount = jsonInput.upgradesTo.upgradeScaffoldingCount;
		}
		if (jsonInput.components != null) {
			this.components = jsonInput.components;
		}
		if (jsonInput.minionSpawn != null) {
			this.minionSpawn = jsonInput.minionSpawn;
			this.minionSpawnCost = jsonInput.minionSpawnCost;
			this.minionSpawnFrequency = jsonInput.minionSpawnFrequency;
			this.minionSpawnFrequencyStart = jsonInput.minionSpawnFrequencyStart;
		}
		if (jsonInput.bulletTargetingPriority != null)
			this.bulletTargetingPriority = jsonInput.bulletTargetingPriority;
	}
}
