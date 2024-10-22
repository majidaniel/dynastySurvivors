package game;

class PlayerItem{
    public var type:PlayerItemType;
    public var baseCost:Float = 0;
    public var name:String;
    public function new(type:PlayerItemType){
        this.type = type;
        switch(type){
            case PlayerItemType.MinionBoost5:
                this.baseCost=0;
                this.name = "5 free minions";
            case PlayerItemType.TowerBuilder:
                this.baseCost=5;
                this.name = "Tower Builder";
            case _:
                trace('Should probably code $type');
        }
    }
}