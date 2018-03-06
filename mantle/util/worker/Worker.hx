package mantle.util.worker;

/**
 * ...
 * @author Thomas Byrne
 */

#if flash
@:forward()
abstract Worker(flash.system.Worker) to flash.system.Worker from flash.system.Worker
{
	public static var isSupported(get, null):Bool;
	static function get_isSupported():Bool
	{
		return flash.system.Worker.isSupported;
	}
	
	public static var current(get, null):Worker;
	static function get_current():Worker
	{
		return flash.system.Worker.current;
	}
	
	public static function registerClass(alias:String, type:Class<Dynamic>): Void {
		haxe.remoting.AMFConnection.registerClassAlias(alias, type);
	}
}

#else
class Worker
{

	public static var isSupported(get, null):Bool;
	static function get_isSupported():Bool
	{
		return false;
	}
	
	public static function registerClass(alias:String, type:Class<Dynamic>): Void {
		// ignore
	}
	
}
#end