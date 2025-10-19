public function createCharacter(_name, _icon, _spritesheet, _animations, _scale, _hp, _color, _canMagic, _baseSpells)
	return new DeltaCharacter(_name, _icon, _spritesheet, _animations, _scale, _hp, _color, _canMagic, _baseSpells);

class DeltaCharacter
{
	public var name = "";
	public var icon = "";
	public var hp = 0;
	public var maxHP = 0;
	public var color = FlxColor.WHITE;
	public var choices = [0,0,0,0,0,0];
	public var canMagic = false;
	public var baseSpells = [];
	public var sprite:FunkinSprite;
	public var shake = 0;
	public function new(_name, _icon, _spritesheet, _animations, _scale, _hp, _color, _canMagic, _baseSpells) { 
		name = _name;
		icon = _icon;
		hp = _hp;
		maxHP = _hp;
		color = _color;
		canMagic = _canMagic;
		if(canMagic)
			baseSpells = _baseSpells;
		sprite = new FunkinSprite(-1000,-1000,Paths.image(_spritesheet));
		sprite.scale.set(_scale,_scale);
		for (anim in _animations) {
			var autoIndices = [];
			if (anim.endFrame != null) for (i in 0...(anim.endFrame + 1))
				autoIndices.push(i);
			sprite.addAnim(anim.name, anim.prefix, anim.fps, anim.loop, false, anim.indices == null ? autoIndices : anim.indices);
			if (anim.offset != null)
				sprite.addOffset(anim.name, anim.offset[0], anim.offset[1]);
			else
				sprite.addOffset(anim.name, 0,0);
		}
		sprite.playAnim('idle');
		sprite.updateHitbox();
		sprite.camera = overworldFront;
		sprite.offset.set(0,0);
	}
}


public function createEnemy(_name, _spritesheet, _animations, _scale, _hp, _acts)
	return new DeltaEnemy(_name, _spritesheet, _animations, _scale, _hp, _acts);

class DeltaEnemy
{
	public var name = "";
	public var hp = 0;
	public var maxHP = 0;
	public var acts:Map<String, Array> = [];
	public var spare = 0;
	public var sprite:FunkinSprite;
	public var shake = 0;
	public function new(_name, _spritesheet, _animations, _scale, _hp, _acts) { 
		name = _name;
		hp = _hp;
		maxHP = _hp;
		acts = _acts;
		sprite = new FunkinSprite(-1000,-1000,Paths.image(_spritesheet));
		sprite.scale.set(_scale,_scale);
		for (anim in _animations) {
			var autoIndices = [];
			if (anim.endFrame != null) for (i in 0...(anim.endFrame + 1))
				autoIndices.push(i);
			sprite.addAnim(anim.name, anim.prefix, anim.fps, anim.loop, false, anim.indices == null ? autoIndices : anim.indices);
			if (anim.offset != null)
				sprite.addOffset(anim.name, anim.offset[0], anim.offset[1]);
			else
				sprite.addOffset(anim.name, 0,0);
		}
		sprite.playAnim('idle');
		sprite.updateHitbox();
		sprite.camera = overworldFront;
		sprite.offset.set(0,0);
	}
}