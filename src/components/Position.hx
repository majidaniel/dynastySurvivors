package components;

// Basic x,y coordinates that an entity is currently at
class Position {
	public var vector:Vector;

	public function new(x:Float = 0, y:Float = 0) {
		this.vector = new Vector(x, y);
	}

	public var x(get, set):Float;

	function get_x() {
		return vector.x;
	}

	function set_x(x) {
		return this.vector.x = x;
	}

	public var y(get, set):Float;

	function get_y() {
		return vector.y;
	}

	function set_y(y) {
		return this.vector.y = y;
	}

}
