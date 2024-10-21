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
				sprite.setRelativePosition(pos.x,pos.y);
			});
		});
	}

	override function onEnabled() {
		super.onEnabled();
		renderables.onEntityAdded.subscribe(entity ->{
			setup(renderables,{
				fetch(renderables,entity, {
					displayResources.scene.addChild(sprite.graphics);
				});
			});
		});
		renderables.onEntityRemoved.subscribe(entity ->{
			setup(renderables,{
				fetch(renderables,entity, {
					displayResources.scene.removeChild(sprite.graphics);
				});
			});
		});
	}
}
