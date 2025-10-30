import funkin.menus.ModSwitchMenu;

var stuff:Array<String> = [
	"Yes",
	"No",
];
var curSelected:Int = 0; //bart simpson
var canPress:Bool = true;

var stuffGroup:FlxTypedGroup<FlxSprite> = [];
var soul:FlxSprite;

var confirmSound:FlxSound = FlxG.sound.load(Paths.sound("menu/confirm"));
var scrollSound:FlxSound = FlxG.sound.load(Paths.sound("menu/scroll"));
var cancelSound:FlxSound = FlxG.sound.load(Paths.sound("menu/cancel"));
var goner:FlxSound = FlxG.sound.load(Paths.sound("goner_drone"));
goner.looped = true;
goner.play();

var tileset:FlxSrpite = new FlxSprite().loadGraphic(Paths.image("castle"),40,40);
tileset.scale.set(1,1);
tileset.updateHitbox();
var tiles:Array<Dynamic> = [
	{
		tilesetX: 0,
		tilesetY: 0,
		x: 0,
		y: 0
	},
	{
		tilesetX: 1,
		tilesetY: 1,
		x: 0,
		y: 1
	},
];
function create(){
	FlxG.camera.y = -100;
	FlxG.camera.flashSprite.scaleX = 0.1;
	FlxG.camera.alpha = 0;
	FlxTween.tween(FlxG.camera.flashSprite, {scaleX: 1}, 0.5, { ease: FlxEase.quadOut });
	FlxTween.tween(FlxG.camera, {y: 0, alpha: 1}, 0.5, { ease: FlxEase.quadOut });
	var warn = new FlxText(0, 200).setFormat(Paths.font("determination.ttf"), 48, FlxColor.WHITE, "center");
	warn.text = "This engine is very work in progress.\nAre you sure you want to PROCEED?";
	warn.screenCenter(FlxAxes.X);
	add(warn);
	for (i in 0...stuff.length)
	{
		var text = new FlxText(125, (64 * i) + (FlxG.height / 2)).setFormat(Paths.font("determination.ttf"), 48, FlxColor.WHITE, "left");
		text.text = stuff[i];
		text.screenCenter(FlxAxes.X);
		stuffGroup.push(text);
		add(text);
	}
	soul = new FlxSprite(-150,30).loadGraphic(Paths.image('ui/soul'));
	soul.scale.set(3, 3);
	soul.updateHitbox();
	add(soul);
}

function changeSelection(number:Int = 0){
	curSelected = FlxMath.wrap(curSelected + number, 0, stuff.length-1);
	scrollSound.play(true);
}

function update(e:Float) {
	soul.x = lerp(soul.x, stuffGroup[curSelected].x-64, 0.1);
	soul.y = lerp(soul.y, stuffGroup[curSelected].y, 0.1);
	for (i in 0...stuffGroup.length)
		stuffGroup[i].color = (i == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
	if (canPress) {
		if (controls.UP_P)
			changeSelection(-1);
		
		if (controls.DOWN_P)
			changeSelection(1);
			
		if (controls.ACCEPT) {
			confirmSound.play(true);
			switch (stuff[curSelected]) {
				case "Yes":
					canPress = false;
					FlxTween.tween(FlxG.camera, {y: -100, alpha: 0}, 0.5, { ease: FlxEase.quadOut });
					FlxTween.tween(FlxG.camera.flashSprite, {scaleX: 0.001}, 0.5, { ease: FlxEase.quadOut });
					new FlxTimer().start(0.5, function(tmr){
						FlxG.switchState(new ModState("Intro"));
					});
				case "No":
					persistentUpdate = !(persistentDraw = true);
					openSubState(new ModSwitchMenu());
			}
		}
	}
}

#if mobile
	addTouchPad("UP_DOWN", "A");
	addTouchPadCamera();
#end