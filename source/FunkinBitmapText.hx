import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;

class FunkinBitmapText extends FlxBitmapText {
	public var size(get, set):Int;
    public function new(X:Float = 0, Y:Float = 0, Graphic:String, Used:String, ?PointX:Float, ?PointY:Float, ?Text:String, ?Size:Float = 1) {
		super(X,Y,Text);
		var pX:Int = (PointX == null) ? (Assets.getBitmapData(Paths.image(Graphic)).width / Used.length) : PointX;
		var pY:Int = (PointY == null) ? Assets.getBitmapData(Paths.image(Graphic)).height : PointY;
        var setUp = FlxBitmapFont.fromMonospace(Assets.getBitmapData(Paths.font(Graphic), true, false), Used, FlxPoint.weak(pX, pY));
        font = setUp;
        size = Size;
    }

	public function setFormat(Size:Int = 8, Color:FlxColor = FlxColor.WHITE, ?Alignment:FlxTextAlign){
		size = Size;
		color = Color;
		if (Alignment != null) alignment = Alignment;
		return this;
	}

	function set_size(Size:Int){
		scale.set(Size, Size);
        updateHitbox();
		return Size;
	}

}