package systems;

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

	var enemySpawnCap:Float = 1;
	var enemySpawn:Float = 0;

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
				addEnemy(displayResources);
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
				new Collidable(CollisionGroup.Player, [CollisionGroup.Enemy], [new PendingEffect(ColissionEffectType.FullConsume, 10000)], 3.5),
				new HealthContainer(100),);

			var followerVectors = [new Vector(0, -7), new Vector(0, 7), new Vector(7, 0), new Vector(-7, 0)];
			for (vect in followerVectors) {
				var follower = universe.createEntity();
				universe.setComponents(follower, new Position(playerPosition.x, playerPosition.y), new Velocity(0, 0),
					new Sprite(hxd.Res.circle_green, displayResources.scene, 5, 5),
					new PlayerFollower(vect, Constants.MINION_MAX_SPEED * (1 + (Math.random()-0.5)*Constants.MINION_MOVE_VARIANCE), Constants.MINION_ACCELERATION), new BulletEmitter(BulletType.Basic, 0.5));
			}
		});
	}

	// TODO: add types
	public function addEnemy(displayResources:DisplayResources) {
		var enemy = universe.createEntity();
		universe.setComponents(enemy, new Position(100, 100), new Velocity(0, 0), new Sprite(hxd.Res.circle_red, displayResources.scene, 10, 10),
			new PlayerSeeker(PlayerSeekingType.Linear, Constants.ENEMY_DEFAULT_MAX_SPEED, Constants.ENEMY_DEFAULT_ACCELERATION),
			new Collidable(CollisionGroup.Enemy, [CollisionGroup.Player], [new PendingEffect(ColissionEffectType.Damage, 10)], 5), new Enemy(),
			new HealthContainer(20));
	}
}
