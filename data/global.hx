import funkin.backend.utils.ShaderResizeFix;
import funkin.options.Options;
import funkin.backend.system.framerate.Framerate;
import openfl.text.TextFormat;


var redirectStates:Map<FlxState, String> = [
	//BetaWarningState => "Play",
	TitleState => "Play",
];

function new() {
	setGameResolution(640, 480, true);
}

function update() {
	FlxG.updateFramerate = FlxG.drawFramerate = FlxG.save.data.thirtyLags ? 30 : 60;
}

function preStateSwitch() {
    for (redirectState in redirectStates.keys())
        if (FlxG.game._requestedState is redirectState)
            FlxG.game._requestedState = new ModState(redirectStates.get(redirectState));
}

function destroy() {
	FlxG.updateFramerate = FlxG.drawFramerate = Options.framerate;
	setGameResolution(1280, 720);
}

function setGameResolution(realWidth:Int, realHeight:Int, ?keepQuality:Bool = false){
	var scale:Float = keepQuality ? Math.min(realWidth/1280, realHeight/720) : 1;
	var width:Int = Math.floor(realWidth/scale);
	var height:Int = Math.floor(realHeight/scale);
    FlxG.resizeWindow(width, height);
    FlxG.resizeGame(width, height);
    FlxG.scaleMode.width = FlxG.width = FlxG.initialWidth = width;
    FlxG.scaleMode.height = FlxG.height = FlxG.initialHeight = height;
    ShaderResizeFix.doResizeFix = true;
    ShaderResizeFix.fixSpritesShadersSizes();
    window.x = width/2 - window.width/2;
    window.y = height/2 - window.height/2;
}

function postStateSwitch(){
    Framerate.codenameBuildField.visible = Framerate.memoryCounter.memoryPeakText.visible = Framerate.memoryCounter.memoryText.visible = false;
	Framerate.fpsCounter.fpsNum.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('PixelOperator-Bold.ttf')), 40, FlxColor.WHITE);
	Framerate.fpsCounter.fpsLabel.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('PixelOperator-Bold.ttf')), 40, FlxColor.WHITE);
}