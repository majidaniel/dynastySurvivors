package systems;

import resources.Queues.HpEffectRequest;
import ecs.Entity;

class EffectResolutionSystem extends System {
	@:fullFamily var healthContainers:{
		requires:{
			healthContainer:HealthContainer
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
	}
}
