package systems;

import h2d.filter.Glow;
import resources.Queues.StatusEffectRequest;
import resources.Queues.HpEffectRequest;
import ecs.Entity;

class EffectResolutionSystem extends System {
	@:fullFamily var healthContainers:{
		requires:{
			healthContainer:HealthContainer
		},
		resources:{queues:Queues}
	};
	@:fullFamily var regens:{
		requires:{
			healthContainer:HealthContainer,
			hpRegen:HpRegen
		},
		resources:{}
	};
	@:fullFamily var decomposers:{
		requires:{
			decomposeEffects:DecomposeEffects
		},
		resources:{queues:Queues}
	};
	@:fullFamily var positions:{
		requires:{
			position:Position
		},
		resources:{queues:Queues}
	};
	@:fullFamily var sprites:{
		requires:{
			sprite:Sprite
		}
	};
	@:fullFamily var alphaDecayers:{
		requires:{alphaDecay:AlphaDecay, sprite:Sprite},
		resources:{}
	};

	override function update(_dt:Float) {
		setup(healthContainers, {
			for (req in queues.getQueue(QueueType.HpEffectQueue)) {
				var re:HpEffectRequest = req;
				var ent:Entity = re.entity;
				fetch(healthContainers, ent, {
					healthContainer.hpAmount += re.amount;
					if (healthContainer.hpAmount <= 0) {
						universe.setComponents(re.entity, new Decompose());
					}
				});
			}
			queues.clearQueue(QueueType.HpEffectQueue);
		});

		setup(decomposers, {
			for (req in queues.getQueue(QueueType.StatusEffectQueue)) {
				// Concat decompose effects
				var re:StatusEffectRequest = req;
				var ent:Entity = re.entity;
				var decomposeEffect = new DecomposeEffects();

				switch (re.statusEffect.type) {
					case StatusEffectType.Bomb:
						fetch(positions, ent, {
							var blastSize:Int = 1;
							fetch(healthContainers, ent, {
								if (healthContainer != null && healthContainer.initialHpAmount > 1) {
									blastSize = Math.ceil(Math.log(healthContainer.initialHpAmount) * Math.log(Math.log(healthContainer.initialHpAmount)) * 2 * (1
										+ Math.random() * 0.5));
								}
							});
							decomposeEffect.addEffect(function() {
								var explosionGenerator = universe.createEntity();
								universe.setComponents(explosionGenerator, new Position(position.x, position.y));
								universe.setComponents(explosionGenerator,
									new BulletEmitter(BulletType.Bomb, 0.05, BulletTargetingPriority.Closest, blastSize));
							});
							// Alter visuals
							fetch(sprites, ent, {
								//sprite.graphics.filter = new Glow(0xffdf27, 1, 3,1,10,true);
								sprite.bitmap.filter = new Glow(0xffdf27, 1, 3);
							});
						});
					case _:
						trace("Should probably implement " + re.statusEffect);
				}

				fetch(decomposers, ent, {
					if (decomposeEffects != null) {
						decomposeEffect.concatEffects(decomposeEffects);
					}
				});

				universe.setComponents(ent, decomposeEffect);
			}
			queues.clearQueue(QueueType.StatusEffectQueue);
		});

		setup(alphaDecayers, {
			iterate(alphaDecayers, {
				alphaDecay.currentTime += _dt;
				sprite.bitmap.alpha = Math.max(0, 1 - alphaDecay.currentTime / alphaDecay.timeToDecay);
			});
		});

		iterate(regens, entity -> {
			hpRegen.timeToNextRegen -= _dt;
			if (hpRegen.timeToNextRegen <= 0) {
				healthContainer.hpAmount += hpRegen.regenAmount;
				if (healthContainer.hpAmount > healthContainer.maxAmount)
					healthContainer.hpAmount = healthContainer.maxAmount;
				hpRegen.timeToNextRegen = hpRegen.regenFrequency;
				if (hpRegen.regenTotal != -1) {
					hpRegen.regenTotal--;
					if (hpRegen.regenTotal <= 0)
						universe.removeComponents(entity, hpRegen);
				}
			}
		});
	}
}
