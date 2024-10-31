package game;

class PlayerItem {
	public var type:PlayerItemType;
	public var baseCost:Int = 0;
	public var name:String;

	public function new(type:PlayerItemType) {
		this.type = type;
		switch (type) {
			case PlayerItemType.MinionBoost5:
				this.baseCost = 0;
				this.name = "5 free minions";
			case PlayerItemType.MinionBoost10:
				this.baseCost = 0;
				this.name = "10 free minions";
			case PlayerItemType.TowerBuilder:
				this.baseCost = 5;
				this.name = "Tower Builder";
			case PlayerItemType.BombImbuer:
				this.baseCost = 0;
				this.name = "Bomb imbuer";
			case PlayerItemType.TankArmor:
				this.baseCost = 5;
				this.name = "Tank armor";
			case _:
				trace('Should probably code $type');
		}
	}
}
