package robotlegs.extensions.impl.services.keyboard;
import robotlegs.extensions.impl.services.keyboard.KeyboardMap;

/**
 * ...
 * @author P.J.Shand
 */
@:keepSub
class BoolMap 
{
	private var keyboardMap:KeyboardMap;
	private var property:String;
	private var object:Dynamic;
	
	public function new(keyboardMap:KeyboardMap) 
	{
		this.keyboardMap = keyboardMap;
		
	}
	
	public function map(object:Dynamic, property:String, charOrKeycode:Dynamic, options:Dynamic = null):Void 
	{
		this.object = object;
		this.property = property;
		
		var pressOptions:Dynamic = {};
		var releaseOptions:Dynamic = {};
		if (options != null) {
			var fields = Reflect.fields (options);
			for (prop in fields) {
				Reflect.setProperty(pressOptions, prop, Reflect.getProperty(options, prop));
				Reflect.setProperty(releaseOptions, prop, Reflect.getProperty(options, prop));
			}
		}
		
		Reflect.setProperty(pressOptions, 'action', KeyboardMap.ACTION_DOWN);
		Reflect.setProperty(releaseOptions, 'action', KeyboardMap.ACTION_UP);
		
		keyboardMap.map(OnPress, charOrKeycode, pressOptions );
		keyboardMap.map(OnRelease, charOrKeycode, releaseOptions );
	}
	
	private function OnPress():Void 
	{
		Reflect.setProperty(object, property, true);
	}
	
	private function OnRelease():Void 
	{
		Reflect.setProperty(object, property, false);
	}	
}