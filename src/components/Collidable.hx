package components;

import Types.CollisionGroup;
import differ.shapes.Circle;
import differ.shapes.Shape;

//Component that indicates an entity can collide with other entities
class Collidable {
	public var collisionGroup:CollisionGroup;
	public var shape:Shape;
	public var collidesWith:Array<CollisionGroup>;

	public function new(collisionGroup:CollisionGroup, collidesWith:Array<CollisionGroup>) {
		this.collisionGroup = collisionGroup;

		this.collidesWith = collidesWith;

		this.shape = new Circle(0, 0, 25);
	}
}
