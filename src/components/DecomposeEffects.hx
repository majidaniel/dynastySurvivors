package components;

import haxe.Constraints.Function;

class DecomposeEffects{
    public var effects:Array<Function> = new Array();
    public function new(effects:Array<Function>){
        this.effects = effects;
    }
}