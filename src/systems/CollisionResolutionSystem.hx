package systems;

import ecs.System;
import components.Collided;

// System that resolves collissions
// Keeping this separate from the detection system let's us layer on game logic into colissions without complicating the detection engine
class CollisionResolutionSystem extends System {
	@:fastFamily var collissionsWithEffects:{collided:Collided, pendingEffect:PendingEffects, healthContainer:HealthContainer};

	override function update(_dt:Float) {
		iterate(collissionsWithEffects, entity -> {
			//Avoid calling deleteEntity multiple times
			var skipOut = false;
			for (effect in pendingEffect.pendingEffects) {
				if(skipOut) continue;
				if (effect.type == ColissionEffectType.Damage) {
					healthContainer.hpAmount -= effect.amount;
					if (healthContainer.hpAmount <= 0) {
						universe.setComponents(entity, new Decompose());
						// TODO: offload to destruction system
						//universe.deleteEntity(entity);
						//skipOut = true;
					}
				} else if (effect.type == ColissionEffectType.FullConsume) {
					//universe.deleteEntity(entity);
					universe.setComponents(entity, new Decompose());
					//skipOut = true;
				}
			}

			universe.removeComponents(entity, collided);
		});
	}
}
