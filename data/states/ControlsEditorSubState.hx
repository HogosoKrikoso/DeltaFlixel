import deltaflixel.mobile.Joystick;
import deltaflixel.mobile.Button;
import flixel.input.touch.FlxTouch;

var buttonStatesAndTouchs = [];

var substateCam:FlxCamera = new FlxCamera();
var fakeJoystick:Joystick;
var fakeAccept:Button;
var fakeBack:Button;
var fakeAccept:Button;

var alphaTween:FlxTween;

function create() {
	
	FlxG.cameras.add(substateCam, false).bgColor = 0x88000000;
	substateCam.alpha = 0;
	alphaTween = FlxTween.tween(substateCam, {alpha: 1}, 0.5);
	
	fakeJoystick = new Joystick(100, FlxG.height-460, 1280, "ui/mobile/joystick", "ui/mobile/joystick");
	fakeJoystick.scale.set(2,2);
	fakeJoystick.startJoystick();
	fakeJoystick.initialized = false;
	fakeAccept = new Button(FlxG.width - 400, FlxG.height-260, "ui/mobile/z");
	fakeBack = new Button(FlxG.width - 300, FlxG.height-460, "ui/mobile/x");
	fakeMenu = new Button(FlxG.width - 200, FlxG.height-260, "ui/mobile/c");
	
	save = new Button(0, 100, "ui/mobile/save");
	save.screenCenter(FlxAxes.X);
	reset = new Button(0, 220, "ui/mobile/reset");
	reset.screenCenter(FlxAxes.X);
	
	var btnPos = DeltaFlixelControls.data;
	fakeJoystick.setPosition(btnPos.joystick[0], btnPos.joystick[1]);
	fakeAccept.setPosition(btnPos.accept[0], btnPos.accept[1]);
	fakeBack.setPosition(btnPos.back[0], btnPos.back[1]);
	fakeMenu.setPosition(btnPos.menu[0], btnPos.menu[1]);
	
	for (btn in [fakeAccept, fakeBack, fakeMenu, save, reset]) add(btn);
	
	for (_btn in [fakeAccept, fakeBack, fakeMenu, fakeJoystick]) {
		buttonStatesAndTouchs.push({
			dragState: false,
			touchID: 0,
			btn: _btn
		});
	}
	
	camera = substateCam;
	
}

function update() {
	for (info in buttonStatesAndTouchs) {
		var dragState = info.dragState;
		var touch = FlxG.touches.list[info.touchID];
		var btn = info.btn;
		if (dragState) {
			mousePos = touch.getScreenPosition();
			if (btn == fakeJoystick) {
				btn.x = mousePos.x - (btn.center.x - btn.base.x);
				btn.y = mousePos.y - (btn.center.y - btn.base.y);
			} else {
				btn.x = mousePos.x - (btn.width/2);
				btn.y = mousePos.y - (btn.height/2);
			}
			if (!touch.pressed) info.dragState = false;
		} else {
			var obj = btn == fakeJoystick ? btn.base : btn;
			for (i=>touch in FlxG.touches.list) if (touch.overlaps(obj) && touch.justPressed) {
				info.touchID = i;
				info.dragState = true;
			}
		}
		btn.update();
	}
	if (reset.justPressed) {
		var btnPos = buttonPositions;
		fakeJoystick.setPosition(btnPos["joystick"][0], btnPos["joystick"][1]);
		fakeAccept.setPosition(btnPos["accept"][0], btnPos["accept"][1]);
		fakeBack.setPosition(btnPos["back"][0], btnPos["back"][1]);
		fakeMenu.setPosition(btnPos["menu"][0], btnPos["menu"][1]);
		playSound("heal", true);
	}
	if (save.justPressed) {
		var btnPos = DeltaFlixelControls.data;
		DeltaFlixelControls.data.joystick = [fakeJoystick.x, fakeJoystick.y];
		DeltaFlixelControls.data.accept = [fakeAccept.x, fakeAccept.y];
		DeltaFlixelControls.data.back = [fakeBack.x, fakeBack.y];
		DeltaFlixelControls.data.menu = [fakeMenu.x, fakeMenu.y];
		updateControlsPosition();
		DeltaFlixelControls.flush();
		playSound("menu/confirm", true);
		alphaTween.cancel();
		substateCam.alpha = 0;
		close();
	}
}