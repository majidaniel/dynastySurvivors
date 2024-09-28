package systems;

import ecs.Universe;
import resources.DisplayResources;
import ecs.System;
import components.Position;
import components.Sprite;

//System that keeps entities with Sprite components position's in sync with Position components
class RenderSystem extends System {
	@:fullFamily var renderables:{
		requires:{pos:Position, sprite:Sprite},
		resources:{displayResources:DisplayResources}
	};

	override function update(_dt:Float) {
		setup(renderables, {
			iterate(renderables, {
				displayResources.scene.add(sprite.graphics);
				sprite.setRelativePosition(pos.x,pos.y);
			});
		});
	}
}
