package systems;

class DecompositionSystem extends System{
    @:fastFamily var decompostables:{decompose:Decompose};

    override function update(_dt:Float) {
		iterate(decompostables, entity -> {
			universe.deleteEntity(entity);
		});
    }
}