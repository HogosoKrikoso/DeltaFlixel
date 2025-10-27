import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import flixel.text.FlxTextBorderStyle;
/*import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;*/
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.graphics.frames.FlxTileFrames;
import flixel.addons.util.FlxSimplex;
import funkin.editors.EditorPicker;
import funkin.menus.ModSwitchMenu;
import funkin.menus.credits.CreditsMain;
import funkin.options.OptionsMenu;
import flixel.util.FlxDirectionFlags;

using StringTools;

importScript("data/scripts/eventSystem");

public var characters:Array = [];
var tileset;

public var camUI = new FlxCamera(0, 0, FlxG.width, FlxG.height);
for (u in [camUI]) {
	u.bgColor = 0;
	FlxG.cameras.add(u, false);
}

function create(){
	tileset = new FlxSprite().loadGraphic(Paths.image("world/field"),40,40);
	importScript("data/chars/kris");
	add(characters[0]);
	//loadMap();
	
	overworldDialougeBox = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/dialouge/textBox"));
	overworldDialougeBox.scale.set(2,2);
	overworldDialougeBox.updateHitbox();
	overworldDialougeBox.screenCenter(FlxAxes.X).y = FlxG.height - (overworldDialougeBox.height + 20);
	overworldDialougeBox.cameras = [camUI];
	add(overworldDialougeBox);
	
	dialouge = new FlxText(overworldDialougeBox.x + 50, overworldDialougeBox.y + 50).setFormat(Paths.font("determination.ttf"), 56, FlxColor.WHITE, "left", FlxTextBorderStyle.SHADOW, 0xFF000088);
	dialouge.text = "puto";
	dialouge.borderSize = 5;
	dialouge.cameras = [camUI];
	add(dialouge);
	
	portrait = new FlxSprite(dialouge.x, dialouge.y);
	portrait.cameras = [camUI];
	add(portrait);
	
	portrait.visible = dialouge.visible = overworldDialougeBox.visible = false;
}

function update(){
	dialouge.fieldWidth = overworldDialougeBox.width - (100 - dialouge.offset.x);
	if (touchPad.buttonC.justPressed) FlxG.resetState();
	characters[0].overworldUpdate(null, controls);
	FlxG.camera.follow(characters[0]);
	//FlxG.collide(player, walls);
}

/*var tilemap = new TiledMap(Paths.file('data/test.tmx'));
var decos = cast tilemap.getLayer('decos');
var tileLayer:TiledTileLayer = cast tilemap.getLayer("tile");
var tileLayer1:TiledTileLayer = cast tilemap.getLayer("walls");
var walls:FlxTypedGroup;
var decorations:FlxTypedGroup;

FlxG.worldBounds.set(0,0, tilemap.width*tilemap.tileWidth, tilemap.height*tilemap.tileHeight); 	// This line is very important bc it makes the world collisions' limit higher so it can still detect collisions with huge maps

camera.minScrollY = 0;
camera.maxScrollX = tilemap.width*tilemap.tileWidth;
camera.minScrollX = 0;
camera.maxScrollY = tilemap.height*tilemap.tileHeight;
function loadMap(){
	walls = new FlxTypedGroup<FlxSprite>();

	var counterh:Int = 0;
	var counterw:Int = 0;

	for(i=>til in tileLayer.tileArray){
		//trace(counter);
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

	for(i=>til in tileLayer1.tileArray){
		//trace(counter);
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
	add(walls);

	player = new Player(500, 500);
	add(player);

	for(layer in decos.layers){
		spr = new FlxSprite(layer.offsetX+40, layer.offsetY).loadGraphic(Paths.image(layer.imagePath.replace('../images/', '').replace('.png', '')));
		add(spr);
	}
}*/

#if mobile
addTouchPad('LEFT_FULL', 'A_B_C');
addTouchPadCamera(false);
#end