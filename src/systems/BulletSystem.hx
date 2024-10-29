package systems;

import h2d.Particles.PartEmitMode;
import resources.Queues.ParticlesRequest;

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
			iterate(emitters, entity -> {
				bulletEmitter.timeToNextEmission -= dt;
				if (bulletEmitter.timeToNextEmission < 0) {
					cacheEnemyStats();
					var velocity:Vector = null;
					var targetPosition = determineTargetPosition(bulletEmitter.targeting, position, this.enemyPositions);

					if (targetPosition == null)
						velocity = new Vector(Math.random() - 0.5, Math.random() - 0.5).normalized();
					else
						velocity = new Vector(targetPosition.x - position.x, targetPosition.y - position.y).normalized();

					var bulletConsumption = addBullet(bulletEmitter.bulletType, position.x, position.y, velocity, displayResources, queues,bulletEmitter.maximumShots,bulletEmitter.shotsRemaining);
					bulletEmitter.timeToNextEmission = bulletEmitter.reloadSpeed * (1 + (Math.random() - .5) * Constants.MINION_RELOAD_VARIANCE);

					if (bulletEmitter.shotsRemaining != null) {
						bulletEmitter.shotsRemaining -= bulletConsumption;
						if (bulletEmitter.shotsRemaining <= 0)
							universe.removeComponents(entity, bulletEmitter);
					}
				}
			});
		});
	}

	public function addBullet(type:BulletType, startX:Float, startY:Float, velocity:Vector, displayResources:DisplayResources, queues:Queues, maximumShots:Float,shotsRemaining:Float):Int {
		var bulletSpeed = 1;
		var decayDistance:Float = null;
		var sprite:Sprite = null;
		var decayTime:Float = null;
		var collideSize = 3;
		var hpContainer = new HealthContainer(1);
		var spreadFromOrigin:Float = 0;

		// Bullet properties
		if (type == BulletType.Melee) {
			bulletSpeed = 40;
			decayDistance = 20;
			sprite = new Sprite(hxd.Res.circle, displayResources.scene, 10, 10);
		} else if (type == BulletType.Basic || type == BulletType.Basic3 || type == BulletType.Basic5 || type == BulletType.Basic10) {
			bulletSpeed = 200;
			decayDistance = 200;
			sprite = new Sprite(hxd.Res.circle, displayResources.scene, 3, 3);
		} else if (type == BulletType.BombApplier) {
			bulletSpeed = 300;
			decayDistance = 1000;
			sprite = new Sprite(hxd.Res.circle_black_border_red, displayResources.scene, 5, 5);
		} else if (type == BulletType.Bomb) {
			sprite = new Sprite(hxd.Res.circle_orange, displayResources.scene, 40, 40);
			sprite.bitmap.alpha=0;
			bulletSpeed = 0;
			decayTime = 0.001;
			collideSize = 20;
			hpContainer.hpAmount = 1000;
			spreadFromOrigin = 50 + 2 * (maximumShots - shotsRemaining);
		}
		velocity *= bulletSpeed;

		// Scatter if necessary
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

		var pendEffects = new PendingEffects(ColissionEffectType.Damage, Constants.BASE_BULLET_DAMAGE);
		if (type == BulletType.BombApplier)
			pendEffects = new PendingEffects(ColissionEffectType.BombImbue, Constants.BASE_BULLET_DAMAGE);

		// TODO: factor out for loop from decompose effects.  Position needing to b unique per bullet is the blocker.
		for (vel in velocityArray) {
			var velocity = new Velocity(vel.x, vel.y);

			var position = new Position(startX, startY);
			if (spreadFromOrigin > 0) {
				position.x += Math.random() * spreadFromOrigin - (spreadFromOrigin / 2);
				position.y += Math.random() * spreadFromOrigin - (spreadFromOrigin / 2);
			}

			var decomposeEffects = new DecomposeEffects([
				function() {
					var req:ParticlesRequest = {startPosition: new Position(position.x, position.y), quantity: 0, velocity: new Velocity(velocity.vector.x,velocity.vector.y), emitMode: PartEmitMode.Point};
					queues.queue(QueueType.ParticleCreationQueue, req);
				}
			]);

			if (type == BulletType.Bomb) {
				decomposeEffects = new DecomposeEffects([
					function() {
						var decayObj = universe.createEntity();
						var ghostSprite:Sprite = sprite.clone();
						universe.setComponents(decayObj, new Position(position.x, position.y), ghostSprite, new DecayOnTime(1), new AlphaDecay(0.5));
					}
				]);
			}

			generateBullet(position, velocity, collideSize, sprite, decayDistance, decayTime, pendEffects, hpContainer, decomposeEffects);
		}
		return 1;
	}

	private function generateBullet(position:Position, velocity:Velocity, collideSize:Float, sprite:Sprite, decayDistance:Float,
			decayTime:Float, pendingEffects:PendingEffects = null, hpContainer:HealthContainer, decomposeEffects:DecomposeEffects) {
		setup(emitters, {
			var bullet = universe.createEntity();

			universe.setComponents(bullet, position, velocity, sprite.clone(),
				new Collidable(CollisionGroup.PlayerBullet, [CollisionGroup.Enemy], pendingEffects, collideSize), hpContainer, decomposeEffects);
			if (decayDistance != null)
				universe.setComponents(bullet, new DecayOnDistance(decayDistance));
			if (decayTime != null)
				universe.setComponents(bullet, new DecayOnTime(decayTime,true));
		});
	}

	private function determineTargetPosition(type:BulletTargetingPriority, originPosition:Position, targetPositions:Array<Position>):Position {
		if (type == BulletTargetingPriority.Closest) {
			if (targetPositions.length > 0) {
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
		}

		// Default to random
		// if (type == BulletTargetingPriority.Random)
		return new Position(Math.random() - 0.5 + originPosition.x, Math.random() - 0.5 + originPosition.y);
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
