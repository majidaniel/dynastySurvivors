package components;

import h2d.Graphics;
import hxd.res.Image;
import h2d.Scene;
import h2d.Bitmap;
import h2d.Tile;

//Indicates that an entity has a sprite representation.
class Sprite {
	public var tile:Tile;
	public var bitmap:Bitmap;
	public var graphics:Graphics;

	private var image:Image;
	private var scene:Scene;

	public function new(image:Image, scene:Scene, ?height:Float, ?width:Float) {
		this.image=image;
		this.scene=scene;
		graphics = new h2d.Graphics();
		tile = image.toTile();
		bitmap = new Bitmap(tile);
		if (height != null)
			bitmap.height = height;
		if (width != null)
			bitmap.width = width;
		graphics.addChild(bitmap);
	}

	//Convenience function so that the center of the sprite is at the indicated position
	public function setRelativePosition(x:Float, y:Float) {
		graphics.setPosition(x - bitmap.width / 2, y - bitmap.height / 2);
	}

	public function clone():Sprite{
		return new Sprite(this.image, this.scene, this.bitmap.height, this.bitmap.width);
	}
}
