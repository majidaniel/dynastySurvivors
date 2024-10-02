import haxe.macro.Compiler.IncludePosition;

enum abstract GameAction(Int) to Int {
	var MoveLeft;
	var MoveRight;
	var MoveUp;
	var MoveDown;
}

enum abstract CollisionGroup(Int) to Int {
	var Player;
	var Enemy;
	var PlayerBullet;
}

enum abstract PlayerSeekingType(Int) to Int{
	var Linear;
}

enum abstract ColissionEffectType(Int) to Int{
	var Damage;
	var FullConsume;
}

enum abstract BulletType(Int) to Int{
	var Basic;
	var Melee;
}

enum abstract BulletTargetingPriority(Int) to Int{
	var Closest;
}

enum abstract MinionType(Int) to Int{
	var BasicShooter;
	var SlowDefender;
}