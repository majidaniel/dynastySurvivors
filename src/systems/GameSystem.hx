package systems;

import systems.XpSystem.XpConsumeRequest;
import Types.QueueType;
import Types.MinionType;
import ecs.Universe;
import ecs.System;
import Types.CollisionGroup;
import systems.MinionSystem.MinionRequest;
import Types.UIMode;

// System that is responsible for setting up levels & reacting to win conditions
class GameSystem extends System {
	private var closestEnemyPosition:Position = null;

	@:fullFamily var gameState:{
		requires:{},
		resources:{
			state:GameState,
			displayResources:DisplayResources,
			queues:Queues,
			inputCapture:InputCapture
		}
	};
	@:fullFamily var worldObjects:{
		requires:{position:Position},
		resources:{}
	}
	var initialMinions = 5;

	public override function update(dt:Float) {
		setup(gameState, {
			if (state.xp >= 100) {
				queues.queue(QueueType.XpQueue, new XpConsumeRequest(100, function() {
					this.addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
				}));
			}
		});
		handleUIInput();
	}

	public function handleUIInput() {
		setup(gameState, {
			if (state.uiMode == UIMode.MainMenu) {
				if (inputCapture.getActionStatus(GameAction.Select1)) {
					initTestScene();
					state.currentLevel = 1;
					state.uiMode = UIMode.InGame;
					universe.getPhase('game-logic').enable();
				}
			}
			if( state.uiMode == UIMode.EndOfGame){
				if(inputCapture.getActionStatus(GameAction.Select3)){
					cleanUniverse();
					initTestScene();
					state.currentLevel = 1;
					state.uiMode = UIMode.InGame;
					universe.getPhase('game-logic').enable();
				}
			}
		});
	}

	public function cleanUniverse(){
		var gameState = new GameState();
		var queues = new Queues();
		universe.setResources(gameState,queues);
		iterate(worldObjects, entity->{
			universe.deleteEntity(entity);
		});
	}

	public function initTestScene() {
		setup(gameState, {
			final playerObject = universe.createEntity();
			var hp = new HealthContainer(100);
			state.hp = hp;
			final playerPosition = new Position(Constants.screenSpaceWidth / 2, screenSpaceHeight / 2);
			state.playerPosition = playerPosition;
			universe.setComponents(playerObject, playerPosition, new Velocity(0, 0), new Sprite(hxd.Res.circle_orange, displayResources.scene, 7, 7),
				new PlayerControlled(),
				new Collidable(CollisionGroup.Player, [CollisionGroup.Enemy, CollisionGroup.Pickup],
					new PendingEffects(ColissionEffectType.FullConsume, 10000), 3.5),
				hp, new DecomposeEffects([this.endGame]));

			for (i in 0...initialMinions)
				addMinion(MinionType.BasicShooter, state.playerPosition.x, state.playerPosition.y, queues);
		});
	}

	override function onEnabled() {
		super.onEnabled();
	}

	private function endGame() {
		setup(gameState, {
			universe.getPhase('game-logic').disable();
			state.uiMode = UIMode.EndOfGame;
		});
	}

	public function addMinion(type:Types.MinionType, initX:Float, initY:Float, queues:Queues) {
		var req:MinionRequest = {minionType: type, startPosition: new Position(initX, initY)};
		queues.queue(QueueType.MinionCreationQueue, req);
	}
}
