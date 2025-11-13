class OptionText extends FlxText
{
	public var save:Dynamic = DeltaFlixelOptions.data;
	public var name:String = "example";
	public var displayName:String = "Example";
	public var type:String = "";
	var inMenuValue:Float;
	public var value;
	public var min = 0;
	public var max = 10;
	public var step = 1;
	public var strings = ["A", "B", "C"];
	public var func;
	public function new(DisplayName = "Example", Type:String = "", ?Data, Save:Dynamic = DeltaFlixelOptions.data, Name:String = "example")
	{
		super();
		setFormat(Paths.font("main.ttf"), 48, FlxColor.WHITE, "center");
		save = Save;
		displayName = DisplayName;
		type = Type;
		name = Name;
		if (Data != null) {
			if (type == "int" || type == "float") {
				if(Data.step != null && type == "float") step = Data.step;
				if(Data.min != null) min = Data.min;
				if(Data.max != null) max = Data.max;
			} else if(type == "string") {
				strings = Data;
				min = 0;
				max = strings.length-1;
			} else if(type != "bool") {
				func = Data;
			}
		}
		if (type != "string") inMenuValue = Reflect.field(save, name);
		else inMenuValue = getIDFromString(Reflect.field(save, name), strings);
	}
	public function update()
	{
		if (type != "int" || type != "float" || type != "string") {
			if (type == "string") value = strings[inMenuValue];
			else value = inMenuValue;
			var otherValue = Reflect.field(save, name);
			if (otherValue != value) {
				Reflect.setField(save, name, value);
			}
		}
		text = displayName;
		if (type == "bool") text += ": " + (value ? "ON" : "OFF");
		if (type == "int" || type == "float" || type == "string") text += ": " + value;
	}
	public function stepNum(num = 0)
	{
		inMenuValue = inMenuValue + (step*num);
		if (inMenuValue > max) inMenuValue = min;
		if (inMenuValue < min) inMenuValue = max;
		playSound("menu/scroll", true);
	}
	public function swapBool()
	{
		inMenuValue = !inMenuValue;
		playSound("menu/scroll", true);
	}
}
