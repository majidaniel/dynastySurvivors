import game.MinionData;

@:build(macros.MinionListMacro.addMinions())
class MinionList {public var minions:Map<MinionType,MinionData>=new Map();}