package systems;

import resources.Queues.ParticlesRequest;
import h2d.Particles;
import h3d.parts.GpuParticles;
import h2d.Particles.*;

class ParticleSystem extends System {
	@:fullFamily var sys:{
		requires:{},
		resources:{displayResources:DisplayResources, queues:Queues, inputCapture:InputCapture}
	}

	override function onEnabled() {
		super.onEnabled();
		setup(sys, {
			// trace(displayResources.scene3d.camera);
		});
	}

	override function update(_dt:Float) {
		setup(sys, {
			// Disabling for now to enable other work
			// queues.clearQueue(QueueType.ParticleCreationQueue);

			var q = queues.getQueue(QueueType.ParticleCreationQueue);
			for (r in q) {
				var req:ParticlesRequest = r;
				// var particles = new h3d.parts.GpuParticles(displayResources.scene3d);
				// particles.setPosition(req.startPosition.x,req.startPosition.y,0);
				var particles = new Particles();
				displayResources.scene.addChild(particles);

				// var x = Math.random();
				var pos = new Position(req.startPosition.x, req.startPosition.y);
				particles.setPosition(pos.x, pos.y);
				// particles.setPosition(100,100);

				// var particleGroup = new h3d.parts.GpuParticles.GpuPartGroup(particles);
				var particleGroup = new ParticleGroup(particles);

				// TODO: Cone doesn't work, have to wholesale replace to get a directional version of this
				particleGroup.emitMode = req.emitMode;

				//if (req.emitMode == PartEmitMode.Cone) {
					particleGroup.emitAngle = Math.atan2(req.velocity.vector.y * -1, req.velocity.vector.x * -1);
				//}
				particleGroup.emitDist = 0;
				particleGroup.emitLoop = false;
				particleGroup.fadeIn = 0;
				particleGroup.fadeOut = 0.3;
				particleGroup.fadePower = 1;
				particleGroup.nparts = 10;
				particleGroup.texture = hxd.Res.particle_black.toTexture();
				particleGroup.size = 0.2;
				particleGroup.life = 0.5;
				particleGroup.lifeRand = 0.1;
				particleGroup.emitDelay = 0;
				particleGroup.isRelative = false;
				particleGroup.speed = 10;
				particleGroup.speedRand = 10;
				particleGroup.emitSync = 1;
				particleGroup.rotSpeed = 1;
				// particleGroup.dx = req.startPosition.x;
				// particleGroup.dy = req.startPosition.y;
				// particleGroup.dx = 200;
				// particleGroup.dy = 200;

				particles.addGroup(particleGroup);

				particles.onEnd = function() {
					// If none of the groups in this particle system are set to looping
					// this method will fire once the system is done emitting particles
					particles.remove();
				}
			}

			queues.clearQueue(QueueType.ParticleCreationQueue);
		});
	}
}
