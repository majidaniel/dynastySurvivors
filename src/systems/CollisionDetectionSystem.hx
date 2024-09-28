package systems;

import ecs.Entity;
import differ.Collision;
import differ.data.ShapeCollision;
import Types.CollisionGroup;
import differ.shapes.Shape;
import ecs.System;
import components.Collidable;
import components.Collided;
import components.Position;

// System that determines collisions between entities with a Collidable component on them
class CollisionDetectionSystem extends System {
	@:fastFamily var collidables:{pos:Position, collider:Collidable};

	override function update(_dt:Float) {
		// Update positions on collidables
		iterate(collidables, {
			collider.shape.x = pos.x;
			collider.shape.y = pos.y;
		});

		// We have separated collidables into groups so that we are only checking collisions between entities that we care about
		var collisionMap:Map<CollisionGroup, Array<Shape>> = new Map();
		iterate(collidables, entity -> {
			if (!collisionMap.exists(collider.collisionGroup))
				collisionMap.set(collider.collisionGroup, new Array<Shape>());
			collider.shape.data = entity;
			collisionMap.get(collider.collisionGroup).push(collider.shape);
		});

		iterate(collidables, {
			for (collisionChecks in collider.collidesWith) {
				if (collisionMap.exists(collisionChecks)) {
					var res:Results<ShapeCollision> = Collision.shapeWithShapes(collider.shape, collisionMap.get(collisionChecks));
					if (res.length != 0) {
						for (x in res.iterator()) {
							var ent:Entity = x.shape1.data;
							var ent2:Entity = x.shape2.data;
							universe.setComponents(ent, new Collided(ent2));
							universe.setComponents(ent2, new Collided(ent));
						}
					}
				}
			}
		});
	}
}
