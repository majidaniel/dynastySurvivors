package resources;

import h2d.Scene;

//Singleton that maintains a reference to heaps.io screen entities
class DisplayResources {
	public var scene:Scene;

	public function new(scene:Scene) {
		this.scene = scene;
	}
}
