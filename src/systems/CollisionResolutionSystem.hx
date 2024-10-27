package systems;

import systems.ParticleSystem.ParticlesRequest;
import differ.Collision;
import ecs.System;
import components.Collided;

// System that resolves collissions
// Keeping this separate from the detection system let's us layer on game logic into colissions without complicating the detection engine
class CollisionResolutionSystem extends System {
	// @:fastFamily var collissionsWithEffects:{collided:Collided, pendingEffect:PendingEffects, healthContainer:HealthContainer};
	@:fullFamily var collissionsWithEffects:{
		requires:{
			collided:Collided,
			pendingEffect:PendingEffects,
			healthContainer:HealthContainer,
			position:Position
		},
		resources:{queues:Queues}
	};

	override function update(_dt:Float) {
		setup(collissionsWithEffects, {
			iterate(collissionsWithEffects, entity -> {
				for (effect in pendingEffect.pendingEffects) {
					if (effect.type == ColissionEffectType.Damage) {
						queues.queueHpEffect(entity, -1 * effect.amount);
					} else if (effect.type == ColissionEffectType.FullConsume) {
						universe.setComponents(entity, new Decompose());
					} else if (effect.type == ColissionEffectType.Particles) {
						var req:ParticlesRequest = {startPosition: new Position(position.x, position.y), quantity: 0};
						queues.queue(QueueType.ParticleCreationQueue, req);
					} else if (effect.type == ColissionEffectType.BombImbue) {
						queues.queueStatusEffect(entity, new StatusEffect(StatusEffectType.Bomb));
					}
				}

				universe.removeComponents(entity, collided);
			});
		});
	}
}
