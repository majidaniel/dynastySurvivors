import haxe.macro.Compiler.IncludePosition;

enum abstract GameAction(Int) to Int {
	var MoveLeft;
	var MoveRight;
	var MoveUp;
	var MoveDown;
	var MergeAction;
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

enum abstract MinionType(String) to String{
	var BasicShooter;
	var SlowDefender;
	var ShooterTier2;
}

enum abstract QueueType(String) to String{
	var MinionCreationQueue;
	var XpQueue;
	var EnemyCreationQueue;
}

enum abstract EnemyType(String) to String{
	var BasicFollowEnemy;
}