import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;

import flixel.graphics.frames.FlxTileFrames;

import flixel.addons.util.FlxSimplex;
import funkin.editors.EditorPicker;
import funkin.menus.ModSwitchMenu;
import funkin.menus.credits.CreditsMain;
import funkin.options.OptionsMenu;

import flixel.util.FlxDirectionFlags;

using StringTools;


var player:FlxSprite;
var speed:Int;

var curMusic = FlxG.sound.music;

FlxG.game.setFilters([]);

var curRoom = toRoom != null ? toRoom : 0;
var tileset;

//https://www.youtube.com/watch?v=08OMWjoCEXY&list=PLkTxsDc9_MX6p6tkjuzQVb2RfCav8Hfrg&index=64
//!------- Playstate code -----------
function create(){

	Main.scaleMode.width = 1280;
    Main.scaleMode.height = 960;

	FlxG.width = 1280; 
	FlxG.height = 960;
    
    for (c in FlxG.cameras.list) {
        c.width = 1280;
        c.height = 960;
    }

	camera.zoom = 2;
	tileset = new FlxSprite().loadGraphic(Paths.image("world/field"),40,40);

	loadMap();
}


function update(){
	player.updateMovement();
	FlxG.camera.follow(player);

	FlxG.collide(player, walls);
    FlxG.overlap(player, triggers, (c1, c2)->{
        switch(c2.name){
            case "toRoom": nextRoom(c2.extra.get("num"));
        }
    });

	if (controls.BACK) FlxG.switchState(new TitleState());
	if (controls.SWITCHMOD) openSubState(new ModSwitchMenu());

	//if((inDialog && isTyping) && controls.ACCEPT) skipDialog();
	//else if((inDialog && !isTyping) && controls.ACCEPT) finishDialog();

	//! DEV ACCESS
	if (controls.DEV_ACCESS) {
		FlxG.game.setFilters([]);
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new EditorPicker());
	}

}


//! ------- Map code ---------
var tilemap = new TiledMap(Paths.file('data/field'+curRoom+".tmx"));
var decos = cast tilemap.getLayer('decos');
var tileLayer:TiledTileLayer = cast tilemap.getLayer("tile");
var tileLayer1:TiledTileLayer = cast tilemap.getLayer("walls");
var objLayer:TiledObjectLayer = cast tilemap.getLayer("triggers");
var walls:FlxTypedGroup = new FlxTypedGroup<FlxSprite>();
var triggers:FlxTypedGroup = new FlxTypedGroup<FlxSprite>();
var decorations:FlxTypedGroup;

FlxG.worldBounds.set(0,0, tilemap.width*tilemap.tileWidth, tilemap.height*tilemap.tileHeight); 	// This line is very important bc it makes the world collisions' limit higher so it can still detect collisions with huge maps

camera.minScrollY = 0;
camera.maxScrollX = tilemap.width*tilemap.tileWidth;
camera.minScrollX = 0;
camera.maxScrollY = tilemap.height*tilemap.tileHeight;

function loadMap(){
	var counterh:Int = 0;
	var counterw:Int = 0;

	for(i=>til in tileLayer.tileArray)
    {
		if (i % tileLayer.width == 0 && i != 0){ 
			counterw = 0;
			counterh++;
		}
		counterw++;

		if(til > 0){
			tile = new FlxSprite(40*counterw,40*counterh).loadGraphicFromSprite(tileset);
        	tile.animation.add("idle",[til-1],1,true);
        	add(tile);
        	tile.animation.play("idle");
		}
		
	}

	var counterh:Int = 0;
	var counterw:Int = 0;

	for(i=>til in tileLayer1.tileArray)
    {
		if (i % tileLayer.width == 0 && i != 0){ 
			counterw = 0;
			counterh++;
		}
		counterw++;

		if(til > 0){
			tile = new FlxSprite(40*counterw,40*counterh).loadGraphicFromSprite(tileset);
        	tile.animation.add("idle",[til-1],1,true);
        	walls.add(tile);
        	tile.animation.play("idle");
			tile.immovable = true;
		}
		
	}
	

	player = new Player(500, 500);
	

	for(layer in decos.layers)
    {
		spr = new FlxSprite(layer.offsetX+tilemap.tileWidth, layer.offsetY).loadGraphic(Paths.image(layer.imagePath.replace('../images/', '').replace('.png', '')));
		add(spr);
	}

    for(obj in objLayer.objects){
		objSpr = new FunkinSprite(obj.x+tilemap.tileWidth, obj.y).makeGraphic(obj.width, obj.height, FlxColor.WHITE);
		//objSpr.visible = false;
		objSpr.immovable = true;
        objSpr.name = obj.name;
        objSpr.extra.set("num", obj.properties.get("num"));
		triggers.add(objSpr);
	}


    add(walls);
    add(player);
    add(triggers);
}

function nextRoom(target:Int){
    toRoom = target;
    trace(target);
    FlxG.resetState();
} 



//! ----- Player code ------
class Player extends FlxSprite
{
	public inline var SPEED:Float = 200;
	public var facing;
	public var isMoving:Bool;
	public var canMove:Bool = true;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		
		//loadGraphic(Paths.image('characters/bf/bf'), true, 16, 16);
		frames = Paths.getFrames('world/kris');
		animation.addByPrefix('d_idle', 'idle_overworld_down', 6);
		animation.addByPrefix('u_idle', 'idle_overworld_up', 6);
		animation.addByPrefix('l_idle', 'idle_overworld_left', 6);
		animation.addByPrefix('r_idle', 'idle_overworld_right', 6);
		animation.addByPrefix('u_walk', 'walk_overworld_up', 6);
		animation.addByPrefix('d_walk', 'walk_overworld_down', 6);
		animation.addByPrefix('l_walk', 'walk_overworld_left', 6);
		animation.addByPrefix('r_walk', 'walk_overworld_right', 6);
		animation.play('d_idle');
		scale.set(2,2);
		updateHitbox();
		height = 30;
		width = 20;
		
		centerOffsets();
		drag.x = drag.y = 5000;
		

		//setSize(8, 8);
		offset.set(0, 30);

		//animation.add("d_idle", [1]);
		//animation.add("l_idle", [7]);
		//animation.add("r_idle", [9]);
		//animation.add("u_idle", [4]);
		//animation.add("d_walk", [1, 0, 1, 2], 6);
		//animation.add("l_walk", [7, 6], 6);
		//animation.add("r_walk", [8, 9], 6);
		//animation.add("u_walk", [4, 3, 4, 5], 6);
	}

	public function updateMovement(){
		speed = SPEED;
		
		var up:Bool = FlxG.keys.pressed.W;
		var down:Bool = FlxG.keys.pressed.S;
		var left:Bool = FlxG.keys.pressed.A;
		var right:Bool = FlxG.keys.pressed.D;

		if (FlxG.keys.pressed.SHIFT){ 
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

	}

		// ------- Sprite animation ---------
	var action = "idle";
	// check if the player is moving, and not walking into walls
	if ((velocity.x != 0 || velocity.y != 0))
	{
		action = "walk";
	}
	switch (facing)
	{
		case 'left':
			animation.play('l_' + action);
		case 'right':
			animation.play("r_" + action);
		case 'up':
			animation.play("u_" + action);
		case 'down':
			animation.play("d_" + action);
		case null:
	}

	isMoving = velocity.x == 0 && velocity.x == 0 ? false : true;
}
}

