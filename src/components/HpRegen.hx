package components;

class HpRegen{
    public var regenAmount:Float;
    public var regenFrequency:Float;
    public var regenTotal:Float;

    public var timeToNextRegen:Float;

    public function new(regenAmount:Float, regenFrequency:Float, regenTotal:Float=-1){
        this.regenAmount=regenAmount;
        this.regenFrequency=regenFrequency;
        this.regenTotal=-1;
        this.timeToNextRegen = regenFrequency;
    }
}