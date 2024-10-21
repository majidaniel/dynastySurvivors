import h3d.Engine;
import hxd.Timer;
import haxe.macro.Expr.Constant;
import hxd.fmt.grd.Data.GradientStop;
import resources.*;
import ecs.Universe;
import systems.*;

// Haxe Entry point
class Main extends hxd.App {
	var universe:Universe;
	var screenSpaceWidth = Constants.screenSpaceWidth;
	var screenSpaceHeight = Constants.screenSpaceHeight;

	override function init() {
		// Initializes "res" folder
		hxd.Res.initEmbed();
		engine.backgroundColor = 0xffffff;
		s2d.scaleMode = LetterBox(screenSpaceWidth, screenSpaceHeight, false);
		
		// ECS library, creates a collection of systems that we'll use later to run
		universe = Universe.create({
			entities: 1000000,
			phases: [
				{
					name: 'game-manager',
					systems: [GameSystem],
					enabled: false
				},
				{
					name: 'game-logic',
					systems: [

						XpSystem,
						EnemySystem,
						MinionSystem,
						FieldComponentSystem,
						BulletSystem,
						MoveSystem,
						DecaySystem,
						CollisionDetectionSystem,
						CollisionResolutionSystem,
						DecompositionSystem
					],
					enabled: false
				},
				{
					name: 'rendering',
					systems: [RenderSystem,ParticleSystem, UserInterfaceSystem],
					enabled: false
				}
			]
		});

		// Setup resources (aka Singletons) for use in ECS retrieval
		var displayResources = new DisplayResources(s2d,s3d);
		var inputCapturer = new InputCapture();
		var gameState = new GameState();
		var queues = new Queues();
		universe.setResources(displayResources, inputCapturer, gameState, queues);

		universe.getPhase('rendering').enable();
		universe.getPhase('game-manager').enable();
	}

	// Runs every frame via heaps.io
	override function update(dt:Float) {
		// var t1:Float = haxe.Timer.stamp();
		// universe.update(dt);
		universe.getPhase('game-manager').update(dt);
		
		universe.getPhase('game-logic').update(dt);

		// var t2 = haxe.Timer.stamp();
		universe.getPhase('rendering').update(dt);
		// var t3 = haxe.Timer.stamp();
		// trace((t2-t1) + ", " + (t3-t2));
	}

	override function render(e:Engine) {
		s3d.render(e);
		s2d.render(e);
	}

	// Default haxe entry function
	static function main() {
		new Main();
	}
}
