package systems;

import resources.Queues.GameActionRequest;
import game.PlayerItem;
import systems.XpSystem.XpConsumeRequest;
import Types.QueueType;
import Types.MinionType;
import ecs.Universe;
import ecs.System;
import Types.CollisionGroup;
import systems.MinionSystem.MinionCreationRequest;
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
					this.addMinion(state.baseMinionType, state.playerPosition.x, state.playerPosition.y, queues);
				}));
			}

			var gameQueue = queues.getQueue(QueueType.GameActionQueue);
			for(req in gameQueue){
				var re:GameActionRequest = req;
				if(re.action == GameAction.TriggerStore){
					this.storeMode();
				}
			}
			queues.clearQueue(QueueType.GameActionQueue);

		});
		handleUIInput();
	}

	public function handleUIInput() {
		setup(gameState, {
			if (state.uiMode == UIMode.MainMenu) {
				if (inputCapture.getActionStatus(GameAction.Select1, true)) {
					initTestScene();
					state.uiMode = UIMode.InGame;
					universe.getPhase('game-logic').enable();
					return;
				}
			}
			if (state.uiMode == UIMode.EndOfGame) {
				if (inputCapture.getActionStatus(GameAction.Select3)) {
					cleanUniverse();
					initTestScene();
					state.currentLevel = 1;
					state.uiMode = UIMode.InGame;

					universe.getPhase('game-logic').enable();
				}
			}
			if (state.uiMode == UIMode.InGame) {
				// if (inputCapture.getActionStatus(GameAction.Select3)) {
				// storeMode();
				// }
			}
			if (state.uiMode == UIMode.InStore) {
				// Process store
				var reward:PlayerItem = null;
				if (inputCapture.getActionStatus(GameAction.Select1)) {
					reward = state.availableItems[0];
				}
				if (inputCapture.getActionStatus(GameAction.Select2)) {
					reward = state.availableItems[1];
				}
				if (inputCapture.getActionStatus(GameAction.Select3)) {
					reward = state.availableItems[2];
				}
				if (reward != null) {
					processReward(reward);
					state.uiMode = UIMode.InGame;
					universe.getPhase('game-logic').enable();
				}
			}
		});
	}

	public function processReward(reward:PlayerItem) {
		setup(gameState, {
			switch (reward.type) {
				case PlayerItemType.MinionBoost5:
					for (i in 0...5)
						this.addMinion(state.baseMinionType, state.playerPosition.x, state.playerPosition.y, queues);
				case PlayerItemType.TowerBuilder:
					this.addMinion(MinionType.TowerBuilder, state.playerPosition.x, state.playerPosition.y, queues);
				case PlayerItemType.BombImbuer:
					this.addMinion(MinionType.BombImbuer, state.playerPosition.x, state.playerPosition.y, queues);
				case _:
					trace('Should probably code ' + reward.type);
			}
		});
	}

	var rewardsArray = [
		[
			new PlayerItem(PlayerItemType.MinionBoost5),
			new PlayerItem(PlayerItemType.TowerBuilder),
			new PlayerItem(PlayerItemType.BombImbuer)
		],
		[
			new PlayerItem(PlayerItemType.MinionBoost10),
			new PlayerItem(PlayerItemType.TowerBuilder),
			new PlayerItem(PlayerItemType.BombImbuer)
		]
	];

	public function storeMode() {
		setup(gameState, {
			state.availableItems = rewardsArray[state.currentRewardTier];
			state.uiMode = UIMode.InStore;
			universe.getPhase('game-logic').disable();
			state.currentRewardTier ++;
		});
	}

	public function cleanUniverse() {
		var gameState = new GameState();
		var queues = new Queues();
		universe.setResources(gameState, queues);
		iterate(worldObjects, entity -> {
			universe.deleteEntity(entity);
		});
	}

	// Todo: make levels a thing
	public function initTestScene() {
		setup(gameState, {
			final playerObject = universe.createEntity();
			state.currentRewardTier = 0;
			queues.queueGameAction(GameAction.TriggerStore);
			var hp = new HealthContainer(100);
			state.hp = hp;
			state.currentThreat = 10;
			state.currentLevel = 1;
			state.ticksElapsed = 0;
			final playerPosition = new Position(Constants.screenSpaceWidth / 2, screenSpaceHeight / 2);
			state.playerPosition = playerPosition;
			universe.setComponents(playerObject, playerPosition, new Velocity(0, 0), new Sprite(hxd.Res.circle_orange, displayResources.scene, 7, 7),
				new PlayerControlled(),
				new Collidable(CollisionGroup.Player, [CollisionGroup.Enemy, CollisionGroup.Pickup],
					new PendingEffects(ColissionEffectType.FullConsume, 10000), 3.5),
				hp, new DecomposeEffects([this.endGame]), new HpRegen(0.1,0.1));

			for (i in 0...initialMinions)
				addMinion(state.baseMinionType, state.playerPosition.x, state.playerPosition.y, queues);
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
		var req:MinionCreationRequest = {minionType: type, startPosition: new Position(initX, initY)};
		queues.queue(QueueType.MinionCreationQueue, req);
	}
}
