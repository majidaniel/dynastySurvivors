package systems;

import Types.QueueType;
import Types.MinionType;
import js.lib.intl.NumberFormat.CurrencyDisplay;
import haxe.ds.Map;
import macros.*;

typedef MinionRequest = {var minionType:MinionType; var startPosition:Position;}

class MinionSystem extends System {
	@:fullFamily var minions:{
		requires:{follower:PlayerFollower, velocity:Velocity, position:Position},
		resources:{state:GameState, displayResources:DisplayResources, queues:Queues}
	};

	var minionDetailsList = JsonMacro.load('res/minions.json');

	override function update(_dt:Float) {
		setup(minions, {
			iterate(minions, {
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

			var minionCreationQueue = queues.getQueue(QueueType.MinionCreationQueue);
			for (req in minionCreationQueue) {
				var minionRequest:MinionRequest = req;
				createMinion(req.minionType, req.startPosition, displayResources);
			}
			queues.clearQueue(QueueType.MinionCreationQueue);
		});
	}

	override function onEnabled() {
		super.onEnabled();
		minions.onEntityAdded.subscribe(entity -> {
			adjustMinionPositions();
		});
		trace(minionDetailsList);
	}

	function createMinion(type:MinionType, startPosition:Position, displayResources:DisplayResources) {
		var minionData = minionDetailsList.BasicShooter;
		switch (type) {
			case BasicShooter:
				minionData = minionDetailsList.BasicShooter;
			case SlowDefender:
				minionData = minionDetailsList.SlowDefender;
		}
		var follower = universe.createEntity();
		universe.setComponents(follower, startPosition, new Velocity(0, 0),
			new PlayerFollower(minionData.maxSpeed * (1 + (Math.random() - 0.5) * Constants.MINION_MOVE_VARIANCE), minionData.acceleration,
				minionData.radialLevel));

		if (type == MinionType.BasicShooter) {
			universe.setComponents(follower, new Sprite(hxd.Res.circle_green, displayResources.scene, 4, 4), new BulletEmitter(BulletType.Basic, 0.5));
		} else if (type == MinionType.SlowDefender) {
			universe.setComponents(follower, new Sprite(hxd.Res.circle_green, displayResources.scene, 6, 6), new BulletEmitter(BulletType.Melee, 2));
		}
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
}
