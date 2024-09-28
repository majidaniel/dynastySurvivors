package systems;

import h3d.Vector;
import resources.GameState;
import ecs.Universe;
import resources.DisplayResources;
import ecs.System;
import components.*;
import Types.CollisionGroup;
import h2d.Text;

// System that is responsible for setting up levels & reacting to win conditions
class EnemyDecisionSystem extends System {
	@:fullFamily var enemies:{
		requires:{playerSeeker:PlayerSeeker, velocity:Velocity, position:Position},
		resources:{state:GameState, displayResources:DisplayResources}
	};

	override function update(_dt:Float) {
		setup(enemies, {
			iterate(enemies, {
				if (playerSeeker.seekingType == PlayerSeekingType.Linear) {
					var vectorY = state.playerPosition.y - position.y;
					var vectorX = state.playerPosition.x - position.x;
					var normalizedVector = new Vector(vectorX, vectorY).normalized();
					velocity.vector.x += playerSeeker.acceleration * normalizedVector.x;
					velocity.vector.y += playerSeeker.acceleration * normalizedVector.y;

					if (velocity.vector.length() > playerSeeker.maxSpeed) {
						var finalNormalizedVector = new Vector(vectorX, vectorY).normalized();
						velocity.vector.x = finalNormalizedVector.x * playerSeeker.maxSpeed;
						velocity.vector.y = finalNormalizedVector.y * playerSeeker.maxSpeed;
					}
				}
			});
		});
	}
}
