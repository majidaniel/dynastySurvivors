package components;

class PendingEffect {
	public var amount:Float;
	public var type:ColissionEffectType;

	public function new(type:ColissionEffectType,amount:Float) {
		this.type=type;
		this.amount=amount;
	}
}
