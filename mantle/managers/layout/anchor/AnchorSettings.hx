package mantle.managers.layout.anchor;

#if swc
	import flash.errors.Error;
#else
	import openfl.errors.Error;
#end

/**
 * ...
 * @author P.J.Shand
 */
class AnchorSettings 
{
	#if swc @:protected #end
	private var _frame:Dynamic;
	#if swc @:protected #end
	private static var iDisplayObjectXML:Xml;
	#if swc @:protected #end
	private static var properties = new Array<String>();
	
	public var frameAnchor:FrameSettings = new FrameSettings();
	public var displayAnchor:DisplayObjectSettings = new DisplayObjectSettings();
	
	#if swc @:extern #end
	public var frame(get, set):Dynamic;
	
	public function new() 
	{
		if (iDisplayObjectXML == null) {
			properties.push("x");
			properties.push("y");
			properties.push("width");
			properties.push("height");
		}
	}
	
	#if swc @:getter(frame) #end
	public function get_frame():Dynamic 
	{
		return _frame;
	}
	
	#if swc @:setter(frame) #end
	public function set_frame(value:Dynamic):Dynamic 
	{
		checkDisplay(value);
		_frame = value;
		return value;
	}
	
	private function checkDisplay(frame:Dynamic):Void 
	{
		for (i in 0...properties.length) 
		{
			var property = properties[i];
			trace("frame[" + property + "] = " + Reflect.getProperty(_frame, property));
			if (!Reflect.hasField(_frame, property)) {
				throw new Error("Frame object must have " + property + " property");
			}
		}
	}
}