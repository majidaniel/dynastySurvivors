package components;

// Basic x,y coordinates that an entity is currently at
class Position {
	public var vector:Vector;
	public var facing:Vector;

	public function new(x:Float = 0, y:Float = 0) {
		this.vector = new Vector(x, y);
		this.facing = new Vector(x,y).normalized();
	}

	public var x(get, set):Float;

	function get_x() {
		return vector.x;
	}

	function set_x(x) {
		if(x !=0 || this.vector.y != 0)
			this.facing = new Vector(x,this.vector.y).normalized();
		return this.vector.x = x;
	}

	public var y(get, set):Float;

	function get_y() {
		return vector.y;
	}

	function set_y(y) {
		if(y !=0 || this.vector.x != 0)
			this.facing = new Vector(this.vector.x,y).normalized();
		return this.vector.y = y;
	}

}
