package systems;

import systems.ParticleSystem.ParticlesRequest;

// System that is responsible for setting up levels & reacting to win conditions
class BulletSystem extends System {
	private var enemyPositions:Array<Position> = new Array();

	@:fullFamily var emitters:{
		requires:{bulletEmitter:BulletEmitter, position:Position},
		resources:{state:GameState, displayResources:DisplayResources, queues:Queues}
	};
	@:fullFamily var enemyList:{
		requires:{
			playerSeeker:PlayerSeeker,
			position:Position,
			hp:HealthContainer,
			threatGenerator:ThreatGenerator
		},
		resources:{state:GameState}
	}

	public override function update(dt:Float) {
		super.update(dt);
		setup(emitters, {
			iterate(emitters, {
				bulletEmitter.timeToNextEmission -= dt;
				if (bulletEmitter.timeToNextEmission < 0) {
					cacheEnemyStats();
					var velocity:Vector = null;
					var targetPosition = determineTargetPosition(bulletEmitter.targeting, position, this.enemyPositions);

					if (targetPosition == null)
						velocity = new Vector(Math.random() - 0.5, Math.random() - 0.5).normalized();
					else
						velocity = new Vector(targetPosition.x - position.x, targetPosition.y - position.y).normalized();

					addBullet(bulletEmitter.bulletType, position.x, position.y, velocity, displayResources,queues);
					bulletEmitter.timeToNextEmission = bulletEmitter.reloadSpeed * (1 + (Math.random() - .5) * Constants.MINION_RELOAD_VARIANCE);
				}
			});
		});
	}

	public function addBullet(type:BulletType, startX:Float, startY:Float, velocity:Vector, displayResources:DisplayResources,queues:Queues) {
		var bulletSpeed = 1;
		var decayDistance:Float = 0;
		var sprite:Sprite = null;
		if (type == BulletType.Melee) {
			bulletSpeed = 40;
			decayDistance = 20;
			sprite = new Sprite(hxd.Res.circle, displayResources.scene, 10, 10);
		} else if (type == BulletType.Basic || type == BulletType.Basic3 || type == BulletType.Basic5 || type == BulletType.Basic10) {
			bulletSpeed = 200;
			decayDistance = 200;
			sprite = new Sprite(hxd.Res.circle, displayResources.scene, 3, 3);
		}else if(type == BulletType.BombApplier){
			bulletSpeed = 300;
			decayDistance = 1000;
			sprite = new Sprite(hxd.Res.circle_black_border_red,displayResources.scene, 5,5);
		}

		velocity *= bulletSpeed;

		var velocityArray = [velocity];
		var scatterArray = [];
		if (type == BulletType.Basic3) {
			scatterArray = [-15, 15];
		} else if (type == BulletType.Basic5) {
			scatterArray = [-30, -15, 15, 30];
		} else if (type == BulletType.Basic10) {
			scatterArray = [-60, -45, -30, -15, 15, 30, 45, 60];
		}
		for (angle in scatterArray) {
			velocityArray.push(new Vector(velocity.x * Math.cos(angle * Math.PI / 180) - velocity.y * Math.sin(angle * Math.PI / 180),
				velocity.x * Math.sin(angle * Math.PI / 180) + velocity.y * Math.cos(angle * Math.PI / 180)));
		}

		for (vel in velocityArray) {
			var bullet = universe.createEntity();
			var pendEffects = new PendingEffects(ColissionEffectType.Damage, Constants.BASE_BULLET_DAMAGE);
			if(type == BulletType.BombApplier)
				pendEffects = new PendingEffects(ColissionEffectType.BombApply, Constants.BASE_BULLET_DAMAGE);
			// pendEffects.addEffect(ColissionEffectType.Particles,0);
			var position = new Position(startX, startY);
			var decomposeEffects = new DecomposeEffects([
				function()
				{
					var req:ParticlesRequest = {startPosition: new Position(position.x, position.y), quantity: 0};
					queues.queue(QueueType.ParticleCreationQueue, req);
				}
			]);

			universe.setComponents(bullet, position, new Velocity(vel.x, vel.y), sprite,
				new Collidable(CollisionGroup.PlayerBullet, [CollisionGroup.Enemy], pendEffects, 3), new HealthContainer(1),
				new DecayOnDistance(decayDistance), decomposeEffects);
		}
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
				if (threatGenerator.threatLevel > 0)
					enemyPositions.push(position);
			});
		});
	}
}
