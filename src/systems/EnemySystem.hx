package systems;

import hxd.poly2tri.EdgeEvent;
import h3d.Vector;
import resources.GameState;
import ecs.Universe;
import resources.DisplayResources;
import ecs.System;
import components.*;
import Types.CollisionGroup;
import systems.XpSystem.XpGainRequest;
import game.EnemyData;
import game.LevelData;
import haxe.Constraints.Function;
import macros.*;

class EnemyCreationRequest {
	var enemyType:EnemyType;
	var startPosition:Position = null;
	var startVelocity:Vector = new Vector(0, 0);

	public function new(enemyType:EnemyType, startPosition:Position = null, startVelocity:Vector = null) {
		this.enemyType = enemyType;
		this.startPosition = startPosition;
		if (startVelocity != null)
			this.startVelocity = startVelocity;
	}
}

// System that is responsible for setting up levels & reacting to win conditions
class EnemySystem extends System {
	@:fullFamily var enemies:{
		requires:{
			playerSeeker:PlayerSeeker,
			velocity:Velocity,
			position:Position,
			threatGenerator:ThreatGenerator
		},
		resources:{state:GameState, displayResources:DisplayResources, queues:Queues}
	};

	@:fullFamily var sys:{
		requires:{},
		resources:{displayResources:DisplayResources, queues:Queues, state:GameState}
	}

	var enemyDetailsList:Map<EnemyType, EnemyData> = new std.Map();
	var levelDetails:Array<WaveSetup> = new Array();
	var uniqueSpawns:Array<WaveSetup> = new Array();
	var waveDetails:Map<WaveType, WaveData> = new Map();

	override public function new(u) {
		super(u);

		var dat:Array<Dynamic> = JsonMacro.load('res/enemies.json');
		var levelData:Array<Dynamic> = JsonMacro.load('res/levels.json');
		var waveData:Array<Dynamic> = JsonMacro.load('res/waves.json');

		for (ent in dat) {
			var enemyData = new EnemyData(ent);
			enemyDetailsList.set(enemyData.type, enemyData);
		}

		for (wave in waveData) {
			waveDetails.set(wave.waveType, new WaveData(wave));
		}

		for (waveSetup in levelData) {
			var ws = new WaveSetup(waveSetup);
			if (ws.startingThreat != null)
				levelDetails.push(ws);
			else if (ws.spawnAt != null)
				uniqueSpawns.push(ws);
		}
	}

	override function onEnabled() {
		super.onEnabled();
	}

