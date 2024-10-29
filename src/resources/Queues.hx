package resources;

import h2d.Particles.PartEmitMode;
import haxe.Constraints.Function;
import ecs.Entity;
import Types.QueueType;

typedef MinionDeletionRequest = {var minionType:MinionType; var quantity:Int;}
typedef HpEffectRequest = {public var entity:Entity; public var amount:Float;}
typedef StatusEffectRequest = {public var entity:Entity; public var statusEffect:StatusEffect;}
typedef ParticlesRequest = {var startPosition:Position; var quantity:Float; var velocity:Velocity; var emitMode:PartEmitMode;}
typedef GameActionRequest = {var action:GameAction;}

class Queues {
	private var queues:Map<String, Array<Dynamic>> = new Map();

	public function new() {
		initQueues();
	}

	public function initQueues() {
		queues.set(QueueType.MinionCreationQueue, new Array());
		queues.set(QueueType.XpQueue, new Array());
		queues.set(QueueType.EnemyCreationQueue, new Array());
		queues.set(QueueType.ParticleCreationQueue, new Array());
		queues.set(QueueType.MinionDestructionQueue, new Array());
		queues.set(QueueType.HpEffectQueue, new Array());
		queues.set(QueueType.StatusEffectQueue, new Array());
		queues.set(QueueType.GameActionQueue, new Array());
	}

	public function queue(type:QueueType, request:Dynamic) {
		queues.get(type).push(request);
	}

	public function clearQueue(type:QueueType) {
		queues.set(type, new Array());
	}

	public function getQueue(type:QueueType):Array<Dynamic> {
		return queues.get(type);
	}

	public function queueMinionDeletionRequest(minionType:MinionType, quantity:Int) {
		var req:MinionDeletionRequest = {minionType: minionType, quantity: quantity};
		this.queue(QueueType.MinionDestructionQueue, req);
	}

	public function queueHpEffect(entity:Entity, hpAmount:Float) {
		var req:HpEffectRequest = {entity: entity, amount: hpAmount};
		this.queue(QueueType.HpEffectQueue, req);
	}

	public function queueStatusEffect(entity:Entity, statusEffect:StatusEffect){
		var req:StatusEffectRequest = {entity:entity, statusEffect:statusEffect};
		this.queue(QueueType.StatusEffectQueue,req);
	}

	public function queueGameAction(action:GameAction){
		var req:GameActionRequest = {action: action};
		this.queue(QueueType.GameActionQueue, req);
	}
}
