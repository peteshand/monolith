package mantle.managers.layout.scale;

#if swc
	import flash.errors.Error;
#else
	import openfl.errors.Error;
#end

/**
 * ...
 * @author P.J.Shand
 */
class ScaleSettings 
{
	public var scaleMode:String = ScaleMode.NONE;
	
	#if swc @:protected #end
	private var _hScaleMode:String;
	#if swc @:protected #end
	private var _vScaleMode:String;
	
	#if swc @:extern #end
	public var vScaleMode(get, set):String;
	#if swc @:extern #end
	public var hScaleMode(get, set):String;
	
	public function new(scaleMode:String=null) 
	{
		if (scaleMode != null) {
			this.scaleMode = scaleMode;
		}
	}		
	
	#if swc @:getter(vScaleMode) #end
	public function get_vScaleMode():String 
	{
		if (_vScaleMode == null) return scaleMode;
		return _vScaleMode;
	}
	
	#if swc @:setter(vScaleMode) #end
	public function set_vScaleMode(value:String):String 
	{
		if (value == ScaleMode.FILL || value == ScaleMode.LETTERBOX) {
			throw new Error("vScaleMode can't be set to ScaleMode." + value);
		}
		_vScaleMode = value;
		return value;
	}
	
	#if swc @:getter(hScaleMode) #end
	public function get_hScaleMode():String 
	{
		if (_hScaleMode == null) return scaleMode;
		return _hScaleMode;
	}
	
	#if swc @:setter(hScaleMode) #end
	public function set_hScaleMode(value:String):String 
	{
		if (value == ScaleMode.FILL || value == ScaleMode.LETTERBOX) {
			throw new Error("hScaleMode can't be set to ScaleMode." + value);
		}
		_hScaleMode = value;
		return value;
	}
}