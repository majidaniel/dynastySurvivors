package systems;

import haxe.macro.Expr.Constant;
import h3d.Vector;
import resources.GameState;
import ecs.Universe;
import resources.DisplayResources;
import ecs.System;
import components.*;
import Types.CollisionGroup;
import h2d.Text;
import systems.XpSystem.XpGainRequest;
import game.EnemyData;
import haxe.Constraints.Function;
import macros.*;

class EnemyCreationRequest {
	var enemyType:EnemyType;
	var startPosition:Position = null;

	public function new(enemyType:EnemyType, startPosition:Position = null) {
		this.enemyType = enemyType;
		this.startPosition = startPosition;
	}
}

// System that is responsible for setting up levels & reacting to win conditions
class EnemySystem extends System {
	@:fullFamily var enemies:{
		requires:{playerSeeker:PlayerSeeker, velocity:Velocity, position:Position},
		resources:{state:GameState, displayResources:DisplayResources, queues:Queues}
	};

	@:fullFamily var sys:{
		requires:{},
		resources:{displayResources:DisplayResources, queues:Queues}
	}

	var enemyDetailsList:Map<EnemyType, EnemyData> = new std.Map();

	override function onEnabled() {
		super.onEnabled();

		var dat:Array<Dynamic> = JsonMacro.load('res/enemies.json');
		for (ent in dat) {
			var enemyData = new EnemyData(ent);
			enemyDetailsList.set(enemyData.type, enemyData);
		}
	}

	override function update(_dt:Float) {
		setup(enemies, {
			iterate(enemies, {
				if (playerSeeker.seekingType == PlayerSeekingType.Linear) {
					var vectorY = state.playerPosition.y - position.y;
					var vectorX = state.playerPosition.x - position.x;
					var normalizedVector = new Vector(vectorX, vectorY).normalized();
					velocity.vector.x += playerSeeker.acceleration * normalizedVector.x * _dt;
					velocity.vector.y += playerSeeker.acceleration * normalizedVector.y * _dt;

					if (velocity.vector.length() > playerSeeker.maxSpeed) {
						var finalNormalizedVector = new Vector(velocity.vector.x, velocity.vector.y).normalized();
						velocity.vector.x = finalNormalizedVector.x * playerSeeker.maxSpeed;
						velocity.vector.y = finalNormalizedVector.y * playerSeeker.maxSpeed;
					}
				}
			});
		});
		setup(sys, {
			var enemyCreationQueue = queues.getQueue(QueueType.EnemyCreationQueue);
			for (req in enemyCreationQueue) {
				if (req.startPosition == null) {
					var vector:Vector = new Vector(Math.random() - 0.5,
						Math.random() - 0.5).normalized() * Math.sqrt(Constants.screenSpaceWidth * Constants.screenSpaceWidth / 4
							+ Constants.screenSpaceHeight * Constants.screenSpaceHeight / 4);
					vector = vector.add(new Vector(Constants.screenSpaceWidth / 2, Constants.screenSpaceHeight / 2));
					req.startPosition = new Position(vector.x, vector.y);
				}
				createEnemy(req.enemyType, req.startPosition, displayResources, queues);
			}
			queues.clearQueue(QueueType.EnemyCreationQueue);
		});
	}

	function createEnemy(enemyType:EnemyType, position:Position, displayResources:DisplayResources, queues:Queues) {
		var enemyData = enemyDetailsList.get(enemyType);
		var enemy = universe.createEntity();
		// Force a new position so references aren't lost
		var newPosition = new Position(position.x, position.y);

		var decomposeEffects:Array<Function> = [];
		if (enemyData.xpValue != null && enemyData.xpValue != 0) {
			decomposeEffects.push(function() {
				queues.queue(QueueType.XpQueue, new XpGainRequest(enemyData.xpValue));
			});
		}

		if (enemyData.spawn != null) {
			if(enemyData.spawnOdds == null || Math.random() < enemyData.spawnOdds)
			decomposeEffects.push(function() {
				var req = new EnemyCreationRequest(enemyData.spawn, newPosition);
				queues.queue(QueueType.EnemyCreationQueue, req);
			});
		}

		var sprite;
		switch (enemyType) {
			case EnemyType.BasicFollowEnemy:
				sprite = hxd.Res.circle_red;
			case EnemyType.XpGain:
				sprite = hxd.Res.diamond_blue;
		}

		universe.setComponents(enemy, newPosition, new Velocity(0, 0), new Sprite(sprite, displayResources.scene, 10, 10),
			new PlayerSeeker(PlayerSeekingType.Linear, enemyData.maxSpeed, enemyData.acceleration),
			new Collidable(enemyData.collisionGroup, [CollisionGroup.Player], new PendingEffects(ColissionEffectType.Damage, enemyData.playerDamage), enemyData.collisionSize),
			new HealthContainer(enemyData.hp), new DecomposeEffects(decomposeEffects));
	}
}
