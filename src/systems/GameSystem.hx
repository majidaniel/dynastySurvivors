package systems;

import Types.MinionType;
import ecs.Universe;
import ecs.System;
import Types.CollisionGroup;
import h2d.Text;

// System that is responsible for setting up levels & reacting to win conditions
class GameSystem extends System {
	private var closestEnemyPosition:Position = null;

	@:fullFamily var gameState:{
		requires:{},
		resources:{state:GameState, displayResources:DisplayResources}
	};

	var enemySpawnCap:Float = .01;
	var enemySpawn:Float = 0;

	var minionSpawnCap:Float = 1;
	var minionSpawn:Float = 0;

	var minionCount = 0;

	public override function update(dt:Float) {
		setup(gameState, {
			// If not level is loaded, load a level
			if (state.currentLevel == null) {
				initTestScene(displayResources);
				state.currentLevel = 1;
			}

			this.enemySpawn -= dt;
			if (enemySpawn < 0) {
				enemySpawn = enemySpawnCap;
				addEnemy(state.playerPosition,displayResources);
			}

			this.minionSpawn -= dt;
			if (this.minionSpawn < 0) {
				if (minionCount % 10 == 0)
					this.addMinion(MinionType.SlowDefender, state.playerPosition.x, state.playerPosition.y, displayResources);
				else
					this.addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, displayResources);
				if (minionCount > 100)
					this.minionSpawn = this.minionSpawnCap;
				minionCount++;
			}
		});
	}

	public function initTestScene(displayResources:DisplayResources) {
		setup(gameState, {
			final playerObject = universe.createEntity();
			state.hp = 100;
			final playerPosition = new Position(200, 200);
			state.playerPosition = playerPosition;
			universe.setComponents(playerObject, playerPosition, new Velocity(0, 0), new Sprite(hxd.Res.circle_green, displayResources.scene, 7, 7),
				new PlayerControlled(),
				new Collidable(CollisionGroup.Player, [CollisionGroup.Enemy], new PendingEffects(ColissionEffectType.FullConsume, 10000), 3.5),
				new HealthContainer(100),);
		});
	}

	public function addMinion(type:Types.MinionType, initX:Float, initY:Float, displayResources:DisplayResources) {
		var follower = universe.createEntity();
		if (type == MinionType.BasicShooter) {
			universe.setComponents(follower, new Position(initX, initY), new Velocity(0, 0), new Sprite(hxd.Res.circle_green, displayResources.scene, 4, 4),
				new PlayerFollower(Constants.MINION_MAX_SPEED * (1 + (Math.random() - 0.5) * Constants.MINION_MOVE_VARIANCE), Constants.MINION_ACCELERATION, 1),
				new BulletEmitter(BulletType.Basic, 0.5));
		} else if (type == MinionType.SlowDefender) {
			universe.setComponents(follower, new Position(initX, initY), new Velocity(0, 0), new Sprite(hxd.Res.circle_green, displayResources.scene, 6, 6),
				new PlayerFollower(Constants.MINION_MAX_SPEED / 4 * (1 + (Math.random() - 0.5) * Constants.MINION_MOVE_VARIANCE),
					Constants.MINION_ACCELERATION / 10, 2),
				new BulletEmitter(BulletType.Melee, 2));
		}
	}

	// TODO: add types
	public function addEnemy(playerPosition:Position,displayResources:DisplayResources) {
		var enemy = universe.createEntity();
		var vector:Vector = new Vector(Math.random()-0.5,Math.random()-0.5).normalized()*300;
		vector.add(playerPosition.vector);
		universe.setComponents(enemy, new Position(vector.x,vector.y), new Velocity(0, 0), new Sprite(hxd.Res.circle_red, displayResources.scene, 10, 10),
			new PlayerSeeker(PlayerSeekingType.Linear, Constants.ENEMY_DEFAULT_MAX_SPEED, Constants.ENEMY_DEFAULT_ACCELERATION),
			new Collidable(CollisionGroup.Enemy, [CollisionGroup.Player], new PendingEffects(ColissionEffectType.Damage, 10), 5), new Enemy(),
			new HealthContainer(20));
	}
}
