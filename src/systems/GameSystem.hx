package systems;

import haxe.Constraints.Function;
import systems.XpSystem.XpGainRequest;
import systems.XpSystem.XpConsumeRequest;
import Types.QueueType;
import Types.MinionType;
import ecs.Universe;
import ecs.System;
import Types.CollisionGroup;
import systems.MinionSystem.MinionRequest;

// System that is responsible for setting up levels & reacting to win conditions
class GameSystem extends System {
	private var closestEnemyPosition:Position = null;

	@:fullFamily var gameState:{
		requires:{},
		resources:{state:GameState, displayResources:DisplayResources, queues:Queues}
	};

	@:fullFamily var decomposers:{
		requires:{effects:DecomposeEffects},
		resources:{}
	}

	var enemySpawnCap:Float = .5;
	var enemySpawn:Float = 0;
	var enemyCount:Int = 1;

	var xpGainCap:Float = 1;
	var xpGain:Float = 0;

	var xpGainAmount = 5;

	public override function update(dt:Float) {
		setup(gameState, {
			// If not level is loaded, load a level
			if (state.currentLevel == null) {
				initTestScene(displayResources);
				state.currentLevel = 1;
			}

			this.enemySpawn -= dt;
			if (enemySpawn < 0) {
				for (i in 0...Math.ceil(enemyCount / 5) * Math.ceil(enemyCount / 20)) {
					addEnemy(state.playerPosition, displayResources, queues);
				}
				enemyCount;
				enemySpawn = enemySpawnCap - 0.25 * (enemyCount % 50 / 50);
			}

			this.xpGain -= dt;
			if (this.xpGain < 0) {
				queues.queue(QueueType.XpQueue, new XpGainRequest(xpGainAmount));
				this.xpGain = this.xpGainCap;
			}
			if (state.xp >= 100) {
				queues.queue(QueueType.XpQueue, new XpConsumeRequest(100, function() {
					this.addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
				}));
			}
		});
	}

	public function initTestScene(displayResources:DisplayResources) {
		setup(gameState, {
			final playerObject = universe.createEntity();
			state.hp = 100;
			final playerPosition = new Position(200, 200);
			state.playerPosition = playerPosition;
			universe.setComponents(playerObject, playerPosition, new Velocity(0, 0), new Sprite(hxd.Res.circle_orange, displayResources.scene, 7, 7),
				new PlayerControlled(),
				new Collidable(CollisionGroup.Player, [CollisionGroup.Enemy], new PendingEffects(ColissionEffectType.FullConsume, 10000), 3.5),
				new HealthContainer(100));
			addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
			addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
			addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
			addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
		});
	}

	override function onEnabled() {
		super.onEnabled();
		decomposers.onEntityRemoved.subscribe(entity -> {
			setup(decomposers, {
				fetch(decomposers, entity, {
					this.evaluateDecomposition(effects.effects);
				});
			});
		});
	}

	private function evaluateDecomposition(effects:Array<Function>) {
		for (f in effects) {
			f();
		}
	}

	public function addMinion(type:Types.MinionType, initX:Float, initY:Float, queues:Queues) {
		var req:MinionRequest = {minionType: type, startPosition: new Position(initX, initY)};
		queues.queue(QueueType.MinionCreationQueue, req);
	}

	// TODO: add types
	public function addEnemy(playerPosition:Position, displayResources:DisplayResources, queues:Queues) {
		var enemy = universe.createEntity();
		var vector:Vector = new Vector(Math.random() - 0.5, Math.random() - 0.5).normalized() * 360;
		vector = vector.add(playerPosition.vector);
		universe.setComponents(enemy, new Position(vector.x, vector.y), new Velocity(0, 0), new Sprite(hxd.Res.circle_red, displayResources.scene, 10, 10),
			new PlayerSeeker(PlayerSeekingType.Linear, Constants.ENEMY_DEFAULT_MAX_SPEED, Constants.ENEMY_DEFAULT_ACCELERATION),
			new Collidable(CollisionGroup.Enemy, [CollisionGroup.Player], new PendingEffects(ColissionEffectType.Damage, 10), 5), new Enemy(),
			new HealthContainer(20), new DecomposeEffects([
				function() {
					queues.queue(QueueType.XpQueue, new XpGainRequest(5));
				}
			]));
	}
}
