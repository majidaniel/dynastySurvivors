package components;

class HealthContainer{
    public var initialHpAmount:Float;
    public var hpAmount:Float;
    public function new(hpAmount:Float){
        this.initialHpAmount = hpAmount;
        this.hpAmount=hpAmount;
    }
}