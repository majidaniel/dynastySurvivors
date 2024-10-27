package components;

import haxe.Constraints.Function;

class DecomposeEffects{
    public var effects:Array<Function> = new Array();
    public function new(?effects:Array<Function>){
        if(effects != null)
            this.effects = effects;
    }
    public function addEffect(func:Function){
        effects.push(func);
    }

    public function concatEffects(decomposeEffects:DecomposeEffects){
		for(x in decomposeEffects.effects){
			this.addEffect(x);
		}
	}
}