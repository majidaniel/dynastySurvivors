package resources;

import Types.QueueType;

class Queues{
    private var queues:Map<String,Array<Dynamic>> = new Map();

    public function new(){
        initQueues();
    }

    public function initQueues(){
        queues.set(QueueType.MinionCreationQueue, new Array());
    }

    public function queue(type:QueueType, request:Dynamic){
        queues.get(type).push(request);
    }

    public function clearQueue(type:QueueType){
        queues.set(type, new Array());
    }

    public function getQueue(type:QueueType){
        return queues.get(type);
    }
}