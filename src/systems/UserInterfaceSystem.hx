package systems;

import h2d.Flow;
import h2d.domkit.Object;
import systems.views.MenuView;
import h2d.Graphics;
import h3d.Vector4;
import ecs.Universe;
import ecs.System;

// System to manage UI
class UserInterfaceSystem extends System {
	@:fullFamily var gameState:{
		requires:{},
		resources:{state:GameState, displayResources:DisplayResources}
	};

	var debugText:h2d.Text;
	var hpText:h2d.Text;
	var actionText:h2d.Text;

	var activeView:Flow;
	var activeViewType:UIMode;

	override function onEnabled() {
		super.onEnabled();
		this.enterMainMenuMode();
	}

	private function enterMainMenuMode() {
		setup(gameState, {
			this.activeView = new MenuView(hxd.Res.circle_orange.toTile(), displayResources.scene);
			state.uiMode = UIMode.MainMenu;
			activeViewType=UIMode.MainMenu;
		});
	}

	public override function update(dT) {
		setup(gameState, {
			if(state.uiMode != this.activeViewType){
				//Clean up time
				displayResources.scene.removeChild(activeView);
				this.activeViewType = state.uiMode;
			}


			if (hpText == null) {
				hpText = this.genText(1, 10);
				displayResources.scene.add(hpText);
			}
			if (actionText == null) {
				actionText = this.genText(10, 30);
				displayResources.scene.add(actionText);
			}
			if (debugText == null) {
				debugText = this.genText(10, 400);
				displayResources.scene.add(debugText);
			}

			if (commandGraphic == null) {
				commandGraphic = new Graphics(displayResources.scene);
			}

			if (state.hp != null)
				this.hpText.text = "HP: " + state.hp.hpAmount;

			if (state.canPlayerTakeAction) {
				this.actionText.text = "Press spacebar";
			} else {
				this.actionText.text = "";
			}
			debugText.text = "";
			for (k => v in state.debugMap) {
				debugText.text += '$k: $v, ';
			}

			debugStuff(displayResources);
			// debugText.text = state.debugText;
			// buildCommandBar(state.availableActions, displayResources.scene);
		});
	}

	private function genText(x:Float, y:Float) {
		var font:h2d.Font = hxd.res.DefaultFont.get();
		var text = new h2d.Text(font);
		text.color = new Vector4(0, 0, 0);
		text.setPosition(x, y);
		return text;
	}

	private function debugStuff(displayResources:DisplayResources) {
		/*
			//Use to draw debug boxes
			var origin = new h2d.Graphics(displayResources.scene);
			origin.beginFill(0xEA8220);
			origin.drawRect(-3 - displayResources.camera.x, -3 - displayResources.camera.y, 6, 6);
			origin.drawRect(-3 - displayResources.camera.x + Constants.GRID_TILE_SIZE, -3 - displayResources.camera.y, 6, 6);
			origin.endFill;
		 */
	}

	private static var BUTTON_WIDTH = 30;
	private static var BUTTON_HEIGHT = 20;

	private var commandGraphic:Graphics;
	/*private function buildCommandBar(availableActions:Array<UserCommands>, scene:Scene) {
			var xOffset = 0;
			commandGraphic.removeChildren();
			for (action in availableActions) {
				var button = buildButton(action);
				button.x = 10 + xOffset * BUTTON_WIDTH + 10 * xOffset;
				button.y = 300;
				xOffset++;
				commandGraphic.addChild(button);
			}
		}

		private function buildButton(action:UserCommands) {
			var buttonGraphic = new h2d.Graphics();
			buttonGraphic.beginFill(0x4CA0DC);
			buttonGraphic.drawRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);

			var font:h2d.Font = hxd.res.DefaultFont.get();
			var text = new h2d.Text(font);
			text.color = new Vector4(0, 0, 0);
			text.setPosition(0, 0);

			switch action {
			
			}

			buttonGraphic.addChild(text);

			var interactive = new h2d.Interactive(BUTTON_WIDTH, BUTTON_HEIGHT);
			interactive.onPush = function(event:Event) {
				this.build(action);
			};
			buttonGraphic.addChild(interactive);

			return buttonGraphic;
	}*/
}
