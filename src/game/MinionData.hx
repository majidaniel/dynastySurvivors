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

	public var type:MinionType;

	public function new(jsonInput:Dynamic) {
		this.type = jsonInput.type;

		this.reloadSpeed = jsonInput.reloadSpeed;
		this.maxSpeed = jsonInput.maxSpeed;
		this.acceleration = jsonInput.acceleration;
		this.radialLevel = jsonInput.radialLevel;
		if (jsonInput.upgradesTo != null) {
			this.upgradeMinion = jsonInput.upgradesTo.upgradeMinionType;
			this.numberToUpgrade = jsonInput.upgradesTo.numberToUpgrade;
		}
	}
}
