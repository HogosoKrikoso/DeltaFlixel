import funkin.menus.ModSwitchMenu;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.text.FlxTextBorderStyle;
import flixel.FlxCamera.FlxCameraFollowStyle;
import haxe.io.Path;
import openfl.text.TextField;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import funkin.backend.system.Controls;
import funkin.backend.system.Paths;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.ui.FlxBar;
import FunkinBitmapText;
import deltaflixel.objects.DeltaCharacter;
import deltaflixel.objects.DeltaEnemy;
import deltaflixel.objects.BattleButton;
import deltaflixel.objects.FightBox;
public var onBattle:Bool = true;

importScript("data/scripts/eventSystem");
	
public var characters:Array = [];
public var enemies:Array = [];

var turn:Int = 0;
var state = "actions";
var textOptionCase = "";

var confirmSound:FlxSound = FlxG.sound.load(Paths.sound("menu/confirm"));
public var scrollSound:FlxSound = FlxG.sound.load(Paths.sound("menu/scroll"));
var cancelSound:FlxSound = FlxG.sound.load(Paths.sound("menu/cancel"));
var rudeBusterMusic:FlxSound = FlxG.sound.load(Paths.music("RudeBuster"));
rudeBusterMusic.looped = true;
rudeBusterMusic.volume = 0.54;
rudeBusterMusic.play();

var hpBar:FlxBar;

public var battleGrid = new FlxCamera(0, 0, FlxG.width, FlxG.height);
public var overworldFront = new FlxCamera(0, 0, FlxG.width, FlxG.height);
public var camUI = new FlxCamera(0, 0, FlxG.width, FlxG.height);
for (u in [battleGrid, overworldFront, camUI]) {
	u.bgColor = 0;
	FlxG.cameras.add(u, false);
}

public var tensionPoints:Float = 0;

public var undos:Array<Float> = [];
public var char_acts:Array = [];

var fightTurn = 0;
var curAction:Int = 0;
var curSel:Int = 0;
var targetCharacter:Int = 0;
var menuItems:Array<String> = ["fight", "act", "item", "spare", "defend"];
var groupMenuItems:FlxTypedGroup = [];
var textOptions:FlxTypedGroup = [];
var fightBoxes:FlxTypedGroup = [];

public var gridBack:FlxBackdrop = new FlxBackdrop(Paths.image('deltaruneBackground'));
gridBack.velocity.set(30, 30);
gridBack.alpha = 0.5;
gridBack.cameras = [battleGrid];
add(gridBack);
public var grid:FlxBackdrop = new FlxBackdrop(Paths.image('deltaruneBackground'));
grid.velocity.set(-30, -30);
grid.cameras = [battleGrid];
add(grid);

#if mobile
addTouchPad('LEFT_FULL', 'A_B_C');
addTouchPadCamera(false);
#end

function playSound(path, force) {
	var sound = FlxG.sound.load(Paths.sound(path));
	sound.volume = 1;
	sound.play(force);
}

public function doTextOptions(stuff) {
	curSel = 0;
	for (that in textOptions)
		remove(that.obj, true);
	textOptions = [];
	if (stuff != null) {
		for (daOption in stuff) {
			text = new FlxText(0, -55, 0, daOption.text).setFormat(Paths.font("determination.ttf"), 55, FlxColor.WHITE, "center");
			text.cameras = [camUI];
			text.x = -text.width;
			textOptions.push({obj: text, data: daOption});
			add(text);
		}
	}
}

