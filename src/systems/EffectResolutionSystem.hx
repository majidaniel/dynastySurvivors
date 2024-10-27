package systems;

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
				var re:StatusEffectRequest = req;
				var ent:Entity = re.entity;
				var decomposeEffect = new DecomposeEffects();

				switch (re.statusEffect.type) {
					case StatusEffectType.Bomb:
						fetch(positions, ent, {
							decomposeEffect.addEffect(function() {
								var explosionGenerator = universe.createEntity();
								universe.setComponents(explosionGenerator, new Position(position.x, position.y));
                                //TODO: replace basic10 with bomb
                                universe.setComponents(explosionGenerator, new BulletEmitter(BulletType.Basic10,0.1,BulletTargetingPriority.Closest,1));
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
	}
}