	override function update(_dt:Float) {
		var threatOnField:Float = 0;
		setup(enemies, {
			iterate(enemies, {
				threatOnField += threatGenerator.threatLevel;
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
			state.debugMap['threatOnField'] = '$threatOnField';
			state.debugMap['threat'] = '' + state.currentThreat;
		});
		setup(sys, {
			generateEnemies(_dt, queues, state, threatOnField);

			var enemyCreationQueue = queues.getQueue(QueueType.EnemyCreationQueue);
			for (req in enemyCreationQueue) {
				if (req.startPosition == null) {
					var vector:Vector;
					/*var vector:Vector = new Vector(Math.random() - 0.5,
						Math.random() - 0.5).normalized() * Math.sqrt(Constants.screenSpaceWidth * Constants.screenSpaceWidth / 4
							+ Constants.screenSpaceHeight * Constants.screenSpaceHeight / 4);
					 */
					if (Math.random() < 0.5) {
						vector = new Vector(Math.random() < 0.5 ? 0 : Constants.screenSpaceWidth, Math.random() * Constants.screenSpaceHeight);
					} else {
						vector = new Vector(Math.random() * Constants.screenSpaceWidth, Math.random() < 0.5 ? 0 : Constants.screenSpaceHeight);
					}

					// vector = vector.add(new Vector(Constants.screenSpaceWidth / 2, Constants.screenSpaceHeight / 2));
					req.startPosition = new Position(vector.x, vector.y);
				}
				createEnemy(req.enemyType, req.startPosition, req.startVelocity, displayResources, queues);
			}
			queues.clearQueue(QueueType.EnemyCreationQueue);
		});
	}

	var enemySpawnCap:Float = 1.0;
	var enemySpawn:Float = 0;
	var enemyCount:Int = 1;

	var threatScaling:Float = 1;

	function generateEnemies(_dt:Float, queues:Queues, state:GameState, threatOnField:Float) {
		this.enemySpawn -= _dt;
		state.currentThreat = (state.initialThreat + threatScaling * state.ticksElapsed);

		// Evaluate specific spawns
		for (spawn in uniqueSpawns) {
			if (spawn.consumed)
				continue;
			if (spawn.spawnAt < state.currentThreat) {
				for (enemyDist in this.waveDetails[spawn.waveType].enemyDistribution) {
					for (i in 0...enemyDist.quantity) {
						addEnemy(enemyDist.type, queues);
					}
				}
				spawn.consumed = true;
			}
		}

		// Normal wave spawning
		if (enemySpawn < 0) {
			var curWave = this.determineCurrentWave(state);
			if (curWave == null)
				return;

			var deltaThreat = state.currentThreat - threatOnField;

			while (deltaThreat > 0) {
				var type = determineEnemyType(curWave);
				if (type == null) {
					trace("Failed to find valid enemy type");
					break;
				}
				addEnemy(type, queues);
				deltaThreat -= enemyDetailsList[type].threatPoints;
			}

			enemySpawn = enemySpawnCap;
			state.ticksElapsed++;
		}
	}

	function determineEnemyType(curWave:WaveData):EnemyType {
		var r = Math.random();
		var curSpot:Float = 0;
		for (enemy in curWave.enemyDistribution) {
			if (enemy.probability + curSpot > r) {
				return enemy.type;
			}
			curSpot += enemy.probability;
		}
		return null;
	}

	private function addEnemy(enemyType:EnemyType, queues:Queues) {
		var req = new EnemyCreationRequest(enemyType);
		queues.queue(QueueType.EnemyCreationQueue, req);
	}

	private function determineCurrentWave(state:GameState) {
		var curWave:WaveData = null;
		var tempThreat:Float = -1;
		for (waveSetup in levelDetails) {
			if (waveSetup.startingThreat < state.currentThreat && waveSetup.startingThreat > tempThreat) {
				curWave = waveDetails.get(waveSetup.waveType);
				tempThreat = waveSetup.startingThreat;
			}
		}
		return curWave;
	}

	function createEnemy(enemyType:EnemyType, position:Position, velocity:Vector, displayResources:DisplayResources, queues:Queues) {
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
			if (enemyData.spawnOdds == null || Math.random() < enemyData.spawnOdds)
				decomposeEffects.push(function() {
					var req = new EnemyCreationRequest(enemyData.spawn, newPosition);
					queues.queue(QueueType.EnemyCreationQueue, req);
				});
		}

		var sprite;
		var spriteSize:Int;
		switch (enemyType) {
			case EnemyType.BasicFollowEnemy:
				sprite = hxd.Res.circle_red;
				spriteSize = 10;
			case EnemyType.LargeFollowEnemy:
				sprite = hxd.Res.circle_red;
				spriteSize = 20;
			case EnemyType.XpGain:
				sprite = hxd.Res.diamond_blue;
				spriteSize = 10;
			case EnemyType.QuickSmallFollowEnemy:
				sprite = hxd.Res.triangle_red;
				spriteSize = 5;
			case EnemyType.LargeSpawner:
				sprite = hxd.Res.circle_red;
				spriteSize = 50;
		}

		universe.setComponents(enemy, newPosition, new Velocity(velocity.x, velocity.y), new Sprite(sprite, displayResources.scene, spriteSize, spriteSize),
			new PlayerSeeker(PlayerSeekingType.Linear, enemyData.maxSpeed * (1 + (Math.random() - 0.5) * Constants.ENEMY_MAX_SPEED_VARIANCE),
				enemyData.acceleration * (1 + (Math.random() - 0.5) * Constants.ENEMY_ACCELERATION_VARIANCE)),
			new Collidable(enemyData.collisionGroup, [CollisionGroup.Player], new PendingEffects(ColissionEffectType.Damage, enemyData.playerDamage),
				enemyData.collisionSize),
			new HealthContainer(enemyData.hp), new DecomposeEffects(decomposeEffects), new ThreatGenerator(enemyData.threatPoints));

		if (enemyData.decayTime != null) {
			universe.setComponents(enemy, new DecayOnTime(enemyData.decayTime));
		}

		if (enemyData.components != null) {
			for (component in enemyData.components) {
				if (component.type == "Spawner") {
					universe.setComponents(enemy, new EnemySpawner(component.spawnType, component.frequency, component.angles, component.velocity));
				}
			}
		}
	}
}
