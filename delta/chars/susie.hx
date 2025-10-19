import flixel.math.FlxAngle;

importScript("data/scripts/DeltaCharacter");
function framesDuration(fps, frames)
	return (1 / fps) * frames;
var character = createCharacter("Susie", "susie", "characters/susie_noeyes", [
	{
		name: "idle",
		prefix: "idle",
		fps: 12,
		loop: true,
	},
	{
		name: "dead",
		prefix: "defeat",
		fps: 12,
		loop: true,
	},
	{
		name: "dead",
		prefix: "defeat",
		fps: 12,
		loop: true,
	},
	{
		name: "rude",
		prefix: "rb_spell",
		fps: 12,
		loop: true,
		offset: [0, 29]
	},
	{
		name: "buster",
		prefix: "rb_cast",
		fps: 12,
		loop: true,
		offset: [18, 32]
	},
], 4, 230, 0xFFFF00FF, true, [
	{
		text: "Rude Buster",
		tp: 0,
		info: "Rude damage.",
		func: function(character, enemy) {
			var enemy = enemies[0];
			addEventToList(() -> textEvent(dialogue, "* Susie casts Rude Buster!" + (enemy != null), false, scrollSound, 0.05));
			addEventToList(() -> {
				character.sprite.playAnim("rude");
				new FlxTimer().start(framesDuration(12, 8), (tmr) -> {
					character.sprite.playAnim("buster");
					new FlxTimer().start(framesDuration(12, 6), (tmr) -> {
						rudebuster = new FunkinSprite(character.sprite.x, character.sprite.y, Paths.image('rudebuster_single'));
						rudebuster.scale.set(4, 4);
						rudebuster.updateHitbox();
						rudebuster.offset.x = 120;
						rudebuster.offset.y = 25;
						rudebuster.angle = FlxAngle.degreesBetween(character.sprite, enemy.sprite);
						rudebuster.cameras = [overworldFront];
						add(rudebuster);
						FlxTween.tween(rudebuster, {x: enemy.sprite.x, y: enemy.sprite.y}, 1, {onComplete: () -> {
							remove(rudebuster);
							var splash = new FunkinSprite(enemy.sprite.x, enemy.sprite.y, Paths.image('rudebuster_splash'));
							splash.addAnim("play", "play", 20, false);
							splash.scale.set(3, 3);
							splash.updateHitbox();
							splash.addOffset("play", 430,260);
							splash.cameras = [overworldFront];
							add(splash);
							splash.playAnim("play", true);
							enemy.shake = 20;
							enemy.hp -= FlxG.random.int(150,200);
							enemy.sprite.playAnim("hurt", true);
							new FlxTimer().start(0.32, (tmr) -> {
								enemy.sprite.playAnim("idle", true);
								handleEvent();
							});
						}});
					});
					new FlxTimer().start(framesDuration(12, 14), (tmr) -> {
						character.sprite.playAnim("idle");
						character.sprite.offset.set(0,0);
					});
				});
			});
			addEventToList(() -> {
				conditionFunction = () -> {
					return controls.ACCEPT;
				};
			});
		},
	},
], 0, 0);
characters.push(character);