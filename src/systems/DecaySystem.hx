package systems;

class DecaySystem extends System {
	@:fullFamily var decayByDistance:{
		requires:{decayOnDistance:DecayOnDistance, position:Position},
		resources:{}
	};

	override function update(_dt:Float) {
		iterate(decayByDistance, entity -> {
			if (decayOnDistance.lastPosition == null)
				decayOnDistance.lastPosition = position;
			var distMoved:Float = position.vector.distance(decayOnDistance.lastPosition.vector);
			decayOnDistance.distanceRemaining -= distMoved;
			if (decayOnDistance.distanceRemaining <= 0)
				universe.setComponents(entity, new Decompose());
            decayOnDistance.lastPosition = new Position(position.x,position.y);
		});
	}
}
