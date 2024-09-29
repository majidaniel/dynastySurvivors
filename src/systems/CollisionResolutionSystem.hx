package systems;

import components.Position;
import ecs.System;
import components.PlayerControlled;
import components.Collided;
import resources.GameState;
import resources.DisplayResources;

// System that resolves collissions
// Keeping this separate from the detection system let's us layer on game logic into colissions without complicating the detection engine
class CollisionResolutionSystem extends System {
	@:fastFamily var collissionsWithEffects:{collided:Collided, pendingEffect:PendingEffects, healthContainer:HealthContainer};

	override function update(_dt:Float) {
		iterate(collissionsWithEffects, entity -> {
			// position.x = 0;
			// position.y = 0;
			// collided.collidedWithEntity;
			for (effect in pendingEffect.pendingEffects) {
				if (effect.type == ColissionEffectType.Damage) {
					healthContainer.hpAmount -= effect.amount;
					if (healthContainer.hpAmount <= 0) {
						trace(healthContainer.hpAmount);
						// TODO: offload to destruction system
						trace("remove " + entity);
						universe.deleteEntity(entity);
						return;
					}
				} else if (effect.type == ColissionEffectType.FullConsume) {
					universe.deleteEntity(entity);
					return;
				}
			}

			universe.removeComponents(entity, collided);
		});
	}
}
