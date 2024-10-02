package macros;

macro function load(path:String) {
    return try {
        var json = haxe.Json.parse(sys.io.File.getContent(path));
        macro $v{json};
    } catch (e) {
        haxe.macro.Context.error('Failed to load json: $e', haxe.macro.Context.currentPos());
    }
}