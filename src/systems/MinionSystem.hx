package systems;

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
				if(vector.length() <= 1){
					velocity.vector.x = 0;
					velocity.vector.y = 0;
				}else{
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
}
