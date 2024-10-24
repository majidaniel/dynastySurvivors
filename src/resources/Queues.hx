package resources;

import Types.QueueType;

typedef MinionDeletionRequest = {var minionType:MinionType; var quantity:Int;}


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
		queues.set(QueueType.MinionDestructionQueue,new Array());
	}

	public function queue(type:QueueType, request:Dynamic) {
		queues.get(type).push(request);
	}

	public function clearQueue(type:QueueType) {
		queues.set(type, new Array());
	}

	public function getQueue(type:QueueType) {
		return queues.get(type);
	}

	public function queueMinionDeletionRequest( minionType:MinionType, quantity:Int){
		var req:MinionDeletionRequest = {minionType: minionType, quantity: quantity};
		this.queue(QueueType.MinionDestructionQueue,req);
	}
}