import haxe.macro.Compiler.IncludePosition;

enum abstract GameAction(Int) to Int {
	var MoveLeft;
	var MoveRight;
	var MoveUp;
	var MoveDown;
	var MergeAction;
	var Select1;
	var Select2;
	var Select3;
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
	var Particles;
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
	var ParticleCreationQueue;
}

enum abstract EnemyType(String) to String{
	var XpGain;
	var BasicFollowEnemy;
	var LargeFollowEnemy;
	var QuickSmallFollowEnemy;
	var LargeSpawner;
}

enum abstract WaveType(String) to String{
	var OnlyBasicFollowEnemy;
	var MostlyBasicFollowEnemy;
	var MixedFollowEnemy;
}

enum abstract UIMode(String) to String{
	var MainMenu;
	var EndOfGame;
	var InGame;
}