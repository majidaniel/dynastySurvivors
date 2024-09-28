package components;

import ecs.Entity;

//Component indicating that an entity has suffered a collision with another entity
class Collided {
	public var collidedWithEntity:Entity;

	public function new(collidedWithEntity:Entity) {
		this.collidedWithEntity = collidedWithEntity;
	}
}
