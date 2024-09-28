package systems;

import resources.GameState;
import ecs.Universe;
import resources.DisplayResources;
import ecs.System;
import components.*;
import Types.CollisionGroup;
import h2d.Text;

//System that is responsible for setting up levels & reacting to win conditions
class GameSystem extends System {
	@:fullFamily var gameState:{
		requires:{},
		resources:{state:GameState, displayResources:DisplayResources}
	};

	public override function update(dt:Float) {
		setup(gameState, {
			// If not level is loaded, load a level
			if (state.currentLevel == null) {
				initLevel1(displayResources);
				state.currentLevel = 1;
			}

			if (state.levelComplete) {
				var font:h2d.Font = hxd.res.DefaultFont.get();
				font.resizeTo(60);
				var tf = new h2d.Text(font);
				tf.color = new h3d.Vector4(0, 0, 0);
				tf.x = 300;
				tf.y = 100;
				tf.text = "You Win!";
				tf.textAlign = Center;
				displayResources.scene.add(tf);
				state.levelComplete = false;
				// TODO: Unload level resources, start next level
			}
		});
	}

	public function initLevel1(displayResources:DisplayResources) {
			final playerObject = universe.createEntity();
			final obstacle1 = universe.createEntity();
			final obstacle2 = universe.createEntity();
			final finishSpot = universe.createEntity();

			universe.setComponents(playerObject, new Position(200, 200), new Velocity(0, 0), new Sprite(hxd.Res.circle, displayResources.scene, 10, 10),
				new PlayerControlled(), new Collidable(CollisionGroup.Player, [CollisionGroup.Obstacles]));
		
	}
}
