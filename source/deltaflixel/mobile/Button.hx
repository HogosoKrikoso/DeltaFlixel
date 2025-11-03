import deltaflixel.mobile.TouchUtil;

class Button extends FlxSprite
{
	public var justPressed = false;
	public var pressed = false;
	public var justReleased = false;
	public var buttonColor:FlxColor = FlxColor.WHITE;
	
	public function new(x = 0.0, y = 0.0, ?graphic:String, ?color:FlxColor)
	{
		super(x, y);
		loadGraphic(Paths.image(graphic));
		if (color != null) buttonColor = color;
	}
	
	public function update(?elapsed)
	{
		if (pressed) {
			if(justPressed) justPressed = false;
			if (!TouchUtil.pressed || !TouchUtil.overlaps(this)) {
				pressed = false;
				justReleased = true;
			}
			color = FlxColor.YELLOW;
		} else {
			if(justReleased) justPressed = false;
			if (TouchUtil.overlaps(this) && TouchUtil.pressed) {
				justPressed = true;
				pressed = true;
			}
			color = buttonColor;
		}
	}
}