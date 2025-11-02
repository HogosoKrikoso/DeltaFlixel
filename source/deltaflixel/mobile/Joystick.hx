import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class Joystick extends FlxSprite
{
	var center:FlxPoint = FlxPoint.get();
	var thumb:FlxSprite;
	var base:FlxSprite;
	public var stick:FlxPoint = FlxPoint.get();
	public var deadzone:Float = 0.2;
	public var radius:Float = 1280.0;
	var button:FlxSprite;
	var dragging = false;
	var initialized = false;
	
	public var UP = false;
	public var UP_P = false;
	public var DOWN = false;
	public var DOWN_P = false;
	public var LEFT = false;
	public var LEFT_P = false;
	public var RIGHT = false;
	public var RIGHT_P = false;
	
	public function new(x = 0.0, y = 0.0, radius = 1280.0, ?baseGraphic:String, ?thumbGraphic:String)
	{
		super(x, y);
		base = new FlxSprite().loadGraphic(Paths.image(baseGraphic));
		thumb = new FlxSprite().loadGraphic(Paths.image(thumbGraphic));
		button = new FlxSprite().makeGraphic(1,1,FlxColor.TRANSPARENT);
		radius = radius;
	}
	
	public function startJoystick() {
		FlxG.state.add(base);
		FlxG.state.add(thumb);
		FlxG.state.add(button);
		initialized = true;
	}
	
	public function stopJoystick() {
		FlxG.state.add(base);
		FlxG.state.add(thumb);
		FlxG.state.add(button);
		initialized = false;
	}
	
	public function update(?elapsed)
	{
		if (initialized) {
			
			// funny setup
			for (spr in [base, thumb, button]) {
				spr.alpha = alpha;
				spr.visible = visible;
				spr.cameras = cameras;
				spr.camera = camera;
				spr.color = color;
			}
			thumb.scale.set(scale.x/2, scale.y/2);
			thumb.offset.set(thumb.width/2, thumb.width/2);
			base.x = x;
			base.y = y;
			base.scale.set(scale.x, scale.y);
			base.updateHitbox();
			
			// centerrrrrrrrr
			center.x = base.x + (base.width/2);
			center.y = base.y + (base.height/2);
			
			// radius
			button.scale.set(radius, radius);
			button.updateHitbox();
			button.x = center.x - (radius/1.5);
			button.y = center.y - (radius/2.5);
			
			// cool update
			mousePos = FlxG.mouse.getScreenPosition(camera);
			if (dragging) {
				thumb.x = FlxMath.bound(mousePos.x, base.x, base.x+base.width);
				thumb.y = FlxMath.bound(mousePos.y, base.y, base.y+base.height);
				stick.x = (thumb.x - center.x) / base.width;
				stick.y = (thumb.y - center.y) / base.height;
				if (!FlxG.mouse.pressed || !FlxG.mouse.overlaps(button, camera)) dragging = false;
			} else {
				thumb.x = center.x;
				thumb.y = center.y;
				stick.x = stick.y = 0;
				if (FlxG.mouse.overlaps(button, camera) && FlxG.mouse.pressed) dragging = true;
			}
			
			// stupid key spaghetti code
			if (!UP) {
				if (stick.y < -deadzone) {
					UP_P = true;
					UP = true;
				}
			} else {
				if (UP_P) UP_P = false;
				if (stick.y > -deadzone) {
					UP = false;
				}
			}
			if (!DOWN) {
				if (stick.y > deadzone) {
					DOWN_P = true;
					DOWN = true;
				}
			} else {
				if (DOWN_P) DOWN_P = false;
				if (stick.y < deadzone) {
					DOWN = false;
				}
			}
			if (!LEFT) {
				if (stick.x < -deadzone) {
					LEFT_P = true;
					LEFT = true;
				}
			} else {
				if (LEFT_P) LEFT_P = false;
				if (stick.x > -deadzone) {
					LEFT = false;
				}
			}
			if (!RIGHT) {
				if (stick.x > deadzone) {
					RIGHT_P = true;
					RIGHT = true;
				}
			} else {
				if (RIGHT_P) RIGHT_P = false;
				if (stick.x < deadzone) {
					RIGHT = false;
				}
			}
		}
	}
}
