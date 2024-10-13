package systems;

class DecompositionSystem extends System {
	@:fastFamily var decompostables:{decompose:Decompose};
	
	@:fullFamily var decompostablesWithEffects:{
		requires:{decompose:Decompose,effects:DecomposeEffects},
		resources:{}
	}

	override function update(_dt:Float) {
		iterate(decompostablesWithEffects, entity ->{
			if(decompose.triggerDecompositions){
				for (f in effects.effects) {
					f();
				}
			}
			universe.deleteEntity(entity);
		});

		iterate(decompostables, entity -> {
			universe.deleteEntity(entity);
		});
	}
}
