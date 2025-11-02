class FightBox
{
	public var x = 0;
	public var y = 0;
	public var alpha:Float = 0;
	public var visible = true;
	public var accuracy = 0;
	public var canUpdate = false;
	public var canPress = false;
	public var pressed = false;
	public var icon:FlxSprite;
	public var box:FlxSprite;
	public var bar:FlxSprite;
	public var barAlpha:Float = 1;
	public function new(xPos, yPos, character)
	{
		x = xPos;
		y = yPos;
		icon = new FlxSprite().loadGraphic(Paths.image('ui/battle/icons/' + character.icon));
		icon.cameras = [camUI];
		icon.scale.set(2.5,2.5);
		icon.updateHitbox();
		box = new FlxSprite().loadGraphic(Paths.image('ui/battle/boxFight'));
		box.cameras = [camUI];
		box.color = character.color;
		bar = new FlxSprite().makeGraphic(18, 76,FlxColor.WHITE);
		bar.cameras = [camUI];
	}
	
	public function resetX()
		bar.offset.x = 0;
		
	public function update(keyPress)
	{
		icon.alpha = box.alpha = alpha;
		bar.alpha = alpha*barAlpha;
		icon.visible = box.visible = bar.visible = visible;
		icon.setPosition(x,y);
		box.setPosition(x+100,y);
		bar.setPosition(box.x+box.width,y+4);
		if (canUpdate) {
			accuracy = reverseMin(bar.offset.x/box.width, 1);
			if (keyPress && bar.offset.x >= 50 && canPress && !pressed)
				pressed = true;
			if (bar.offset.x >= (box.width+75)) {
				accuracy = 0;
				pressed = true;
				canUpdate = false;
				canPress = false;
			}
			if (pressed) {
				if (barAlpha > 0)
					barAlpha -= 0.1;
				bar.scale.x += 0.1;
				bar.scale.y += 0.1;
			}else{
				bar.offset.x += 300 / getFPS();
				barAlpha = 1;
				bar.scale.set(1,1);
			}
		}
	}
}