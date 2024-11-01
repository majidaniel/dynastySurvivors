package components;

import ecs.Entity;

// Component indicating that an entity has suffered a collision with another entity
class Collided {
	public var collidedWithEntity:Entity;
	public var collisionPoint:Position;

	public function new(collidedWithEntity:Entity, collisionPoint:Position = null) {
		this.collidedWithEntity = collidedWithEntity;
		this.collisionPoint = collisionPoint;
	}
}
