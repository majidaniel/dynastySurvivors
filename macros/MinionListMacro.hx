package macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import Sys;
import haxe.io.Path;
import Types.MinionType;
import game.MinionData;

class MinionListMacro {
	public static function addMinions() {
		try {
			var json:Array<Dynamic> = haxe.Json.parse(sys.io.File.getContent("res/minions.json"));
            var fields:Array<Field> = Context.getBuildFields();
            var minions:Map<MinionType,MinionData>=new Map();
            var mD:MinionData;

            var map : Array<Expr> = [];

            for(entry in json){
                var type = MinionType.BasicShooter;
                var minionData:MinionData = new MinionData(entry.reloadSpeed);
                minions.set(type,minionData);
                mD=minionData;

                map.push(macro $v{type} => $v{minionData});
            };

            var clz = Context.toComplexType(Context.getType("game.MinionData"));

            fields.push({
                name: "data",
                doc: 'Minion data',
                access: [Access.APublic, Access.AStatic, Access.AInline],
                pos: Context.currentPos(),
                kind: FieldType.FVar(macro: Map<MinionType,MinionData>, macro $v{minions})
            });
			return fields;
		} catch (e) {
			return haxe.macro.Context.error('Failed to load json: $e', haxe.macro.Context.currentPos());
		}
	}
}
