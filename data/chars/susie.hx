import deltaflixel.objects.DeltaCharacter;
import flixel.math.FlxAngle;
var character = new DeltaCharacter({
	// stats, acts and magic part
	name: "Susie",
	hp: 230,
	stats: {
		hp: 230,
		attack: 20,
		defense: 2,
		magic: 1,
	},
	canSpell: true,
	spells: [
		{
			text: "S-Action",
			enemySpecific: "Cheese",
			tp: 0,
			info: "i hate 67 with every god damn part of my soul.",
			func: (character, enemy) -> {
			},
		},
		{
			text: "Rude Buster",
			tp: 0,
			info: "Rude damage.",
			func: (character, enemy) -> {
				var enemy = enemy;
				var character = character;
				events[eventName].push(() -> doTextStuff("* Susie casts Rude Buster!" + (enemy != null), false, true, "default", null, 0.05));
				events[eventName].push(() -> {
					character.playAnim("rude");
					new FlxTimer().start(framesDuration(12, 8), (tmr) -> {
						character.playAnim("buster");
						new FlxTimer().start(framesDuration(12, 6), (tmr) -> {
							rudebuster = new FunkinSprite(character.x, character.y, Paths.image('rudebuster_single'));
							rudebuster.scale.set(4, 4);
							rudebuster.updateHitbox();
							rudebuster.offset.x = 120;
							rudebuster.offset.y = 25;
							rudebuster.angle = FlxAngle.degreesBetween(character, enemy);
							rudebuster.cameras = [overworldFront];
							add(rudebuster);
							playSound("rudebuster_swing");
							FlxTween.tween(rudebuster, {x: enemy.x, y: enemy.y}, 0.32, {onComplete: () -> {
								remove(rudebuster);
								playSound("rudebuster_hit");
								var splash = new FunkinSprite(enemy.x, enemy.y, Paths.image('rudebuster_splash'));
								splash.addAnim("play", "play", 20, false);
								splash.scale.set(3, 3);
								splash.updateHitbox();
								splash.addOffset("play", 430,260);
								splash.cameras = [overworldFront];
								add(splash);
								splash.playAnim("play", true);
								enemy.hurt((11*character.attack)+(5*character.magic)-(3*character.defense), true, 20);
								new FlxTimer().start(0.32, (tmr) -> {
									enemy.playAnim("idle", true);
									handleEvent();
								});
							}});
						});
						new FlxTimer().start(framesDuration(12, 14), (tmr) -> {
							character.playAnim("idle");
						});
					});
				});
				events[eventName].push(() -> {
					conditionFunction = () -> {
						if (keys.ACCEPT) {
							endDialouge(false);
							return true;
						}
						return false;
					};
				});
			},
		},
	],
	// visual stuff
	color: [255, 0, 255],
    damageColor: [204, 253, 204],
    attackBarColor: [234, 121, 200],
    attackBoxColor: [128, 0, 128],
    actColor: [255, 128, 255],
	icon: "susie",
	spritesheet: "characters/susie_noeyes",
	scale: 4,
	animations: [
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
			offset: [0, 129]
		},
		{
			name: "buster",
			prefix: "rb_cast",
			fps: 12,
			loop: true,
			offset: [18, 132]
		},
	],
});
characters.push(character);