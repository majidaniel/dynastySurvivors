package systems;

import components.PlayerControlled;
import ecs.System;
import components.Position;
import components.Velocity;
import resources.InputCapture;
import Types.GameAction;

//System responsible for updating entity Positions based on Velocity
//Also contains logic for altering player velocity based on key input (could easily be separated into its own system)
class MoveSystem extends System {
	@:fastFamily var movables:{pos:Position, vel:Velocity};
	@:fullFamily var playerMovables:{requires:{pos:Position, vel:Velocity, playerControlled:PlayerControlled}, resources:{inputCapture:InputCapture}};

	override function update(_dt:Float) {
		iterate(movables, {
			pos.x += vel.x * _dt;
			pos.y += vel.y * _dt;
		});

		setup(playerMovables, {
			iterate(playerMovables, {
				if (inputCapture.getActionStatus(GameAction.MoveUp))
					vel.y -= playerControlled.acceleration * _dt;
				else if (inputCapture.getActionStatus(GameAction.MoveDown))
					vel.y += playerControlled.acceleration * _dt;
				else if (vel.y != 0) {
					vel.y -= playerControlled.deceleration * _dt;
					if (Math.abs(vel.y) < playerControlled.deceleration)
						vel.y = 0;
				}
				if (inputCapture.getActionStatus(GameAction.MoveLeft))
					vel.x -= playerControlled.acceleration * _dt;
				else if (inputCapture.getActionStatus(GameAction.MoveRight))
					vel.x += playerControlled.acceleration * _dt;
				else if (vel.x != 0) {
					vel.x -= playerControlled.deceleration * _dt;
					if (Math.abs(vel.x) < playerControlled.deceleration)
						vel.x = 0;
				}

				// Cap velocity to max speed grid-wise
				if(Math.abs(vel.x) > playerControlled.maxSpeed)
					vel.x = playerControlled.maxSpeed * Math.abs(vel.x) / vel.x; 
				if(Math.abs(vel.y) > playerControlled.maxSpeed)
					vel.y = playerControlled.maxSpeed * Math.abs(vel.y) / vel.y; 
				

				// Cap velocity to max speed
				if (vel.x * vel.x + vel.y * vel.y > playerControlled.maxSpeed * playerControlled.maxSpeed) {
					trace(vel.x + " : " + vel.y);
					var velX = vel.x;
					var velY = vel.y;

					if (vel.x != 0)
						velX = vel.x / ((Math.abs(vel.x) + Math.abs(vel.y)) / playerControlled.maxSpeed);
					if (vel.y != 0)
						velY = vel.y / ((Math.abs(vel.x) + Math.abs(vel.y)) / playerControlled.maxSpeed);
					
					 if(vel.x == 0 && velX != 0)
						vel.x = playerControlled.initialImpulse * playerControlled.maxSpeed * Math.abs(velX) / velX;
					 if(vel.y == 0 && velY != 0)
						vel.y = playerControlled.initialImpulse * playerControlled.maxSpeed * Math.abs(velY) / velY;
					vel.x = velX;
					vel.y = velY;
				}
			});
		});
	}
}
