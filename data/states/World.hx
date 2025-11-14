import flixel.tile.FlxTileroom;
import flixel.util.FlxDirectionFlags;
import flixel.text.FlxTextBorderStyle;
import flixel.tile.FlxBaseTileroom.FlxTileroomAutoTiling;
import flixel.graphics.frames.FlxTileFrames;
import flixel.addons.util.FlxSimplex;
import funkin.editors.EditorPicker;
import funkin.menus.ModSwitchMenu;
import funkin.menus.credits.CreditsMain;
import funkin.options.OptionsMenu;
import flixel.util.FlxDirectionFlags;
import Xml;
import flixel.util.FlxSort;

using StringTools;

importScript("data/scripts/eventSystem");

public var characters = [];

public var camUI = new FlxCamera(0, 0, FlxG.width, FlxG.height);
for (u in [camUI]) {
	u.bgColor = 0;
	FlxG.cameras.add(u, false);
}

public var tilesets = [];
public var tilemaps = [];
public var sprites = [];
public var spawnPoints = [];
public var worldBounds = [0,0,0,0];

function create(){
	loadRoom("test");
	
	importScript("data/chars/kris");
	importScript("data/chars/ralsei");
	
	for (character in characters) {
		character.x = spawnPoints["main"].x
		character.y = spawnPoints["main"].y
		add(character);
	}
	
	overworldDialougeBox = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/dialouge/textBox"));
	overworldDialougeBox.scale.set(2,2);
	overworldDialougeBox.updateHitbox();
	overworldDialougeBox.screenCenter(FlxAxes.X).y = FlxG.height - (overworldDialougeBox.height + 20);
	overworldDialougeBox.cameras = [camUI];
	add(overworldDialougeBox);
	
	dialouge = new FlxText(overworldDialougeBox.x + 50, overworldDialougeBox.y + 50).setFormat(Paths.font("main.ttf"), 56, FlxColor.WHITE, "left");
	dialouge.cameras = [camUI];
	add(dialouge);
	
	portrait = new FlxSprite(dialouge.x, dialouge.y);
	portrait.cameras = [camUI];
	add(portrait);
	
	portrait.visible = dialouge.visible = overworldDialougeBox.visible = false;
}

function update(){
	if (keys.MENU) FlxG.resetState();
	dialouge.fieldWidth = overworldDialougeBox.width - (100 - dialouge.offset.x);
	for (i=>character in characters) {
		var follow = (i - 1) < 0 ? null : characters[i - 1];
		character.overworldUpdate(follow);
		character.x = FlxMath.bound(character.x, worldBounds[0], worldBounds[2]);
		character.y = FlxMath.bound(character.y, worldBounds[1], worldBounds[3]);
	}
	for (name=>tilemap in tilemaps) {
		if(name == "walls") FlxG.collide(characters, tilemap);
	}
	members.sort((obj1, obj2) -> {
	    if ((obj1.y) < (obj2.y))
	        return -1;
	    else if ((obj1.y) > (obj2.y))
	        return 1;
	    else
	        return 0;
	}, -1);
	if(characters[0] != null) FlxG.camera.follow(characters[0]);
}

function loadRoom(roomName){
	var roomXmlString = Assets.getText(Paths.xml("rooms/" + roomName));
    var roomXml = Xml.parse(roomXmlString);
    var roomElement = roomXml.firstElement();
    var roomWidth = Std.parseInt(roomElement.get("width"));
    var roomHeight = Std.parseInt(roomElement.get("height"));
    var tileWidth = Std.parseInt(roomElement.get("tilewidth"))*2;
    var tileHeight = Std.parseInt(roomElement.get("tileheight"))*2;
	worldBounds = [0,0,(roomWidth-1)*tileWidth,(roomHeight-1)*tileHeight];
	camera.minScrollY = 0;
	camera.maxScrollX = roomWidth*tileWidth;
	camera.minScrollX = 0;
	camera.maxScrollY = roomHeight*tileHeight;
	for (element in roomElement.elements()) {
        switch (element.elementName) {
        	case "tileset":
        		var name = element.get("name");
				var path = element.get("path");
				tileset = new FlxSprite().loadGraphic(Paths.image(path),true,element.get("tilewidth"),element.get("tileheight"));
				tilesets[name] = tileset;
            case "sprite":
	            var name = element.get("name");
                var sprite = createSpriteFromXMLElement(element);
                add(sprite);
                sprites[name] = sprite;
            case "spawn":
	            var name = element.get("name");
                var pos = {
                	x: element.get("x"),
              	  y: element.get("y")
                };
                spawnPoints[name] = pos;
            case "tilemap":
	            var tileset = element.exists("tileset") ? tilesets[element.get("tileset")] : 0;
				var name = element.get("name");
				var group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
                var tileArray = parseTilemapData(element.get("data"), roomWidth);
                for(y=>row in tileArray) for(x=>til in row) if(til > 0){
					tile = new FlxSprite(tileWidth*x,tileHeight*y);
					if (tileset != 0) tile.loadGraphicFromSprite(tileset);
		        	tile.animation.add("idle",[til-1],1,true);
					tile.alpha = name != "walls" ? 1 : 0.001;
		        	group.add(tile);
					tile.immovable = true;
		        	tile.animation.play("idle");
					tile.setGraphicSize(tileWidth, tileHeight);
					tile.updateHitbox();
				}
				add(group);
				if (group.length > 0) tilemaps[name] = group;
        }
    }
    if (Assets.exists("data/rooms/" + roomName + ".hx")) importScript("data/rooms/" + roomName);
}

