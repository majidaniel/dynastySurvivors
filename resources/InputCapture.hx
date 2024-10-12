package resources;

import hxd.Pad;
import Types.GameAction;

// Singleton that hooks into Heaps.io's keyboard even system and translates it into action enum
class InputCapture {
	var keycodeMap:Map<Int, GameAction> = new Map();
	var actionStatus:Map<GameAction, Bool> = new Map();
	var pad:Pad;

	public function new() {
		hxd.Window.getInstance().addEventTarget(onEvent);
		keycodeMap.set(38, GameAction.MoveUp);
		keycodeMap.set(39, GameAction.MoveRight);
		keycodeMap.set(40, GameAction.MoveDown);
		keycodeMap.set(37, GameAction.MoveLeft);
		keycodeMap.set(32, GameAction.MergeAction);

		hxd.Pad.wait(onPad);
	}

	function onPad( p : hxd.Pad ){
		if( !p.connected )
		  trace("Pad not connected ?");
		p.onDisconnect = function(){
		  if( p.connected )
			trace("OnDisconnect called while still connected ?");
		}
		this.pad=p;
	  }


	public function onEvent(event:hxd.Event) {
		switch (event.kind) {
			case EKeyDown:
				var actionType = keycodeMap.get(event.keyCode);
				if (actionType != null)
					actionStatus.set(actionType, true);
			case EKeyUp:
				var actionType = keycodeMap.get(event.keyCode);
				if (actionType != null)
					actionStatus.set(actionType, false);
			case _:
		}
	}

	public function getActionStatus(gameAction:GameAction) {
		//trace(pad);
		var status = actionStatus.get(gameAction);
		if (status == null)
			return false;
		return status;
	}
}
