package systems;

import game.MinionData;
import Types.QueueType;
import Types.MinionType;
import haxe.ds.Map;
import macros.*;

typedef MinionRequest = {var minionType:MinionType; var startPosition:Position;}

class MinionSystem extends System {
	@:fullFamily var minions:{
		requires:{follower:PlayerFollower, velocity:Velocity, position:Position},
		resources:{
			state:GameState,
			displayResources:DisplayResources,
			queues:Queues,
			inputCapture:InputCapture
		}
	};

	@:fullFamily var sys:{
		requires:{},
		resources:{displayResources:DisplayResources, queues:Queues, inputCapture:InputCapture}
	}

	var minionDetailsList:Map<MinionType, MinionData> = new std.Map();
	var mergeActionReset = false;

	override function update(_dt:Float) {
		var minionCount = new Map<MinionType, Int>();
		setup(minions, {
			iterate(minions, {
				// Build up minionCount status. TODO: Move into add/remove moments only
				if (!minionCount.exists(follower.type))
					minionCount.set(follower.type, 1);
				else {
					minionCount[follower.type]++;
					if (minionCount[follower.type] > 5) {
						// state.debugText = "Spacebar to merge!";
						state.canPlayerTakeAction = true;
					} else {
						state.canPlayerTakeAction = false;
					}
				}

				// Update target velocity for minion. TODO: doesn't need to happen every cycle
				var vectorY = state.playerPosition.y - position.y + follower.relativePosition.y;
				var vectorX = state.playerPosition.x - position.x + follower.relativePosition.x;
				var vector = new Vector(vectorX, vectorY);
				if (vector.length() <= 1) {
					velocity.vector.x = 0;
					velocity.vector.y = 0;
				} else {
					var normalizedVector = vector.normalized();
					velocity.vector.x += follower.acceleration * _dt * normalizedVector.x;
					velocity.vector.y += follower.acceleration * _dt * normalizedVector.y;

					if (velocity.vector.length() > follower.maxSpeed) {
						var finalNormalizedVector = new Vector(vectorX, vectorY).normalized();
						velocity.vector.x = finalNormalizedVector.x * follower.maxSpeed;
						velocity.vector.y = finalNormalizedVector.y * follower.maxSpeed;
					}
				}
			});
		});
		setup(sys, {
			var minionCreationQueue = queues.getQueue(QueueType.MinionCreationQueue);
			for (req in minionCreationQueue) {
				// var minionRequest:MinionRequest = req;
				createMinion(req.minionType, req.startPosition, displayResources);
			}
			queues.clearQueue(QueueType.MinionCreationQueue);
			mergeMinions(minionCount);
			if (inputCapture.getActionStatus(GameAction.MergeAction)) {
				if (!mergeActionReset) {
					mergeMinions(minionCount);
					mergeActionReset = true;
					// state.debugText = "";
				}
			} else {
				mergeActionReset = false;
			}
		});
	}

	override function onEnabled() {
		super.onEnabled();
		minions.onEntityAdded.subscribe(entity -> {
			adjustMinionPositions();
		});
		var dat:Array<Dynamic> = JsonMacro.load('res/minions.json');
		for (ent in dat) {
			var minionData = new MinionData(ent);
			minionDetailsList.set(minionData.type, minionData);
		}
	}

	function createMinion(type:MinionType, startPosition:Position, displayResources:DisplayResources) {
		var minionData = minionDetailsList.get(type);

		var follower = universe.createEntity();
		universe.setComponents(follower, startPosition, new Velocity(0, 0),
			new PlayerFollower(type, minionData.maxSpeed * (1 + (Math.random() - 0.5) * Constants.MINION_MOVE_VARIANCE), minionData.acceleration,
				minionData.radialLevel));
		universe.setComponents(follower, new BulletEmitter(minionData.bulletType, minionData.reloadSpeed));
		
		var circleSize=4;
		var sprite=hxd.Res.circle_green;
		switch(type){
			case MinionType.BasicShooter: circleSize = 4;
			case MinionType.BasicShooter2: circleSize = 8;
			case MinionType.BasicShooter3: circleSize = 12;
			case MinionType.BasicShooter4: circleSize = 30;
			case MinionType.SlowDefender: circleSize = 6;
			case MinionType.ShooterTier2: circleSize=10;
		}
		universe.setComponents(follower, new Sprite(sprite, displayResources.scene, circleSize, circleSize));
	}

	function adjustMinionPositions() {
		setup(minions, {
			var radialLevels = new Map<Int, Int>();
			var minionCount = new Map<Int, Int>();
			iterate(minions, {
				if (!radialLevels.exists(follower.radialLevel))
					radialLevels[follower.radialLevel] = 1;
				else
					radialLevels[follower.radialLevel]++;
				if (!minionCount.exists(follower.radialLevel))
					minionCount[follower.radialLevel] = 1;
				else
					minionCount[follower.radialLevel]++;
			});
			var currentPositions = new Map<Int, Int>();
			for (l in radialLevels.keys()) {
				currentPositions[l] = 0;
			}
			iterate(minions, {
				var degrees = (2 * Math.PI) * currentPositions[follower.radialLevel] / radialLevels[follower.radialLevel];
				follower.relativePosition = new Vector(Math.cos(degrees),
					Math.sin(degrees)).normalized() * follower.radialLevel * (1
						+ Constants.MINION_DISTANCE_PER_RADIAL_LEVEL
						+ MINION_RADIAL_DISTANCE_RATIO * follower.radialLevel * minionCount[follower.radialLevel]);
				currentPositions[follower.radialLevel]++;
			});
		});
	}

	function mergeMinions(minionCount:Map<MinionType, Int>) {
		setup(minions, {
			for (type => count in minionCount) {
				if (count > minionDetailsList[type].numberToUpgrade) {
					var req:MinionRequest = {
						minionType: minionDetailsList[type].upgradeMinion,
						startPosition: new Position(state.playerPosition.x, state.playerPosition.y)
					};
					queues.queue(QueueType.MinionCreationQueue, req);
					var destroyCount = minionDetailsList[type].numberToUpgrade;
					iterate(minions, entity -> {
						if (follower.type == type && destroyCount > 0) {
							universe.setComponents(entity, new Decompose());
							destroyCount--;
						}
					});
				}
			}
		});
	}
}
