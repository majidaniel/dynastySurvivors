package components;

class BulletEmitter {
    public var bulletType:BulletType;
    public var reloadSpeed:Float;
    public var timeToNextEmission:Float=0;
    public var targeting:BulletTargetingPriority;
    public var maximumShots:Float;
    public var shotsRemaining:Float;

    public function new(bulletType:Types.BulletType,reloadSpeed:Float,targeting:BulletTargetingPriority=BulletTargetingPriority.Closest,maximumShots:Int=null){
        this.bulletType = bulletType;
        this.reloadSpeed = reloadSpeed;
        this.targeting = targeting;
        this.maximumShots = maximumShots;
        this.shotsRemaining = maximumShots;
    }
}