package resources;

import h2d.Scene;

//Singleton that maintains a reference to heaps.io screen entities
class DisplayResources {
	public var scene:Scene;
	public var scene3d:h3d.scene.Scene;
	public function new(scene:Scene, scene3d:h3d.scene.Scene) {
		this.scene = scene;
		this.scene3d=scene3d;
	}
}
