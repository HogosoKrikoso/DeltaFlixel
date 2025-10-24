class DeltaCharacter extends FunkinSprite
{
	public var name = "";
	public var icon = "";
	public var hp = 0;
	public var maxHP = 0;
	public var color = FlxColor.WHITE;
	public var choices = [0,0,0,0,0,0];
	public var canMagic = false;
	public var baseSpells = [];
	public var shake = 0;
	
	public inline var baseSpeed:Float = 200;
	public var facing = "down";
	public var isMoving:Bool;
	public var canMove:Bool = true;
	public var action:String = "idle";
	
	public function new(_name, _icon, _spritesheet, _animations, _scale, _hp, _color, _canMagic, _baseSpells) { 
		super();
		name = _name;
		icon = _icon;
		hp = _hp;
		maxHP = _hp;
		color = _color;
		canMagic = _canMagic;
		if(canMagic)
			baseSpells = _baseSpells;
		frames = Paths.getFrames(_spritesheet);
		scale.set(_scale,_scale);
		for (anim in _animations) {
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
	public function overworldUpdate(follow, controls){
		speed = baseSpeed;
		
		var up:Bool = controls.UP;
		var down:Bool = controls.DOWN;
		var left:Bool = controls.LEFT;
		var right:Bool = controls.RIGHT;

		if ((FlxG.keys.pressed.SHIFT || controls.BACK_HOLD) && action == "walk"){ 
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
			// ------- Sprite animation ---------
		action = "idle";
		// check if the player is moving, and not walking into walls
		if ((velocity.x != 0 || velocity.y != 0)) action = "walk";
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
		isMoving = velocity.x == 0 && velocity.x == 0 ? false : true;
	}
}