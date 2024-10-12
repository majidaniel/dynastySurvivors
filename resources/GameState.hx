package resources;

import components.HealthContainer;
import components.Position;

//Singleton that maintains the meta game state (what level you are on, status, etc) 
//We use this as a messaging/event/command system to indicate when the level is over.  
class GameState{
    public var currentLevel:Int = null;
    public var levelComplete:Bool = null;
    public var hp:HealthContainer;
    public var playerPosition:Position = null;
    public var debugMap:Map<String,String> = new Map();

    public var xp:Float = 0;
    public var canPlayerTakeAction:Bool=false;

    public function new(){
        
    }
}