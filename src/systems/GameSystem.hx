package systems;

import haxe.Constraints.Function;
import systems.XpSystem.XpConsumeRequest;
import Types.QueueType;
import Types.MinionType;
import ecs.Universe;
import ecs.System;
import Types.CollisionGroup;
import systems.MinionSystem.MinionRequest;
import systems.EnemySystem.EnemyCreationRequest;

// System that is responsible for setting up levels & reacting to win conditions
class GameSystem extends System {
	private var closestEnemyPosition:Position = null;

	@:fullFamily var gameState:{
		requires:{},
		resources:{state:GameState, displayResources:DisplayResources, queues:Queues}
	};

	var xpGainCap:Float = 1;
	var xpGain:Float = 0;

	var xpGainAmount = 5;

	var initialMinions = 5;

	public override function update(dt:Float) {
		setup(gameState, {
			// If not level is loaded, load a level
			if (state.currentLevel == null) {
				initTestScene(displayResources);
				state.currentLevel = 1;
			}

			/*this.xpGain -= dt;
			if (this.xpGain < 0) {
				queues.queue(QueueType.XpQueue, new XpGainRequest(xpGainAmount));
				this.xpGain = this.xpGainCap;
			}*/
			if (state.xp >= 100) {
				queues.queue(QueueType.XpQueue, new XpConsumeRequest(100, function() {
					this.addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
				}));
			}
		});
	}

	public function initTestScene(displayResources:DisplayResources) {
		setup(gameState, {
			final playerObject = universe.createEntity();
			var hp = new HealthContainer(100);
			state.hp = hp;
			final playerPosition = new Position(Constants.screenSpaceWidth/2, screenSpaceHeight/2);
			state.playerPosition = playerPosition;
			universe.setComponents(playerObject, playerPosition, new Velocity(0, 0), new Sprite(hxd.Res.circle_orange, displayResources.scene, 7, 7),
				new PlayerControlled(),
				new Collidable(CollisionGroup.Player, [CollisionGroup.Enemy,CollisionGroup.Pickup], new PendingEffects(ColissionEffectType.FullConsume, 10000), 3.5),
				hp, new DecomposeEffects([this.endGame]));
			
			for (i in 0...initialMinions)
				addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
		});
	}

	override function onEnabled() {
		super.onEnabled();
		
	}

	private function endGame(){
		universe.getPhase('game-logic').disable();
	}

	public function addMinion(type:Types.MinionType, initX:Float, initY:Float, queues:Queues) {
		var req:MinionRequest = {minionType: type, startPosition: new Position(initX, initY)};
		queues.queue(QueueType.MinionCreationQueue, req);
	}

}
