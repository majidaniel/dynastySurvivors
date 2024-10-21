package systems;

import systems.EnemySystem.EnemyCreationRequest;

// Misc components attached to enemies and minions, merge with bullet system at some point?
class FieldComponentSystem extends System {
	@:fullFamily var enemySpawners:{
		requires:{enemySpawner:EnemySpawner, position:Position, velocity:Velocity},
		resources:{queues:Queues}
	}

	override function update(_dt:Float) {
		setup(enemySpawners, {
			iterate(enemySpawners, entity -> {
				enemySpawner.nextSpawn -= _dt;
				if (enemySpawner.nextSpawn < 0) {
					for (angle in enemySpawner.directions) {
						var initVelocity:Vector = new Vector(0, 0);
						if (enemySpawner.velocity != 0) {
							var spawnVector = velocity.vector.normalized();
							initVelocity = new Vector(spawnVector.x * Math.cos(angle * Math.PI / 180) - spawnVector.y * Math.sin(angle * Math.PI / 180),
								spawnVector.x * Math.sin(angle * Math.PI / 180) + spawnVector.y * Math.cos(angle * Math.PI / 180)) * enemySpawner.velocity;
						}

						var req = new EnemyCreationRequest(enemySpawner.type, new Position(position.x, position.y), initVelocity);
						queues.queue(QueueType.EnemyCreationQueue, req);
					}

					enemySpawner.nextSpawn = enemySpawner.frequency;
				}
			});
		});
	}
}