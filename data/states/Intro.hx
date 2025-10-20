import funkin.backend.MusicBeatState;

var waveShader:CustomShader = new CustomShader("wave");

var curDisplayHeight = window.display.bounds.height;
var curDisplayWidth = window.display.bounds.width;
var curDisplayX = window.display.bounds.x;
var curDisplayY = window.display.bounds.y;

var canPress:Bool = true;

var goner:FlxSound = FlxG.sound.load(Paths.sound("intronoise"));
goner.play();

function create(){
	FlxG.camera.alpha = 0;
	FlxG.camera.y = -1000;
	FlxTween.tween(FlxG.camera, {alpha: 1}, 2.57142857);
	FlxTween.tween(FlxG.camera, {y: 0}, 2.57142857, { ease: FlxEase.quadOut });
	new FlxTimer().start(2.57142857+2.78571429, (k) -> {
		FlxTween.tween(FlxG.camera, {alpha: 0}, 3);
		new FlxTimer().start(4.5, function(tmr){
			MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
			FlxG.switchState(new ModState("Menu"));
		});
	});
	logo = new FlxSprite().loadGraphic(Paths.image('logo'));
	logo.scale.set(1, 1);
	logo.updateHitbox();
	logo.screenCenter();
	add(logo);
}

function postCreate(){
	if(!window.fullscreen){
		window.maximized = false;
		alo = FlxTween.num(window.width, 4*curDisplayHeight/3.5, 1.2, { 
			ease: FlxEase.quadInOut,
			onUpdate: function(num){
				window.x = lerp(window.x, curDisplayX + curDisplayWidth/5, 0.04);
				window.width = num.value;
			}
		});
		
		alo = FlxTween.num(window.height, 3*curDisplayHeight/3.5, 1.2, { 
			ease: FlxEase.quadInOut,
			onUpdate: function(num){
				window.y = lerp(window.y, curDisplayY + curDisplayHeight/16, 0.04);
				window.height = num.value;
			}
		});
	}
}

var time_:Float = 0.0;
function update(e:Float) {
	time_ += e;
    waveShader.uTime = time_;
	if (canPress) {
		if (controls.ACCEPT) {
			canPress = false;
			FlxTween.tween(FlxG.camera, {alpha: 0}, 0.5, { ease: FlxEase.quadOut });
			new FlxTimer().start(0.5, function(tmr){
				MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
				FlxG.switchState(new ModState("Menu"));
			});
		}
	}
}

#if mobile
	addTouchPad("NONE", "A");
	addTouchPadCamera(false);
#end