import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import flixel.text.FlxTextBorderStyle;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
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

public var characters:Map = [];
importScript("data/chars/kris");
importScript("data/chars/ralsei");

public var camUI = new FlxCamera(0, 0, FlxG.width, FlxG.height);
for (u in [camUI]) {
	u.bgColor = 0;
	FlxG.cameras.add(u, false);
}

public var tilesets = [];
public var layers = ["w" => "a"];
public var worldBounds = [0,0,0,0];

function create(){
	loadRoom("test2");
	

	
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
	dialouge.fieldWidth = overworldDialougeBox.width - (100 - dialouge.offset.x);
	if (keys.MENU) FlxG.resetState();
	for (i=>character in characters) {
		var follow = (i - 1) < 0 ? null : characters[i - 1];
		for (name=>layer in layers) {
			if(name == "walls") FlxG.collide(characters, layer);
		}
		
		character.overworldUpdate(follow, keys);
		character.x = FlxMath.bound(character.x, worldBounds[0], worldBounds[2]);
		character.y = FlxMath.bound(character.y, worldBounds[1], worldBounds[3]);
	}
	members.sort((obj1, obj2) -> {
	    if ((obj1.y) < (obj2.y))
	        return -1;
	    else if ((obj1.y) > (obj2.y))
	        return 1;
	    else
	        return 0;
	}, -1);
	FlxG.camera.follow(characters[0]);
}

function loadRoom(roomName){
	var scale = 2;
	var roomXmlString = Assets.getText(Paths.file("data/rooms/" + roomName + ".tmx"));
    var roomXml = Xml.parse(roomXmlString);
    var mapElement = roomXml.firstElement();
    var mapWidth = Std.parseInt(mapElement.get("width"));
    var mapHeight = Std.parseInt(mapElement.get("height"));
    var tileWidth = Std.parseInt(mapElement.get("tilewidth"))*scale;
    var tileHeight = Std.parseInt(mapElement.get("tileheight"))*scale;
	worldBounds = [0,0,(mapWidth-1)*tileWidth,(mapHeight-1)*tileHeight];
	//FlxG.worldBounds.set(0,0,(mapWidth-1)*tileWidth, (mapHeight-1)*tileHeight);

	camera.minScrollY = 0;
	camera.maxScrollX = mapWidth*tileWidth;
	camera.minScrollX = 0;
	camera.maxScrollY = mapHeight*tileHeight;
	for (element in mapElement.elements()) {
        switch (element.nodeName) {
            case "tileset":
                var firstgid = element.get("firstgid");
				var source = element.get("source");
				var tilesetXmlString = Assets.getText(Paths.file("data/tilesets/" + source));
				var tilesetXml = Xml.parse(tilesetXmlString);
				var tilesetElement = tilesetXml.firstElement();
				image = tilesetElement.firstElement();
				if (image.nodeName == "image") {
					var source = image.get("source");
					tileset = new FlxSprite().loadGraphic(Paths.image(source.replace('../../images/', '').replace('.png', '')),true,tilesetElement.get("tilewidth"),tilesetElement.get("tileheight"));
					add(tileset);
					tilesets[firstgid] = tileset;
				}
            case "group":
                var layerName = element.get("name");
				var layerGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

		        for (sprite in element.elements()) if (sprite.nodeName == "imagelayer") {
					var x = Std.parseFloat(sprite.get("offsetx"));
		      	    var y = Std.parseFloat(sprite.get("offsety"));
					image = sprite.firstElement();
		            if (image.nodeName == "image") {
		                var source = image.get("source");
						var width = Std.parseFloat(image.get("width"));
		      		    var height = Std.parseFloat(image.get("height"));
	         		    sprite = new FlxSprite(x*scale,y*scale).loadGraphic(Paths.image(source.replace('../../images/', '').replace('.png', '')));
			        	layerGroup.add(sprite);
						sprite.setGraphicSize(width*scale, height*scale);
						sprite.updateHitbox();
		            }
		        }
				add(layerGroup);
				if (layerGroup.length > 0) layers[layerName] = layerGroup;
            case "layer":
	            var tilesetID = element.exists("tilesetgid") ? element.get("tilesetgid") : "1";
				var layerName = element.get("name");
				var layerGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
                var tileArray = parseRawToArray(element.firstElement().firstChild().toString(), mapWidth); // From layer => data => values => String

                for(y=>row in tileArray) for(x=>til in row) if(til > 0){
					tile = new FlxSprite(tileWidth*x,tileHeight*y).loadGraphicFromSprite(tilesets[tilesetID]);
		        	tile.animation.add("idle",[til-1],1,true);
					//tile.visible = layerName != "walls";
		        	layerGroup.add(tile);
					tile.immovable = true;
		        	tile.animation.play("idle");
					tile.setGraphicSize(tileWidth, tileHeight);
					tile.updateHitbox();
				}
				add(layerGroup);
				if (layerGroup.length > 0) layers.set(layerName, layerGroup);

			case "objectgroup":
				if(element.get("name") == "playerSpawn") { for (character in characters) add(character); }
        }
    }
    if (Assets.exists("data/rooms/" + roomName + ".hx")) importScript("data/rooms/" + roomName);
}

/** 
 * [Parses the raw string of tiles proportioned with its width, to an Array]
 * @param str String containing all the tiles.
 * @param width Width in tiles of the map.
 * 
 * @returns Array
 */
function parseRawToArray(str:Array, width:Float)
{
    //var cleanData = StringTools.trim(csvData);	
    var rows = [];
    var result = [];
	var _count:Int = 0;
	var _from:Int = 0;
	for(idx in 0...str.length) if(str.charAt(idx) == ",") {
		_count++;
		if(_count%width==0 && _count != 0) {
			rows.push(str.substring(_from > 0 ? _from+1 : _from, idx));
			 _from = idx;
		}	
	}

    for (i=>row in rows) {
        var tiles = row.split(",");
        var parsedRow = [];
        for (til in tiles) parsedRow.push(Std.parseInt(til));
        result.push(parsedRow);
    }
    return result;
}

/**
 * TODO:
 * [] Define change room system
 * [] Compatibility with multiple tilesets
 * [X] Improve Z index of sprites 
 * [] Animated sprites support
 * [] UI & menu
 * [] Health
 * [] Save data system
 * [] Fix Ralsei's hitbox
 */
