package systems;

import components.PlayerControlled;
import ecs.System;
import components.Position;
import components.Velocity;
import resources.InputCapture;
import Types.GameAction;

// System responsible for updating entity Positions based on Velocity
// Also contains logic for altering player velocity based on key input (could easily be separated into its own system)
class MoveSystem extends System {
	@:fastFamily var movables:{pos:Position, vel:Velocity};
	@:fullFamily var playerMovables:{requires:{pos:Position, vel:Velocity, playerControlled:PlayerControlled}, resources:{inputCapture:InputCapture, state:GameState}};

	override function onEnabled() {
		super.onEnabled();
		movables.onEntityRemoved.subscribe(entity -> {
			setup(movables, {
				// trace("movable removed");
			});
		});
	}

	override function update(_dt:Float) {
		iterate(movables, {
			pos.x += vel.vector.x * _dt;
			pos.y += vel.vector.y * _dt;
		});

		setup(playerMovables, {
			iterate(playerMovables, {
				var padInput = false;
				if (inputCapture.pad != null) {
					state.debugMap['PadInputs'] = inputCapture.pad.xAxis + ' : ' + inputCapture.pad.yAxis;
					if (Math.abs(inputCapture.pad.xAxis) > inputCapture.pad.axisDeadZone*2 || Math.abs(inputCapture.pad.yAxis) > inputCapture.pad.axisDeadZone * 2) {
						var dir:Vector = new Vector(inputCapture.pad.xAxis, inputCapture.pad.yAxis).normalized();
						//state.debugMap['Inputs'] = '$dir.x : $dir.y';
						vel.vector.x += dir.x * playerControlled.acceleration * _dt;
						vel.vector.y += dir.y * playerControlled.acceleration * _dt;
						padInput = true;
					}
				}

				if (inputCapture.getActionStatus(GameAction.MoveUp))
					vel.vector.y -= playerControlled.acceleration * _dt;
				else if (inputCapture.getActionStatus(GameAction.MoveDown))
					vel.vector.y += playerControlled.acceleration * _dt;
				else if (vel.vector.y != 0 && !padInput) {
					vel.vector.y -= playerControlled.deceleration * _dt;
					if (Math.abs(vel.vector.y) < playerControlled.deceleration)
						vel.vector.y = 0;
				}
				if (inputCapture.getActionStatus(GameAction.MoveLeft))
					vel.vector.x -= playerControlled.acceleration * _dt;
				else if (inputCapture.getActionStatus(GameAction.MoveRight))
					vel.vector.x += playerControlled.acceleration * _dt;
				else if (vel.vector.x != 0 && !padInput) {
					vel.vector.x -= playerControlled.deceleration * _dt;
					if (Math.abs(vel.vector.x) < playerControlled.deceleration)
						vel.vector.x = 0;
				}

				// Cap velocity to max speed grid-wise
				if (Math.abs(vel.vector.x) > playerControlled.maxSpeed)
					vel.vector.x = playerControlled.maxSpeed * Math.abs(vel.vector.x) / vel.vector.x;
				if (Math.abs(vel.vector.y) > playerControlled.maxSpeed)
					vel.vector.y = playerControlled.maxSpeed * Math.abs(vel.vector.y) / vel.vector.y;

				// Cap velocity to max speed
				if (vel.vector.x * vel.vector.x + vel.vector.y * vel.vector.y > playerControlled.maxSpeed * playerControlled.maxSpeed) {
					var velX = vel.vector.x;
					var velY = vel.vector.y;

					if (vel.vector.x != 0)
						velX = vel.vector.x / ((Math.abs(vel.vector.x) + Math.abs(vel.vector.y)) / playerControlled.maxSpeed);
					if (vel.vector.y != 0)
						velY = vel.vector.y / ((Math.abs(vel.vector.x) + Math.abs(vel.vector.y)) / playerControlled.maxSpeed);

					if (vel.vector.x == 0 && velX != 0)
						vel.vector.x = playerControlled.initialImpulse * playerControlled.maxSpeed * Math.abs(velX) / velX;
					if (vel.vector.y == 0 && velY != 0)
						vel.vector.y = playerControlled.initialImpulse * playerControlled.maxSpeed * Math.abs(velY) / velY;
					vel.vector.x = velX;
					vel.vector.y = velY;
				}
			});
		});
	}
}
