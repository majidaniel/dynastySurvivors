enum abstract GameAction(Int) to Int {
	var MoveLeft;
	var MoveRight;
	var MoveUp;
	var MoveDown;
}

enum abstract CollisionGroup(Int) to Int {
	var Player;
	var Obstacles;
	var FinishSpot;
}
