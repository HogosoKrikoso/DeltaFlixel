import StringTools;

public var dialouge:FlxText;
public var portrait:FlxSprite;
public var overworldDialougeBox:FlxSprite;

public var events = [];
public var eventName:String = "";
public var conditionFunction;
public function manageEventList(tag:String) {
	if (events[tag] != null)
		events[tag] = [];
	eventName = tag;
}

public function handleEvent() {
	if (events[eventName] == null || (events[eventName] != null && events[eventName].length == 0)) {
		//scripts.call("eventListEnd", eventName);
		return;
	}
	var curEvent = events[eventName].shift();
	curEvent();
}

var textTimer:FlxTimer;
public function doTextStuff(?str:String = "", ?keepText:Bool = false, ?noAccept:Bool = false, ?soundPath:String = null, ?graphicPath:String = null, ?offset:Float = 0.05){
	if (graphicPath != null && portrait != null) {
		portrait.loadGraphic(Paths.image("ui/dialouge/face/" + graphicPath));
		portrait.scale.set(3.6,3.6);
		portrait.updateHitbox();
		portrait.visible = true;
		if (dialouge != null) dialouge.offset.x = -(portrait.width + 25);
	} else {
		if (dialouge != null) dialouge.offset.x = 0;
		if (portrait != null) portrait.visible = false;
	}
	if (dialouge != null) dialouge.visible = true;
	if (overworldDialougeBox != null) overworldDialougeBox.visible = true;
	var sound:FlxSound;
	if (soundPath != null) sound = FlxG.sound.load(Paths.sound("dialouge/" + soundPath));
	if (!keepText && dialouge != null)
		dialouge.text = "";
	final chars = str.split("");
	var lastChar = "";
	if (!noAccept) {
		conditionFunction = () -> {
			if(controls.BACK) {
				textTimer.cancel();
				dialouge.text = StringTools.replace(str, "|w", "");
				conditionFunction = () -> {
					if(controls.ACCEPT) {
						endDialouge(keepText);
						return true;
					}
				}
			}
			if(controls.SWITCHMOD) {
				textTimer.cancel();
				endDialouge(keepText);
				return true;
			}
			return false;
		}
	} else {
		conditionFunction = () -> {
			if(controls.BACK || controls.SWITCHMOD) {
				textTimer.cancel();
				dialouge.text = StringTools.replace(str, "|w", "");
				return true;
			}
			return false;
		}
	}
	textTimer = new FlxTimer().start(offset, (ses) -> {
		final nextChar = chars.shift();
		if (dialouge != null) {
			if (nextChar != "\\") {
				if (nextChar == "n" && lastChar == "\\") { 
					dialouge.text += "\n";
					lastChar = nextChar;
					return;
				}
			} else {
				lastChar = nextChar;
				return;
			}
			if (nextChar != "|") {
				if (nextChar == "w" && lastChar == "|") { 
					lastChar = nextChar;
					return;
				}
			} else {
				lastChar = nextChar;
				return;
			}
			dialouge.text += nextChar;
		}
		if (sound != null)
			sound.play(false);
		lastChar = nextChar;
		if (chars.length == 0) {
			if (!noAccept) {
				conditionFunction = () -> {
					if(controls.ACCEPT) {
						endDialouge(keepText);
						return true;
					}
				}
			} else {
				handleEvent();
			}
		}
	}, chars.length);
}

public function endDialouge(keepText) {
	if (!keepText && dialouge != null) dialouge.text = "";
	if (portrait != null) portrait.visible = false;
	if (dialouge != null) dialouge.visible = false;
	if (overworldDialougeBox != null) overworldDialougeBox.visible = false;
}

function update() {
	if (conditionFunction != null) {
		final result = conditionFunction();
		if (result) {
			conditionFunction = null;
			handleEvent();
		}
	}
}