package resources;

//Singleton that maintains the meta game state (what level you are on, status, etc) 
//We use this as a messaging/event/command system to indicate when the level is over.  
class GameState{
    public var currentLevel:Int = null;
    public var levelComplete:Bool = null;

    public function new(){
        
    }
}