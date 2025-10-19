var events = [];
var eventTag:String = "";
public var conditionFunction;

public function clearEventsList()
	events[eventTag] = [];

public function addEventToList(callback)
	events[eventTag].push(callback);

public function manageEventList(tag:String) {
	if (events[tag] != null)
		events[tag] = [];
	eventTag = tag;
}

public function handleEvent() {
	if (events[eventTag] == null || (events[eventTag] != null && events[eventTag].length == 0)) {
		//scripts.call("eventListEnd", eventTag);
		return;
	}
	var curEvent = events[eventTag].shift();
	curEvent();
}

public function textEvent(dehText:FlxText, str:String, keepText:Bool, sound:FlxSound, offset:Float) {
	if (!keepText && dehText != null)
		dehText.text = "";
	final chars = str.split("");
	var lastChar = "";
	new FlxTimer().start(offset, (ses) -> {
		final nextChar = chars.shift();
		if (dehText != null) {
			if (nextChar != "\\") {
				if (nextChar == "n" && lastChar == "\\") { 
					dehText.text += "\n";
				} else {
					dehText.text += nextChar;
				}
			}
		}
		if (sound != null)
			sound.play(false);
		if (chars.length == 0) 
			handleEvent();
		lastChar = nextChar;
	}, chars.length);
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