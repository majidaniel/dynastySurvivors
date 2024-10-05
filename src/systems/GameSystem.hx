package systems;

import Types.QueueType;
import Types.MinionType;
import ecs.Universe;
import ecs.System;
import Types.CollisionGroup;
import systems.MinionSystem.MinionRequest;
import h2d.Text;

// System that is responsible for setting up levels & reacting to win conditions
class GameSystem extends System {
	private var closestEnemyPosition:Position = null;

	@:fullFamily var gameState:{
		requires:{},
		resources:{state:GameState, displayResources:DisplayResources, queues:Queues}
	};

	var enemySpawnCap:Float = .5;
	var enemySpawn:Float = 0;
	var enemyCount:Int = 1;

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
				for(i in 0 ... Math.ceil(enemyCount / 5) * Math.ceil(enemyCount / 20) * 2){
					addEnemy(state.playerPosition, displayResources); 
				}
				enemyCount;
				enemySpawn = enemySpawnCap - 0.25 * (enemyCount % 50 / 50);
			}

			this.minionSpawn -= dt;
			if (this.minionSpawn < 0) {
				//if (minionCount % 10 == 0)
				//	this.addMinion(MinionType.SlowDefender, state.playerPosition.x, state.playerPosition.y, queues);
				//else
					this.addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
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

	public function addMinion(type:Types.MinionType, initX:Float, initY:Float, queues:Queues) {
		var req:MinionRequest = {minionType: type, startPosition: new Position(initX, initY)};
		queues.queue(QueueType.MinionCreationQueue, req);
	}

	// TODO: add types
	public function addEnemy(playerPosition:Position, displayResources:DisplayResources) {
		var enemy = universe.createEntity();
		var vector:Vector = new Vector(Math.random() - 0.5, Math.random() - 0.5).normalized() * 360;
		vector = vector.add(playerPosition.vector);
		universe.setComponents(enemy, new Position(vector.x, vector.y), new Velocity(0, 0), new Sprite(hxd.Res.circle_red, displayResources.scene, 10, 10),
			new PlayerSeeker(PlayerSeekingType.Linear, Constants.ENEMY_DEFAULT_MAX_SPEED, Constants.ENEMY_DEFAULT_ACCELERATION),
			new Collidable(CollisionGroup.Enemy, [CollisionGroup.Player], new PendingEffects(ColissionEffectType.Damage, 10), 5), new Enemy(),
			new HealthContainer(40));
	}
}
