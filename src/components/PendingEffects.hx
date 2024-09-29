package components;

typedef PendingEffect = {
	public var amount:Float;
	public var type:ColissionEffectType;
}

class PendingEffects {
	public var pendingEffects = new Array<PendingEffect>();

	public function new(type:ColissionEffectType=null, amount:Float=null) {
		if(type != null)
			this.addEffect(type, amount);
	}

	public function addEffect(type:ColissionEffectType, amount:Float) {
		this.pendingEffects.push({type: type, amount: amount});
	}

	public function concatEffects(pendingEffects:PendingEffects){
		for(x in pendingEffects.pendingEffects){
			this.addEffect(x.type,x.amount);
		}
	}
}
