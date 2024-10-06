package systems;

import haxe.Constraints.Function;

class XpGainRequest {
	var type = 0;
	var xpGain:Float;

	public function new(xpGain:Float) {
		this.xpGain = xpGain;
	}
}

class XpConsumeRequest {
	var type = 1;
	var xpAmount:Float;
	var callback:Function;

    public function new(xpAmount:Float,callback:Function) {
		this.xpAmount = xpAmount;
        this.callback = callback;
	}
}

class XpSystem extends System {
	@:fullFamily var gameState:{
		requires:{},
		resources:{
			state:GameState,
			displayResources:DisplayResources,
			queues:Queues,
		}
	};

	override function update(_dt:Float) {
		var minionCount = new Map<MinionType, Int>();
		setup(gameState, {
			var xpQueue = queues.getQueue(QueueType.XpQueue);
			for (req in xpQueue) {
				if (req.type == 0)
					state.xp += req.xpGain;
				if (req.type == 1) {
					if (state.xp >= req.xpAmount) {
						state.xp -= req.xpAmount;
						req.callback();
					}
				}
			}
			queues.clearQueue(QueueType.XpQueue);
		});
	}
}
