package systems;

import js.lib.intl.NumberFormat.CurrencyDisplay;
import haxe.ds.Map;

class MinionSystem extends System {
	@:fullFamily var minions:{
		requires:{follower:PlayerFollower, velocity:Velocity, position:Position},
		resources:{state:GameState, displayResources:DisplayResources}
	};

	override function update(_dt:Float) {
		setup(minions, {
			iterate(minions, {
				var vectorY = state.playerPosition.y - position.y + follower.relativePosition.y;
				var vectorX = state.playerPosition.x - position.x + follower.relativePosition.x;
				var vector = new Vector(vectorX, vectorY);
				if (vector.length() <= 1) {
					velocity.vector.x = 0;
					velocity.vector.y = 0;
				} else {
					var normalizedVector = vector.normalized();
					velocity.vector.x += follower.acceleration * _dt * normalizedVector.x;
					velocity.vector.y += follower.acceleration * _dt * normalizedVector.y;

					if (velocity.vector.length() > follower.maxSpeed) {
						var finalNormalizedVector = new Vector(vectorX, vectorY).normalized();
						velocity.vector.x = finalNormalizedVector.x * follower.maxSpeed;
						velocity.vector.y = finalNormalizedVector.y * follower.maxSpeed;
					}
				}
			});
		});
	}

	override function onEnabled() {
		super.onEnabled();
		minions.onEntityAdded.subscribe(entity ->{
			adjustMinionPositions();
		});
	}

	function adjustMinionPositions() {
		setup(minions, {
			var radialLevels = new Map<Int, Int>();
			iterate(minions, {
				if (!radialLevels.exists(follower.radialLevel))
					radialLevels[follower.radialLevel] = 1;
				else
					radialLevels[follower.radialLevel]++;
			});
			var currentPositions = new Map<Int, Int>();
			for (l in radialLevels.keys()) {
				currentPositions[l] = 0;
			}
			iterate(minions, {
				var degrees = (2 * Math.PI) * currentPositions[follower.radialLevel] / radialLevels[follower.radialLevel];
				follower.relativePosition = new Vector(Math.cos(degrees),
					Math.sin(degrees)).normalized() * follower.radialLevel * Constants.MINION_DISTANCE_PER_RADIAL_LEVEL;
				currentPositions[follower.radialLevel]++;
			});
		});
	}
}