function parseTilemapData(str, width)
{
    var tiles = str.split(",");
    var row = [];
    var result = [];
    for (tile in tiles) {
        row.push(Std.parseInt(tile));
        if (row.length >= width) {
    		result.push(row);
			row = [];
		}
    }
    return result;
}

function createSpriteFromXMLElement(element) {
	var spr = new FunkinSprite();
	spr.name = element.get("name");
	spr.frames = Paths.getFrames(element.get("path"));
	if (element.exists("x")) spr.x = Std.parseFloat(element.get("x"))*2;
	if (element.exists("y")) spr.y = Std.parseFloat(element.get("y"))*2;
	if (element.exists("scroll")) spr.scrollFactor.set(Std.parseFloat(element.get("scroll")), Std.parseFloat(element.get("scroll")));
	if (element.exists("scrollx")) spr.scrollFactor.x = Std.parseFloat(element.get("scrollx"));
	if (element.exists("scrolly")) spr.scrollFactor.y = Std.parseFloat(element.get("scrolly"));
	if (element.exists("skew")) spr.skew.set(Std.parseFloat(element.get("skew")), Std.parseFloat(element.get("skew")));
	if (element.exists("skewx")) spr.skew.x = Std.parseFloat(element.get("skewx"));
	if (element.exists("skewy")) spr.skew.y = Std.parseFloat(element.get("skewy"));
	if (element.exists("antialiasing")) spr.antialiasing = element.get("antialiasing") == "true";
	if (element.exists("width")) spr.width = Std.parseFloat(element.get("width"))*2;
	if (element.exists("height")) spr.width = Std.parseFloat(element.get("height"))*2;
	if (element.exists("scale")) spr.scale.set(Std.parseFloat(element.get("scale"))*2, Std.parseFloat(element.get("scale"))*2);
	if (element.exists("scalex")) spr.scale.x = Std.parseFloat(element.get("scalex"))*2;
	if (element.exists("scaley")) spr.scale.y = Std.parseFloat(element.get("scaley"))*2;
	if (element.exists("graphicSize")) spr.setGraphicSize(Std.parseInt(element.get("graphicSize"))*2, Std.parseInt(element.get("graphicSize"))*2);
	if (element.exists("graphicSizex")) spr.setGraphicSize(Std.parseInt(element.get("graphicSizex"))*2);
	if (element.exists("graphicSizey")) spr.setGraphicSize(0, Std.parseInt(element.get("graphicSizey"))*2);
	if (element.exists("flipX")) spr.flipX = element.get("flipX") == "true";
	if (element.exists("flipY")) spr.flipY = element.get("flipY") == "true";
	if (element.exists("updateHitbox") && element.get("updateHitbox") == "true") spr.updateHitbox();
	if (element.exists("zoomfactor")) spr.zoomFactor = Std.parseFloat(element.get("zoomfactor"));
	if (element.exists("alpha")) spr.alpha = Std.parseFloat(element.get("alpha"));
	if (element.exists("color")) spr.color = FlxColor.fromString(element.get("color"));
	if (element.exists("angle")) spr.angle = Std.parseFloat(element.get("angle"));
	
	return spr;
}

/**
 * TODO:
 * [] Change Room System
 * [X] Compatibility with multiple tilesets
 * [X] Improve Z index of sprites 
 * [] Animated sprites support
 * [] UI & menu
 * [] Health
 * [] Save data system
 * [] Fix Party's Hitbox
 */
