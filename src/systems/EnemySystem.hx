package systems;

import h3d.Vector;
import resources.GameState;
import ecs.Universe;
import resources.DisplayResources;
import ecs.System;
import components.*;
import Types.CollisionGroup;
import h2d.Text;
import systems.XpSystem.XpGainRequest;

class EnemyCreationRequest {
	var enemyType:EnemyType;
	var startPosition:Position = null;

	public function new(enemyType:EnemyType, startPosition:Position = null) {
		this.enemyType = enemyType;
		this.startPosition = startPosition;
	}
}

// System that is responsible for setting up levels & reacting to win conditions
class EnemySystem extends System {
	@:fullFamily var enemies:{
		requires:{playerSeeker:PlayerSeeker, velocity:Velocity, position:Position},
		resources:{state:GameState, displayResources:DisplayResources, queues:Queues}
	};

	@:fullFamily var sys:{
		requires:{},
		resources:{displayResources:DisplayResources,queues:Queues}
	}

	override function update(_dt:Float) {
		setup(enemies, {
			iterate(enemies, {
				if (playerSeeker.seekingType == PlayerSeekingType.Linear) {
					var vectorY = state.playerPosition.y - position.y;
					var vectorX = state.playerPosition.x - position.x;
					var normalizedVector = new Vector(vectorX, vectorY).normalized();
					velocity.vector.x += playerSeeker.acceleration * normalizedVector.x;
					velocity.vector.y += playerSeeker.acceleration * normalizedVector.y;

					if (velocity.vector.length() > playerSeeker.maxSpeed) {
						var finalNormalizedVector = new Vector(vectorX, vectorY).normalized();
						velocity.vector.x = finalNormalizedVector.x * playerSeeker.maxSpeed;
						velocity.vector.y = finalNormalizedVector.y * playerSeeker.maxSpeed;
					}
				}
			});
		});
		setup(sys, {
			var enemyCreationQueue = queues.getQueue(QueueType.MinionCreationQueue);

			for (req in enemyCreationQueue) {
				// var minionRequest:MinionRequest = req;
				createEnemy(req.enemyType, req.startPosition, displayResources, queues);
			}
			queues.clearQueue(QueueType.EnemyCreationQueue);
		});
	}

	function createEnemy(enemyType:EnemyType, position:Position, displayResources:DisplayResources, queues:Queues) {
		var enemy = universe.createEntity();
		var vector:Vector = new Vector(Math.random() - 0.5, Math.random() - 0.5).normalized() * 360;
		vector = vector.add(position.vector);
		universe.setComponents(enemy, new Position(vector.x, vector.y), new Velocity(0, 0), new Sprite(hxd.Res.circle_red, displayResources.scene, 10, 10),
			new PlayerSeeker(PlayerSeekingType.Linear, Constants.ENEMY_DEFAULT_MAX_SPEED, Constants.ENEMY_DEFAULT_ACCELERATION),
			new Collidable(CollisionGroup.Enemy, [CollisionGroup.Player], new PendingEffects(ColissionEffectType.Damage, 10), 5), new HealthContainer(10),
			new DecomposeEffects([
				function() {
					queues.queue(QueueType.XpQueue, new XpGainRequest(5));
				}
			]));
	}
}
