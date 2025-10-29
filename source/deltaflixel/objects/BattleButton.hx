class BattleButton extends FunkinSprite
{
	public var buttonName:String = "";
	public function new(X, Y, ButtonName, Scale) {
		super(X,Y);
		scale.set(Scale,Scale);
		buttonName = ButtonName;
		updateGraphic(false);
	}
	public function updateGraphic(highlight){
		loadGraphic(Paths.image("ui/" + buttonName + (highlight ? "_h" : "")));
		updateHitbox();
	}
}