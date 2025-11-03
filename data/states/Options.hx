import deltaflixel.options.OptionText;

var list:FlxTypedGroup<OptionText> = [
	new OptionText("30 FPS", "bool", null, FlxG.save.data, "thirtyLags"),
	#if mobile
		new OptionText("[ TOUCH CONTROLS ]"),
		new OptionText("Opacity", "float", {min: 0, max: 1, step: 0.1}, FlxG.save.data, "buttonOpacity"),
		new OptionText("Color", "string", ["Monster","Determination","Integrity","Perseverance","Patience","Kindness","Justice","Bravery"], FlxG.save.data, "soul"),
	#end
];

var curSelected:Int = 0;
var soul:FlxSprite;

function create(){
	for (i=>text in list) add(text);
	soul = new FlxSprite(-150,10).loadGraphic(Paths.image('ui/soul'));
	soul.scale.set(3, 3);
	soul.updateHitbox();
	add(soul);
}

function changeSelection(number:Int = 0){
	curSelected = FlxMath.wrap(curSelected + number, 0, list.length-1);
	playSound("menu/scroll", true);
}

function update(e:Float) {
	var sel = list[curSelected];
	
	soul.x = lerp(soul.x, 10, 0.1);
	soul.y = lerp(soul.y, sel.y, 0.1);
	
	for (i=>text in list) {
		text.color = (i == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
		text.update();
		if (text.type == "int" || text.type == "float" || text.type == "string" || text.type == "bool") text.x = 74;
		else text.screenCenter(FlxAxes.X);
		text.y = 10 + (50*i);
	}
	
	if (keys.UP_P)
		changeSelection(-1);
	
	if (keys.DOWN_P)
		changeSelection(1);
	
	if (sel.type == "int" || sel.type == "float" || sel.type == "string") {
		if (keys.LEFT_P)
			sel.stepNum(-1);
		if (keys.RIGHT_P)
			sel.stepNum(1);
	}
			
	if ((keys.LEFT_P || keys.RIGHT_P) && sel.type == "bool")
		sel.swapBool();
		
	if (keys.BACK)
		FlxG.switchState(new ModState("Menu"));
}