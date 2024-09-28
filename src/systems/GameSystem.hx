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

	@:fullFamily var enemyList:{
		requires:{enemy:Enemy, position:Position},
		resources:{state:GameState}
	}

	var fireCooldownCap:Float = 0.5;
	var fireCooldown:Float = 0;

	var enemySpawnCap:Float = 1;
	var enemySpawn:Float = 0;

	public override function update(dt:Float) {
		setup(gameState, {
			cacheEnemyStats();
			// If not level is loaded, load a level
			if (state.currentLevel == null) {
				initTestScene(displayResources);
				state.currentLevel = 1;
			}

			if (state.levelComplete) {
				var font:h2d.Font = hxd.res.DefaultFont.get();
				font.resizeTo(60);
				var tf = new h2d.Text(font);
				tf.color = new h3d.Vector4(0, 0, 0);
				tf.x = 300;
				tf.y = 100;
				tf.text = "You Win!";
				tf.textAlign = Center;
				displayResources.scene.add(tf);
				state.levelComplete = false;
				// TODO: Unload level resources, start next level
			}
			
			this.fireCooldown -= dt;
			if (fireCooldown < 0 ) {
				var bulletSpeed = 200;
				var velocity;
				if(closestEnemyPosition != null)
					velocity = closestEnemyPosition.vector.sub(state.playerPosition.vector).normalized()*bulletSpeed;
				else
					velocity = new Vector(Math.random()-0.5,Math.random()-0.5).normalized()*bulletSpeed;
				addBullet(state.playerPosition.x, state.playerPosition.y, velocity, displayResources);
				this.fireCooldown = this.fireCooldownCap;
			}

			this.enemySpawn -= dt;
			if(enemySpawn < 0){
				enemySpawn = enemySpawnCap;
				addEnemy(displayResources);
			}
		});
	}

	private function cacheEnemyStats() {
		setup(enemyList, {
			var closestEnemyPosition:Position = null;
			var closestEnemyDistance:Float = null;
			iterate(enemyList, {
				if (closestEnemyPosition == null || position.vector.sub(state.playerPosition.vector).length() < closestEnemyDistance) {
					closestEnemyPosition = position;
					closestEnemyDistance = position.vector.sub(state.playerPosition.vector).length();
				}
			});
			this.closestEnemyPosition = closestEnemyPosition;
		});
	}

	public function initTestScene(displayResources:DisplayResources) {
		setup(gameState, {
			final playerObject = universe.createEntity();
			state.hp = 100;
			final playerPosition = new Position(200, 200);
			state.playerPosition = playerPosition;
			universe.setComponents(playerObject, playerPosition, new Velocity(0, 0), new Sprite(hxd.Res.circle_green, displayResources.scene, 10, 10),
				new PlayerControlled(), new Collidable(CollisionGroup.Player, [CollisionGroup.Enemy],[new PendingEffect(ColissionEffectType.FullConsume,10000)],5), new HealthContainer(100));
		});
	}

	// TODO: add types
	public function addEnemy(displayResources:DisplayResources) {
		var enemy = universe.createEntity();
		universe.setComponents(enemy, new Position(100, 100), new Velocity(0, 0), new Sprite(hxd.Res.circle_red, displayResources.scene, 10, 10),
			new PlayerSeeker(PlayerSeekingType.Linear, Constants.ENEMY_DEFAULT_MAX_SPEED, Constants.ENEMY_DEFAULT_ACCELERATION),
			new Collidable(CollisionGroup.Enemy, [CollisionGroup.Player],[new PendingEffect(ColissionEffectType.Damage,10)],5), new Enemy(), new HealthContainer(20));
	}

	//TODO: add types, damage amount
	public function addBullet(startX:Float, startY:Float, velocity:Vector, displayResources:DisplayResources) {
		var bullet = universe.createEntity();
		universe.setComponents(bullet, new Position(startX, startY), new Velocity(velocity.x, velocity.y),
			new Sprite(hxd.Res.circle, displayResources.scene, 3, 3), new Collidable(CollisionGroup.PlayerBullet, [CollisionGroup.Enemy],[new PendingEffect(ColissionEffectType.Damage,10)],3),
			new HealthContainer(1));
	}
}
