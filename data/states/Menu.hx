import funkin.menus.ModSwitchMenu;
import flixel.text.FlxTextBorderStyle;
import funkin.options.TreeMenu;

var stuff:Array<String> = [
	"Battle",
	"World",
	"Options",
	"Back To Codename",
];
var curSelected:Int = 0; //bart simpson
var canPress:Bool = true;

var stuffGroup:FlxTypedGroup<FlxSprite> = [];
var soul:FlxSprite;

function create(){
	FlxG.camera.scroll.y = -100;
	FlxG.camera.flash(FlxColor.BLACK, 1);
	FlxTween.tween(FlxG.camera.scroll, {y: 0}, 1, { ease: FlxEase.quadOut });
	background = new FlxSprite(0,-80).loadGraphic(Paths.image("menus/title_bg_full"));
	background.scale.set(4,4);
	background.updateHitbox();
	add(background);
	logo = new FlxSprite().loadGraphic(Paths.image('logo'));
	logo.scale.set(1, 1);
	logo.updateHitbox();
	logo.screenCenter().y -= 300;
	add(logo);
	for (i in 0...stuff.length)
	{
		var text = new FlxText(125, (64 * i) + (FlxG.height / 2)).setFormat(Paths.font("determination.ttf"), 48, FlxColor.WHITE, "left", FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
		text.borderSize = 5;
		text.text = stuff[i];
		text.screenCenter(FlxAxes.X);
		stuffGroup.push(text);
		add(text);
	}
	soul = new FlxSprite(-150,30).loadGraphic(Paths.image('ui/soul'));
	soul.scale.set(3, 3);
	soul.updateHitbox();
	add(soul);
	playMusic("quiet_church", 1, true);
}

function changeSelection(number:Int = 0){
	curSelected = FlxMath.wrap(curSelected + number, 0, stuff.length-1);
	playSound("menu/scroll", true);
}

function update(e:Float) {
	soul.x = lerp(soul.x, stuffGroup[curSelected].x-64, 0.1);
	soul.y = lerp(soul.y, stuffGroup[curSelected].y, 0.1);
	for (i in 0...stuffGroup.length)
		stuffGroup[i].color = (i == curSelected) ? FlxColor.WHITE : FlxColor.GRAY;
	if (canPress) {
		if (keys.UP_P)
			changeSelection(-1);
		
		if (keys.DOWN_P)
			changeSelection(1);
			
		if (keys.ACCEPT) {
			playSound("menu/confirm", true);
			switch (stuff[curSelected]) {
				case "Battle":
					canPress = false;
					FlxG.sound.music.stop();
					FlxG.switchState(new ModState("BattleState"));
				case "World":
					canPress = false;
					FlxG.sound.music.stop();
					FlxG.switchState(new ModState("World"));
				case "Options":
					canPress = false;
					FlxG.switchState(new TreeMenu(() -> {}, true, "hola"));
				case "Back To Codename":
					persistentUpdate = !(persistentDraw = true);
					openSubState(new ModSwitchMenu());
			}
		}
	}
}