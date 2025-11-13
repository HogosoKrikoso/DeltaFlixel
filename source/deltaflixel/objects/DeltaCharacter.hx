function getColorFromRGBArray(c) return FlxColor.fromRGB(c[0], c[1], c[2]);

class DeltaCharacter extends FunkinSprite
{
	public var name = "";
	public var icon = "";
	public var hp = 0;
	public var maxHP = 0;
	public var attack:Int;
	public var defense:Int;
	public var magic:Int;
	public var color = FlxColor.WHITE;
	public var actColor = FlxColor.WHITE;
	public var attackBoxColor = FlxColor.WHITE;
	public var attackBarColor = FlxColor.WHITE;
	public var damageColor = FlxColor.WHITE;
	public var choices = [0,0,0,0,0,0];
	public var canSpell = false;
	public var spells = [];
	public var shake = 0;
	
	var movementHistory = [];
	public inline var baseSpeed:Float = 200;
	public var followTimer:Float = 0;
	public var facing = "down";
	public var isMoving:Bool;
	public var canMove:Bool = true;
	public var action:String = "idle";
	
	var overworldX:Float;
	var overworldY:Float;
	
	public function new(data) { 
		super();
		name = data.name;
		icon = data.icon;
		hp = data.stats.hp;
		maxHP = data.hp;
		color = getColorFromRGBArray(data.color);
		actColor = getColorFromRGBArray(data.actColor);
		attackBoxColor = getColorFromRGBArray(data.attackBoxColor);
		attackBarColor = getColorFromRGBArray(data.attackBarColor);
		damageColor = getColorFromRGBArray(data.damageColor);
		attack = data.stats.attack;
		defense = data.stats.defense;
		canSpell = data.canSpell;
		if(canSpell) {
			spells = data.spells;
			magic = data.stats.magic;
		}
		frames = Paths.getFrames(data.spritesheet);
		scale.set(data.scale,data.scale);
		for (anim in data.animations) {
			var autoIndices = [];
			if (anim.endFrame != null) for (i in 0...(anim.endFrame + 1))
				autoIndices.push(i);
			addAnim(anim.name, anim.prefix, anim.fps, anim.loop, false, anim.indices == null ? autoIndices : anim.indices);
			if (anim.offset != null)
				addOffset(anim.name, anim.offset[0], anim.offset[1]);
			else
				addOffset(anim.name, 0,0);
		}
		playAnim('idle');
		updateHitbox();
	}
	public function overworldUpdate(parent, ?keys){
		overworldX = x;
		overworldY = y;
		
		if (parent == null) {
			speed = baseSpeed;
			
			var up = keys.UP;
			var down = keys.DOWN;
			var left = keys.LEFT;
			var right = keys.RIGHT;
	
			if (keys.BACK_HOLD && action == "walk"){ 
				speed += 100;
				animation.timeScale = 1.5;
			}
			else animation.timeScale = 1.0;
			if (up || down || left || right) {
	
				if (up && down)
					up = down = false;
				if (left && right)
					left = right = false;
		
				if(canMove && (up || down || left || right)){
					var newAngle:Float = 0;
					if (up){
						newAngle = -90;
						if (left)
							newAngle -= 45;
						else if (right)
							newAngle += 45;
						facing = 'up';
					}
					else if (down){
						newAngle = 90;
						if (left)
							newAngle += 45;
						else if (right)
							newAngle -= 45;
						facing = 'down';
					}
					else if (left){
						newAngle = 180;
						facing = 'left';
					}
		
					else if (right){
						newAngle = 0;
						facing = 'right';
					}
					
					velocity.setPolarDegrees(speed, newAngle);
				}
			} else {
				velocity.set(0,0);
			}
			#if mobile
			x += velocity.x / getFPS();
			y += velocity.y / getFPS();
			#else
			x += velocity.x / 30;
			y += velocity.y / 30;
			#end
			action = "idle";
			if ((velocity.x != 0 || velocity.y != 0)) action = "walk";
			isMoving = velocity.x == 0 && velocity.x == 0 ? false : true;
		} else {
			if (parent.movementHistory.length > 30) {
				isMoving = true;
				var movement = parent.movementHistory.shift();
				facing = movement.facing;
				action = movement.action;
				animation.timeScale = movement.timeScale;
				x = movement.x;
				y = movement.y;
			} else {
				action = "idle";
				isMoving = false;
			}
		}
		if (isMoving) {
			movementHistory.push({
				x: this.x,
				y: this.y,
				facing: this.facing,
				action: this.action,
				timeScale: animation.timeScale,
			});
		}
		switch (facing)
		{
			case 'left':
				playAnim('l_' + action);
			case 'right':
				playAnim("r_" + action);
			case 'up':
				playAnim("u_" + action);
			case 'down':
				playAnim("d_" + action);
			default:
		}
	}
	
	public function heal(v, ?removeSound:Bool = false) {
		hp += v;
		if(!removeSound) playSound("heal");
	}
	
	public function hurt(v, ?removeSound:Bool = false, ?customShake:Int = 10) {
		hp -= v;
		playAnim("hurt");
		if(!removeSound) playSound("hurt");
		shake = customShake;
	}
}