package components;

import Types.CollisionGroup;
import differ.shapes.Circle;
import differ.shapes.Shape;

//Component that indicates an entity can collide with other entities
class Collidable {
	public var collisionGroup:CollisionGroup;
	public var shape:Shape;
	public var collidesWith:Array<CollisionGroup>;
	public var collisionEffects:PendingEffects;

	public function new(collisionGroup:CollisionGroup, collidesWith:Array<CollisionGroup>,collisionEffects:PendingEffects=null,collisionSize:Float=10) {
		this.collisionGroup = collisionGroup;

		this.collidesWith = collidesWith;

		this.collisionEffects = collisionEffects;
		
		this.shape = new Circle(0, 0, collisionSize);
	}
}
