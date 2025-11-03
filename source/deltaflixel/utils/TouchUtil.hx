import flixel.FlxObject;
import flixel.input.touch.FlxTouch;

/**
 * ...
 * @author: Karim Akra
 */
 // Karim ur da best
class TouchUtil
{
	public static var pressed(get, never):Bool;
	public static var justPressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var released(get, never):Bool;
	public static var touch(get, never):FlxTouch;

	public static function overlaps(object:FlxObject, ?camera:FlxCamera)
	{
		var cam = (camera != null) ? camera : object.camera;
		for (touch in FlxG.touches.list)
			if (touch.overlaps(object, cam))
				return true;

		return false;
	}

	public static function overlapsComplex(object:FlxObject, ?camera:FlxCamera)
	{
		if (camera == null)
			for (camera in object.cameras)
				for (touch in FlxG.touches.list)
					if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
						return true;
		else
			if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
				return true;

		return false;
	}

	private static function get_pressed()
	{
		for (touch in FlxG.touches.list)
			if (touch.pressed)
				return true;

		return false;
	}

	private static function get_justPressed()
	{
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				return true;

		return false;
	}

	private static function get_justReleased()
	{
		for (touch in FlxG.touches.list)
			if (touch.justReleased)
				return true;

		return false;
	}

	private static function get_released()
	{
		for (touch in FlxG.touches.list)
			if (touch.released)
				return true;

		return false;
	}

	private static function get_touch()
	{
		for (touch in FlxG.touches.list)
			if (touch != null)
				return touch;

		return FlxG.touches.getFirst();
	}
}
