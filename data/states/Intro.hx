import funkin.backend.MusicBeatState;

var waveShader:CustomShader = new CustomShader("wave");

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