import funkin.backend.utils.ShaderResizeFix;
import funkin.options.Options;
import funkin.backend.system.framerate.Framerate;
import openfl.text.TextFormat;
import deltaflixel.mobile.Joystick;
import deltaflixel.mobile.Button;
import openfl.system.Capabilities;

var redirectStates:Map<FlxState, String> = [
	//BetaWarningState => "Play",
	TitleState => "Play",
];

public static var keys:Dynamic = {
	UP: false,
	DOWN: false,
	LEFT: false,
	RIGHT: false,
	UP_P: false,
	DOWN_P: false,
	LEFT_P: false,
	RIGHT_P: false,
	ACCEPT: false,
	ACCEPT_HOLD: false,
	BACK: false,
	BACK_HOLD: false,
	MENU: false,
	MENU_HOLD: false,
};

var defaultSettings = [
	"thirtyLags" => false,
	"buttonOpacity" => 0.5,
	"soul" => "Monster",
];

function new() {
	for (key in defaultSettings.keys()) if (!Reflect.hasField(FlxG.save.data, key))
		Reflect.setField(FlxG.save.data, key, defaultSettings[key]);
	setGameResolution(1280, 960, false);
}

function preStateSwitch() {
    for (redirectState in redirectStates.keys())
        if (FlxG.game._requestedState is redirectState)
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}

var joystick:Joystick;
var acceptButton:Button;
var backButton:Button;
var menuButton:Button;
public static var mobileCam:FlxCamera;
function postStateSwitch() {
	#if mobile
		mobileCam = new FlxCamera();
	    FlxG.cameras.add(mobileCam, false).bgColor = 0;
		joystick = new Joystick(100, 500, 1280, "ui/mobile/joystick", "ui/mobile/joystick");
		joystick.scale.set(2,2);
		acceptButton = new Button(FlxG.width - 400, 700, "ui/mobile/z");
		backButton = new Button(FlxG.width - 300, 500, "ui/mobile/x");
		menuButton = new Button(FlxG.width - 200, 700, "ui/mobile/c");
	    joystick.startJoystick();
		joystick.camera = mobileCam;
	    for (btn in [acceptButton, backButton, menuButton]) FlxG.state.add(btn).camera = mobileCam;
    #end
    Framerate.codenameBuildField.visible = Framerate.memoryCounter.memoryPeakText.visible = Framerate.memoryCounter.memoryText.visible = false;
	Framerate.fpsCounter.fpsNum.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('PixelOperator-Bold.ttf')), 40, FlxColor.WHITE);
	Framerate.fpsCounter.fpsLabel.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('PixelOperator-Bold.ttf')), 40, FlxColor.WHITE);
}

function update() {
	#if mobile
		for (btn in [acceptButton, backButton, menuButton, joystick]) {
			btn.update();
			btn.alpha = FlxG.save.data.buttonOpacity;
			btn.color = switch (FlxG.save.data.soul) {
				case "Monster": FlxColor.WHITE;
				case "Determination": FlxColor.RED;
				case "Integrity": FlxColor.BLUE;
				case "Perseverance": FlxColor.PURPLE;
				case "Patience": FlxColor.CYAN;
				case "Kindness": FlxColor.GREEN;
				case "Justice": FlxColor.YELLOW;
				case "Bravery": FlxColor.ORANGE;
			}
			if (btn != joystick) btn.buttonColor = btn.color;
		}
		keys.UP = joystick.UP;
		keys.DOWN = joystick.DOWN;
		keys.LEFT = joystick.LEFT;
		keys.RIGHT = joystick.RIGHT;
		keys.UP_P = joystick.UP_P;
		keys.DOWN_P = joystick.DOWN_P;
		keys.LEFT_P = joystick.LEFT_P;
		keys.RIGHT_P = joystick.RIGHT_P;
		keys.ACCEPT = acceptButton.justPressed;
		keys.ACCEPT_HOLD = acceptButton.pressed;
		keys.BACK = backButton.justPressed;
		keys.BACK_HOLD = backButton.pressed;
		keys.MENU = menuButton.justPressed;
		keys.MENU_HOLD = menuButton.pressed;
	#else
		keys.UP = controls.UP;
		keys.DOWN = controls.DOWN;
		keys.LEFT = controls.LEFT;
		keys.RIGHT = controls.RIGHT;
		keys.UP_P = controls.UP_P;
		keys.DOWN_P = controls.DOWN_P;
		keys.LEFT_P = controls.LEFT_P;
		keys.RIGHT_P = controls.RIGHT_P;
		keys.ACCEPT = FlxG.keys.justPressed.Z;
		keys.ACCEPT_HOLD = FlxG.keys.pressed.Z;
		keys.BACK = FlxG.keys.justPressed.X;
		keys.BACK_HOLD = FlxG.keys.pressed.X;
		keys.MENU = FlxG.keys.justPressed.X;
		keys.MENU_HOLD = FlxG.keys.pressed.X;
	#end
	FlxG.updateFramerate = FlxG.drawFramerate = FlxG.save.data.thirtyLags ? 30 : 60;
}

function destroy() {
	#if mobile
		joystick.stopJoystick();
		for (btn in [acceptButton, backButton, menuButton, joystick]) btn.destroy();
	#end
	FlxG.updateFramerate = FlxG.drawFramerate = Options.framerate;
	setGameResolution(1280, 720);
}

function setGameResolution(realWidth:Int, realHeight:Int, ?keepQuality:Bool = false){
	var scale:Float = keepQuality ? Math.max(realWidth/1280, realHeight/720) : 1;
	var width:Int = Math.floor(realWidth/scale);
	var height:Int = Math.floor(realHeight/scale);
    FlxG.resizeWindow(width, height);
    FlxG.resizeGame(width, height);
    FlxG.scaleMode.width = FlxG.width = FlxG.initialWidth = width;
    FlxG.scaleMode.height = FlxG.height = FlxG.initialHeight = height;
    ShaderResizeFix.doResizeFix = true;
    ShaderResizeFix.fixSpritesShadersSizes();
}

// utils

public static function playSound(path, ?force:Bool = false) {
	var sound = FlxG.sound.load(Paths.sound(path));
	sound.play(force);
}

var musicID:String = "";
public static function playMusic(path, ?volume:Float = 1, ?loop:Bool = false, ?force:Bool = false) if (musicID != path || force) {
	if (FlxG.sound.music != null) FlxG.sound.music.stop();
	FlxG.sound.playMusic(Paths.music(path), volume, loop);
	musicID = path;
}

public static function reverseMin(v, max){
	if(v > max)
		return max + (max - v);
	else
		return v;
}

public static function getFPS() return Math.floor(FlxG.rawElapsed == 0 ? 0 : (1 / FlxG.rawElapsed));

public static function getIDFromString(string, array) for (i=>string2 in array) if (string2 == string)
	return i;