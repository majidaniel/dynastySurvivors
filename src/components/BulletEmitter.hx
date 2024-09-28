package components;

class BulletEmitter {
    public var bulletType:BulletType;
    public var reloadSpeed:Float;
    public var timeToNextEmission:Float=0;
    public var targeting:BulletTargetingPriority;

    public function new(bulletType:Types.BulletType,reloadSpeed:Float,targeting:BulletTargetingPriority=BulletTargetingPriority.Closest){
        this.bulletType = bulletType;
        this.reloadSpeed = reloadSpeed;
        this.targeting = targeting;
    }
}