package systems;

// System that is responsible for setting up levels & reacting to win conditions
class BulletSystem extends System {
	private var enemyPositions:Array<Position> = new Array();

	@:fullFamily var emitters:{
		requires:{bulletEmitter:BulletEmitter, position:Position},
		resources:{state:GameState, displayResources:DisplayResources}
	};
	@:fullFamily var enemyList:{
		requires:{enemy:Enemy, position:Position},
		resources:{state:GameState}
	}

	public override function update(dt:Float) {
		super.update(dt);
		setup(emitters, {
			iterate(emitters, {
				bulletEmitter.timeToNextEmission -= dt;
				if (bulletEmitter.timeToNextEmission < 0) {
					cacheEnemyStats();
					var bulletSpeed = 200;
					var velocity:Vector = null;
					var targetPosition = determineTargetPosition(bulletEmitter.targeting, position, this.enemyPositions);
					// if(closestEnemyPosition != null)
					//	velocity = closestEnemyPosition.vector.sub(state.playerPosition.vector).normalized()*bulletSpeed;
					// else
					if (targetPosition == null)
						velocity = new Vector(Math.random() - 0.5, Math.random() - 0.5).normalized() * bulletSpeed;
					else
						velocity = new Vector(targetPosition.x - position.x, targetPosition.y - position.y).normalized() * bulletSpeed;
					addBullet(position.x, position.y, velocity, displayResources);
					bulletEmitter.timeToNextEmission = bulletEmitter.reloadSpeed * (1 + (Math.random() - .5) * Constants.MINION_RELOAD_VARIANCE);
				}
			});
		});
	}

	// TODO: add types, damage amount
	public function addBullet(startX:Float, startY:Float, velocity:Vector, displayResources:DisplayResources) {
		// TODO: prob need to optimize
		var bullet = universe.createEntity();
		universe.setComponents(bullet, new Position(startX, startY), new Velocity(velocity.x, velocity.y),
			new Sprite(hxd.Res.circle, displayResources.scene, 3, 3),
			new Collidable(CollisionGroup.PlayerBullet, [CollisionGroup.Enemy], new PendingEffects(ColissionEffectType.Damage, 5), 3), new HealthContainer(1),
			new DecayOnDistance(1000));
	}

	private function determineTargetPosition(type:BulletTargetingPriority, originPosition:Position, targetPositions:Array<Position>):Position {
		if (targetPositions.length == 0)
			return null;

		if (type == BulletTargetingPriority.Closest) {
			var tarPosition:Position = null;
			var tarDistance:Float = 99999;
			for (pos in targetPositions) {
				if (tarDistance > pos.vector.distance(originPosition.vector)) {
					tarPosition = pos;
					tarDistance = pos.vector.distance(originPosition.vector);
				}
			}
			return tarPosition;
		}
		return null;
	}

	private function cacheEnemyStats() {
		enemyPositions = new Array();
		setup(enemyList, {
			iterate(enemyList, {
				enemyPositions.push(position);
			});
		});
	}
}
