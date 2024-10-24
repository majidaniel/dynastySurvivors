package systems;

import game.MinionData;
import Types.QueueType;
import Types.MinionType;
import haxe.ds.Map;
import macros.*;

typedef MinionCreationRequest = {var minionType:MinionType; var startPosition:Position;}

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
			var mC = 0;
			var debug_DPS:Float = 0;
			iterate(minions, {
				// TODO: Move to onadded vs every loop
				if (!minionCount.exists(follower.type))
					minionCount.set(follower.type, 1);
				else {
					minionCount[follower.type]++;
				}
				debug_DPS += 1 / minionDetailsList[follower.type].reloadSpeed * Constants.BASE_BULLET_DAMAGE;
				mC++;

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
			state.minionCount = mC;
			state.debugMap['minion count'] = '$mC';
			state.debugMap['DPS'] = '$debug_DPS';
		});
		setup(sys, {
			var minionDeletionQueue = queues.getQueue(QueueType.MinionDestructionQueue);
			for(req in minionDeletionQueue){
				this.destroyMinions(req.minionType,req.quantity);
			}
			queues.clearQueue(QueueType.MinionDestructionQueue);

			var minionCreationQueue = queues.getQueue(QueueType.MinionCreationQueue);
			for (req in minionCreationQueue) {
				createMinion(req.minionType, req.startPosition, displayResources);
			}
			queues.clearQueue(QueueType.MinionCreationQueue);
			mergeMinions(minionCount);
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
		if(minionData.bulletType != null)
			universe.setComponents(follower, new BulletEmitter(minionData.bulletType, minionData.reloadSpeed));
		if(minionData.minionSpawn != null){
			universe.setComponents(follower, new MinionSpawner(minionData.minionSpawn,minionData.minionSpawnCost,minionData.minionSpawnFrequency,minionData.minionSpawnFrequencyStart));
		}

		var circleSize = 4;
		var sprite = hxd.Res.circle_green;
		switch (type) {
			case MinionType.BasicShooter:
				circleSize = 4;
			case MinionType.BasicShooter2:
				circleSize = 8;
			case MinionType.BasicShooter3:
				circleSize = 12;
			case MinionType.BasicShooter4:
				circleSize = 30;
			case MinionType.Tower:
				circleSize = 10;
				sprite = hxd.Res.square_black_grey;
			case MinionType.TowerBuilder:
				circleSize = 6;
				sprite = hxd.Res.square_black_blue;
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
				if (minionDetailsList[type].numberToUpgrade != null && count > minionDetailsList[type].numberToUpgrade) {
					if (minionDetailsList[type].upgradeScaffoldingCount != null) {
						var nextTierCount:Float = 0;
						if (minionCount.exists(minionDetailsList[type].upgradeMinion)) {
							nextTierCount = minionCount[minionDetailsList[type].upgradeMinion] * minionDetailsList[type].upgradeScaffoldingCount;
						}
						if (count < nextTierCount)
							continue;
					}

					if (minionDetailsList[type].upgradeQuantityFloor == null || count > minionDetailsList[type].upgradeQuantityFloor) {
						var req:MinionCreationRequest = {
							minionType: minionDetailsList[type].upgradeMinion,
							startPosition: new Position(state.playerPosition.x, state.playerPosition.y)
						};
						queues.queue(QueueType.MinionCreationQueue, req);
						this.destroyMinions(type,minionDetailsList[type].numberToUpgrade);
					}
				}
			}
		});
	}

	function destroyMinions(minionType:MinionType,destroyCount:Int){
		iterate(minions, entity -> {
			if (follower.type == minionType && destroyCount > 0) {
				universe.setComponents(entity, new Decompose());
				destroyCount--;
			}
		});
	}
}
