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
					name: 'game-logic',
					systems: [
						GameSystem,
						XpSystem,
						EnemySystem,
						MinionSystem,
						BulletSystem,
						MoveSystem,
						DecaySystem,
						CollisionDetectionSystem,
						CollisionResolutionSystem,
						DecompositionSystem
					]
				},
				{
					name: 'rendering',
					systems: [RenderSystem, UserInterfaceSystem]
				}
			]
		});

		// Setup resources (aka Singletons) for use in ECS retrieval
		var displayResources = new DisplayResources(s2d);
		var inputCapturer = new InputCapture();
		var gameState = new GameState();
		var queues = new Queues();
		universe.setResources(displayResources, inputCapturer, gameState,queues);
	}

	// Runs every frame via heaps.io
	override function update(dt:Float) {
		//var t1:Float = haxe.Timer.stamp();
		//universe.update(dt);
		universe.getPhase('game-logic').update(dt);

		//var t2 = haxe.Timer.stamp();
		universe.getPhase('rendering').update(dt);
		//var t3 = haxe.Timer.stamp();
		//trace((t2-t1) + ", " + (t3-t2));
	}

	// Default haxe entry function
	static function main() {
		new Main();
	}
}
