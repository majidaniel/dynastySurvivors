package systems;

// System that is responsible for setting up levels & reacting to win conditions
class BulletSystem extends System {
	private var closestEnemyPosition:Position = null;

	@:fullFamily var emitters:{
		requires:{bulletEmitter:BulletEmitter, position:Position},
		resources:{state:GameState, displayResources:DisplayResources}
	};

	public override function update(dt:Float) {
		super.update(dt);
		setup(emitters, {
			iterate(emitters, {
				bulletEmitter.timeToNextEmission -= dt;
				if (bulletEmitter.timeToNextEmission < 0) {
					var bulletSpeed = 200;
					var velocity;
					// if(closestEnemyPosition != null)
					//	velocity = closestEnemyPosition.vector.sub(state.playerPosition.vector).normalized()*bulletSpeed;
					// else
					velocity = new Vector(Math.random() - 0.5, Math.random() - 0.5).normalized() * bulletSpeed;
					addBullet(position.x, position.y, velocity, displayResources);
					bulletEmitter.timeToNextEmission = bulletEmitter.reloadSpeed;
				}
			});
		});
	}

	// TODO: add types, damage amount
	public function addBullet(startX:Float, startY:Float, velocity:Vector, displayResources:DisplayResources) {
		var bullet = universe.createEntity();
		universe.setComponents(bullet, new Position(startX, startY), new Velocity(velocity.x, velocity.y),
			new Sprite(hxd.Res.circle, displayResources.scene, 3, 3),
			new Collidable(CollisionGroup.PlayerBullet, [CollisionGroup.Enemy], [new PendingEffect(ColissionEffectType.Damage, 10)], 3),
			new HealthContainer(1));
	}

	/*private function cacheEnemyStats() {
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
	}*/
}
