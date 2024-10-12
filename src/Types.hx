import haxe.macro.Compiler.IncludePosition;

enum abstract GameAction(Int) to Int {
	var MoveLeft;
	var MoveRight;
	var MoveUp;
	var MoveDown;
	var MergeAction;
}

enum abstract CollisionGroup(String) to String {
	var Player;
	var Enemy;
	var PlayerBullet;
	var Pickup;
}

enum abstract PlayerSeekingType(Int) to Int{
	var Linear;
}

enum abstract ColissionEffectType(Int) to Int{
	var Damage;
	var FullConsume;
}

enum abstract BulletType(String) to String{
	var Basic;
	var Basic3;
	var Basic5;
	var Basic10;
	var Melee;
}

enum abstract BulletTargetingPriority(Int) to Int{
	var Closest;
}

enum abstract MinionType(String) to String{
	var BasicShooter;
	var BasicShooter2;
	var BasicShooter3;
	var BasicShooter4;
	var SlowDefender;
	var ShooterTier2;
}

enum abstract QueueType(String) to String{
	var MinionCreationQueue;
	var XpQueue;
	var EnemyCreationQueue;
}

enum abstract EnemyType(String) to String{
	var XpGain;
	var BasicFollowEnemy;
	var LargeFollowEnemy;
}