function create() {
	
	tpBar = new FlxBar(0, 0, FlxBarFillDirection.RIGHT_TO_LEFT, 859, 100, null, '', 0, 100);
	tpBar.createImageBar(Paths.image('ui/tpBar_empty'), Paths.image('ui/tpBar_filled'));
	tpBar.setPosition(-300,310);
	tpBar.angle = 90;
	tpBar.scale.set(0.5, 0.5);
	tpBar.antialiasing = false;
	tpBar.numDivisions = 500;
	tpBar.cameras = [camUI];
	add(tpBar);
	
	tpLabel = new FlxSprite().loadGraphic(Paths.image('ui/tp'));
	tpLabel.scale.set(2,2);
	tpLabel.updateHitbox();
	tpLabel.setPosition(35, 200);
	tpLabel.cameras = [camUI];
	add(tpLabel);
	
	tpText = new FlxText(32, 300);
	tpText.setFormat(Paths.font("determination.ttf"), 56, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	tpText.borderSize = 3;
	tpText.borderQuality = 1;
	tpText.fieldWidth = tpBar.x;
	tpText.cameras = [camUI];
	add(tpText);
	
	hudBase = new FlxSprite().loadGraphic(Paths.image('ui/base'));
	hudBase.scale.set(FlxG.width,1.25);
	hudBase.updateHitbox();
	hudBase.y = FlxG.height - hudBase.height;
	hudBase.cameras = [camUI];
	add(hudBase);
	
	for (i in 0...menuItems.length) {
		item = new BattleButton(0,0,menuItems[i],2);
		item.cameras = [camUI];
		groupMenuItems.push(item);
		add(item);
	}
	
	dialouge = new FlxText();
	dialouge.setFormat(Paths.font("determination.ttf"), 56, FlxColor.WHITE, "left");	dialouge.fieldWidth = FlxG.width - (dialouge.x+45);
	dialouge.text = "* cheezborger";
	dialouge.cameras = [camUI];
	add(dialouge);
	
	portrait = new FlxSprite(35, hudBase.y + 75);
	portrait.cameras = [camUI];
	portrait.visible = false;
	add(portrait);
	
	hpBar = new FlxBar((FlxG.width / 2), hudBase.y + 46, FlxBar.FILL_LEFT_TO_RIGHT, 175, 18, null, "", 0, 1);
	hpBar.cameras = [camUI];
	add(hpBar);
	
	hpLabel = new FlxSprite().loadGraphic(Paths.image('ui/hp'));
	hpLabel.scale.set(2.25,2.25);
	hpLabel.updateHitbox();
	hpLabel.setPosition(hpBar.x - (hpLabel.width + 14), hpBar.y);
	hpLabel.cameras = [camUI];
	add(hpLabel);
	
	hpText = new FlxText(hpBar.x, hudBase.y + 13);
	hpText.setFormat(Paths.font("small.ttf"), 29, FlxColor.WHITE, "right");
	hpText.fieldWidth = hpBar.width;
	hpText.cameras = [camUI];
	add(hpText);
	
	name = new FunkinBitmapText(0, hudBase.y + 20, "name", " ABCDEFGHIJKLMNOPQRSTUVWXYZ", 11, 18, "", 2.75);
	name.cameras = [camUI];
	add(name);
	
	icon = new FlxSprite();
	icon.cameras = [camUI];
	add(icon);
	
	textOptHP = new FlxBar(10,10, FlxBar.FILL_LEFT_TO_RIGHT, 200, 50, null, "", 0, 1);
	textOptHP.cameras = [camUI];
	textOptHP.createFilledBar(0xFFAA0000, 0xFF00FF00);
	add(textOptHP);
	
	textOptHPText = new FlxText(13, 13);
	textOptHPText.setFormat(Paths.font("determination.ttf"), 50, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	textOptHPText.cameras = [camUI];
	textOptHPText.borderSize = 3;
	add(textOptHPText);
	
	textOptSpare = new FlxBar(FlxG.width - 210, 20, FlxBar.FILL_LEFT_TO_RIGHT, 200, 50, null, "", 0, 1);
	textOptSpare.cameras = [camUI];
	textOptSpare.createFilledBar(0xFFAA0000, 0xFFFFF00);
	add(textOptSpare);
	
	textOptSpareText = new FlxText(FlxG.width - 197, 23).setFormat(Paths.font("determination.ttf"), 50, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	textOptSpareText.cameras = [camUI];
	textOptSpareText.borderSize = 3;
	add(textOptSpareText);
	
	textOptDescription = new FlxText(FlxG.width - 250, hudBase.y + 90, 250).setFormat(Paths.font("determination.ttf"), 50, FlxColor.GRAY, "left");
	textOptDescription.cameras = [camUI];
	textOptDescription.borderSize = 3;
	add(textOptDescription);
	
	textOptTP = new FlxText(FlxG.width - 250, FlxG.height - 60, 250).setFormat(Paths.font("determination.ttf"), 50, FlxColor.ORANGE, "left");
	textOptTP.cameras = [camUI];
	textOptTP.borderSize = 3;
	add(textOptTP);
	
	soul = new FlxSprite(0,0).loadGraphic(Paths.image('ui/soul'));
	soul.scale.set(3, 3);
	soul.updateHitbox();
	soul.cameras = [camUI];
	add(soul);
	
	/*if (chars != null) 
	characters = chars;
	else {*/
		importScript("data/chars/kris");
		importScript("data/chars/susie");
		importScript("data/chars/ralsei");
		//importScript("data/chars/noelle");
	//}
	
	/*if (_enemies != null) 
		enemies = _enemies;
	else {*/
		importScript("data/enemies/cheese");
	//}
	
	eventName = "startup";
	events[eventName] = [
		() -> doTextStuff("* Cheese.", false, true, "default", null, 0.05),
	];
	handleEvent();
		
	var i = 0;
	for (character in characters) {
		character.camera = overworldFront;
		add(character);
		undos.push(0);
		char_acts.push("");
		var box = new FightBox((FlxG.width/2)-240, 25 + 80*i, character);
		add(box.icon);
		add(box.box);
		add(box.bar);
		fightBoxes.push(box);
		i += 1;
	}
	for (enemy in enemies) if (enemy != null) {
		enemy.camera = overworldFront;
		add(enemy);
	}
}

public function changeAction(number:Int = 0){
	curAction = FlxMath.wrap(curAction + number, 0, menuItems.length-1);
	scrollSound.play(true);
}
public function changeSel(number:Int = 0){
	curSel = FlxMath.wrap(curSel + number, 0, textOptions.length-1);
	scrollSound.play(true);
}
function update() {
	dialouge.fieldWidth = FlxG.width - (45 - dialouge.offset.x);
	if (touchPad.buttonC.justPressed) FlxG.resetState();
	if (state != "enemyAttack")
		targetCharacter = turn;
	tensionPoints = FlxMath.bound(tensionPoints, 0, 100);
	targetCharacter = FlxMath.bound(targetCharacter, 0, characters.length-1);
	var char = characters[targetCharacter];
	if (name != null) {
		name.text = char.name.toUpperCase();
		name.updateHitbox();
		name.y = hudBase.y + 18;
		name.x = hpBar.x - (name.width + 64);
	}
	if (dialouge != null) {
		dialouge.setPosition(45, hudBase.y + 100);
	}
	if (icon != null) {
		icon.loadGraphic(Paths.image('ui/icons/' + char.icon));
		icon.scale.set(2,2);
		icon.updateHitbox();
		icon.setPosition(name.x - (icon.width + 12), hudBase.y + 14);
	}
	if (tpText != null) {
		if (tensionPoints >= 100) {
			tpText.text = "M\n A\n  X";
			tpText.color = FlxColor.YELLOW;
		} else {
			tpText.text = Math.floor(tensionPoints) + "\n%";
			tpText.color = FlxColor.WHITE;
		}
	}
	/*if (tpBar != null) {
		tpBar.percent = CoolUtil.fpsLerp(tpBar.percent, tensionPoints, 0.1);
	}*/
	if (hpBar != null) {
		hpBar.createFilledBar(0xFFAA0000, char.color);
		hpBar.value = char.hp/char.maxHP;
	}
	if (hpText != null) {
		hpText.text = char.hp + "/" + char.maxHP;
		hpText.color = char.hp <= 0 ? FlxColor.RED : (char.hp <= char.maxHP/4 ? FlxColor.YELLOW : FlxColor.WHITE);
	}
	for (i=>item in groupMenuItems) {
		item.x = ((FlxG.width/2) - (40*groupMenuItems.length)) + (80*i);
		item.y = hudBase.y - 75;
	}
	if (state == "actions") {
		for (i=>enemy in enemies) {
			if (enemy.hp <= 0) {
				enemies = removeFromArray(i, enemies);
			}
		}
		dialouge.visible = true;
		if (controls.BACK) {
			if (turn > 0) {
				cancelSound.play(true);
				prevTurn();
			}
		}
		characters[turn].playAnim("idle", false);
		if (controls.ACCEPT) {
			if (characters[turn].hp < 0) {
				nextTurn();
				return;
			}
			confirmSound.play(true);
			switch (groupMenuItems[curAction].buttonName) {
				case "fight":
					state = "select";
					textOptionCase = "fight";
					characters[turn].choices[0] = 0;
					doTextOptions(getEnemyOptions());
				case "act":
					state = "select";
					textOptionCase = "magic";
					characters[turn].choices[0] = 1;
					doTextOptions(characters[turn].baseSpells);
				case "magic":
					state = "select";
					textOptionCase = "act";
					characters[turn].choices[0] = 1;
					doTextOptions(getEnemyOptions());
				case "defend":
					characters[turn].choices[0] = 4;
					tensionPoints += 16;
					undos[turn] = 16;
					characters[turn].playAnim("defend", false);
					nextTurn();
			}
			return;
		}
		
		if (controls.LEFT_P) {
			changeAction(-1);
		}
		
		if (controls.RIGHT_P) {
			changeAction(1);
		}
		
		for (i=>item in groupMenuItems) {
			var id = item.buttonName;
			if (id == "act" || id == "magic") item.buttonName = characters[turn].canMagic ? "magic" : "act";
			item.updateGraphic(i == curAction);
		}
	} else dialouge.visible = state == "events" || state == "win";
	if (state == "select") {
		var data = textOptions[curSel].data;
		if (data.tp == null) data.tp = 0;
		var text = textOptions[curSel].obj;
		textOptDescription.text = "";
		textOptTP.text = "";
		if (data.hp != null && data.maxHP != null) {
			textOptHP.value = FlxMath.bound(data.hp/data.maxHP, 0, 1);
			textOptHPText.text = Math.floor(FlxMath.bound(data.hp/data.maxHP, 0, 1)*100) + "%";
			textOptHP.visible = textOptHPText.visible = true;
		} else {
			textOptHP.visible = textOptHPText.visible = false;
			if (data.tp > 0)
				textOptTP.text = data.tp + "% TP";
			if (data.info != null)
				textOptDescription.text += data.info;
		}
		textOptSpare.setPosition(FlxG.width-(textOptSpare.width+10), text.y-0);
		textOptSpareText.setPosition(textOptSpare.x+3, textOptSpare.y+3);
		textOptHP.setPosition(textOptSpare.x-(textOptHP.width+30), textOptSpare.y);
		textOptHPText.setPosition(textOptHP.x+3, textOptHP.y+3);
		soul.x = text.x - 60;
		soul.y = text.y - 5;
		if (data.spare != null) {
			textOptSpare.value = FlxMath.bound(data.spare/100, 0, 1);
			textOptSpareText.text = FlxMath.bound(data.spare, 0, 100) + "%";
			textOptSpare.visible = textOptSpareText.visible = true;
		} else {
			textOptSpare.visible = textOptSpareText.visible = false;
		}
		if (controls.BACK) {
			cancelSound.play(true);
			switch(textOptionCase) {
				default:
					state = "actions";
					characters[turn].choices[0] = 0;
					doTextOptions([]);
				case "magic2":
					char_acts[turn] = "";
					state = "select";
					textOptionCase = "magic";
					characters[turn].choices[2] = 0;
					doTextOptions(characters[turn].baseSpells);
					if (undos[turn] != 0) {
						tensionPoints -= undos[turn];
						undos[turn] = 0;
					}
				case "magicPlayer":
					char_acts[turn] = "";
					state = "select";
					textOptionCase = "magic";
					characters[turn].choices[2] = characters[turn].choices[3] = 0;
					doTextOptions(characters[turn].baseSpells);
					if (undos[turn] != 0) {
						tensionPoints -= undos[turn];
						undos[turn] = 0;
					}
				case "act2":
					state = "select";
					textOptionCase = "act";
					characters[turn].choices[1] = 0;
					doTextOptions(getEnemyOptions());
					if (undos[turn] != 0) {
						tensionPoints -= undos[turn];
						undos[turn] = 0;
					}
			}
		}
		if (controls.ACCEPT) {
			confirmSound.play(true);
			switch(textOptionCase) {
				case "fight":
					characters[turn].playAnim("attackprep", true);
				case "magic2":
					characters[turn].playAnim("spellprep", true);
				case "magicPlayer":
					characters[turn].playAnim("spellprep", true);
				case "act2":
					characters[turn].playAnim("actprep", true);
			}
			switch(textOptionCase) {
				default:
					characters[turn].choices[1] = curSel;
					nextTurn();
					doTextOptions([]);
				case "act":
					characters[turn].choices[1] = curSel;
					state = "select";
					textOptionCase = "act2";
					doTextOptions(enemies[curSel].acts.get(characters[turn].name));
				case "act2":
					if (tensionPoints >= data.tp) {
						char_acts[turn] = data.func;
						tensionPoints -= data.tp;
						undos[turn] = -data.tp;
						characters[turn].choices[2] = curSel;
						nextTurn();
						doTextOptions([]);
					}
				case "magic":
					if (tensionPoints >= data.tp) {
						char_acts[turn] = data.func;
						tensionPoints -= data.tp;
						undos[turn] = -data.tp;
						characters[turn].choices[2] = curSel;
						state = "select";
						characters[turn].choices[3] = data.party ? 1 : 0;
						textOptionCase = data.party ? "magicPlayer" : "magic2";
						doTextOptions(data.party ? getPartyOptions() : getEnemyOptions());
					}
			}
			return;
		}
		soul.visible = true;
		updateTextOptions();
	} else {
		soul.visible = false;
		textOptHP.visible = textOptHPText.visible = textOptSpare.visible = textOptSpareText.visible = false;
		textOptDescription.text = "";
		textOptTP.text = "";
	}
	if (state == "FightState") {
		for (i=>box in fightBoxes) {
			box.alpha = CoolUtil.fpsLerp(characters[i].choices[0] == 0 ? 1 : 0, box.alpha, 0.5);
			box.canUpdate = characters[i].choices[0] == 0;
			box.canPress = (i == fightTurn);
			var enemy = enemies[characters[i].choices[1]];
			if (enemy.hp <= 0)
				characters[i].choices[0] = -1;
			if (i == fightTurn && characters[i].choices[0] != 0)
				fightTurn += 1;
			if (i == fightTurn && box.pressed) {
				if (box.accuracy >= 0.95)
					box.bar.color = FlxColor.YELLOW;
				if (box.accuracy >= 0)
					tensionPoints += 24;
				playSound("slash", true);
				new FlxTimer().start(0.32, () -> {
					if (box.accuracy > 0) {
						enemy.hurt(Math.floor(120*box.accuracy));
						new FlxTimer().start(0.32, (tmr) -> {
							enemy.playAnim("idle", true);
						});
					}
				});
				characters[i].playAnim("attack", false);
				fightTurn += 1;
			}
		}
		if (fightTurn >= characters.length) {
			new FlxTimer().start(1, () -> {
				state = "actions";
				turn = 0;
				for (character in characters) {
					character.playAnim("idle", true);
					character.choices = [0,0,0,0,0,0];
				}
			});
		}
	}else{
		for (box in fightBoxes) {
			box.canUpdate = false;
			box.alpha = CoolUtil.fpsLerp(0, box.alpha, 0.5);
		}
	}
	for (i=>character in characters) {
		character.y = CoolUtil.fpsLerp(150 + ((400/characters.length) * (characters.length < 2 ? 0.25 : i)), character.y, 0.5);
		character.x = CoolUtil.fpsLerp(275 - ((25/characters.length) * i), character.x, 0.5) + FlxG.random.float(-character.shake,character.shake);
		if (character.shake > 0) character.shake -= 0.1;
	}
	for (i=>enemy in enemies) {
		if (enemy.hp <= 0) {
			FlxTween.tween(enemy, {x: FlxG.width-(enemy.width+25)}, 0.5, {ease: FlxEase.quadOut});
			enemy.playAnim("dead");
			new FlxTimer().start(0.5, (x) -> {
				if (enemy != null) FlxTween.tween(enemy, {x: FlxG.width*1.1}, 0.32);
			});
		} else {
			enemy.y = CoolUtil.fpsLerp(150 + ((400/enemies.length) * (enemies.length < 2 ? 0.25 : i)), enemy.y, 0.5);
			enemy.x = CoolUtil.fpsLerp((FlxG.width - 320) + ((25/enemies.length) * i), enemy.x, 0.5) + FlxG.random.float(-enemy.shake,enemy.shake);
			if (enemy.shake > 0) enemy.shake -= 0.25;
		}
	}
	var deadChars = 0;
	for (character in characters) {
		if (character.hp <= 0) {
			character.playAnim("dead", true);
			deadChars += 1;
		}else{
			if (character.animation.name == "dead") {
				character.playAnim("idle", true);
			}
		}
	}
	if (deadChars == characters.length) FlxG.resetState();
	for (box in fightBoxes) box.update(controls.ACCEPT);
	if (enemies.length <= 0 && state != "win") {
		eventName = "youWon";
		events[eventName] = [
			() -> doTextStuff("You won!\n0 XP - 0 D$", false, false, "default", null, 0.05),
		];
		handleEvent();
		state = "win";
	}
}

function updateTextOptions() {
	if (controls.UP_P) 
		changeSel(-1);
	if (controls.DOWN_P) 
		changeSel(1);
	var i = 0;
	for (o in textOptions) {
		var text = o.obj;
		text.x = CoolUtil.fpsLerp(70, text.x, 0.5);
		text.y = (hudBase.y + 95) + (60*(i-Math.max(curSel-2,0)));
		if (text.y < (hudBase.y + 85))
			text.visible = false;
		else
			text.visible = true;
		if (o.data.tp == null || (o.data.tp != null && tensionPoints >= o.data.tp))
			text.color = FlxColor.WHITE;
		else
			text.color = FlxColor.GRAY;
		i += 1;
	}
}
public function nextTurn() {
	turn += 1;
	if (turn >  characters.length-1)  {
		state = "events";
		eventName = "postPlayerTurn";
		events[eventName] = [];
		for (i=>character in characters) {
			var to_do = char_acts[i];
			if (to_do != ""){
				var enemy = character.choices[3] == 1 ? characters[character.choices[1]] : enemies[character.choices[1]];
				to_do(character, enemy);
				char_acts[i] = "";
			}
		}
		events[eventName].push(() -> {
			fightTurn = 0;
			for (i=>box in fightBoxes) {
				box.resetX();
				box.pressed = false;
				box.bar.offset.x -= i*125;
				box.bar.color = FlxColor.WHITE;
			}
			state = "FightState";
		});
		handleEvent();
	} else
		state = "actions";
}

public function prevTurn() {
	turn -= 1;
	if (undos[turn] != 0) {
		tensionPoints -= undos[turn];
		undos[turn] = 0;
	}
	char_acts[turn] = "";
	characters[turn].choices = [0,0,0,0,0,0];
	state = "actions";
}

public function getEnemyOptions() {
	var t:Array<Dynamic> = [];
	for (enemy in enemies) t.push({text: enemy.name, hp: enemy.hp, maxHP: enemy.maxHP, spare: enemy.spare});
	return t;
}

public function getPartyOptions() {
	var t:Array<Dynamic> = [];
	for (character in characters) t.push({text: character.name, hp: character.hp, maxHP: character.maxHP});
	return t;
}

public function removeFromArray(id, array) {
	var t = [];
	for (i=>stuff in array) if(i != id) 
		t.push(stuff);
	return t;
}

/*if (scripts != null) for (path in scripts)
	importScript(path);*/