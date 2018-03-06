package mantle.time;

import haxe.Timer;
import lime.app.Application;
import mantle.notifier.Notifier;

#if flash
import flash.Lib;
import flash.events.Event;
#end
/**
 * ...
 * @author P.J.Shand
 */
class EnterFrame
{
	private static var callbacks = new Array<Void->Void>();
	private static var running:Notifier<Bool>;
	
	static function __init__() 
	{
		running = new Notifier<Bool>(false);
		running.change.add(OnRunningChange);
	}
	
	static function OnRunningChange() 
	{
		trace("running.value = " + running.value);
		if (running.value) {
			#if flash
				Lib.current.stage.addEventListener(Event.ENTER_FRAME, Update);
			#else
				OnTick();
			#end
		}
		else {
			#if flash
				Lib.current.stage.removeEventListener(Event.ENTER_FRAME, Update);
			#end
		}
	}
	
	#if flash
	static private inline function Update(e:Event):Void 
	{
		OnTick();
	} 
	#end
	
	private static inline function OnTick():Void
	{
		//trace("OnTick");
		for (i in 0...callbacks.length) 
		{
			callbacks[i]();
		}
		
		#if (!flash)
			if (running.value) Timer.delay(OnTick, Std.int(1000 / Application.current.frameRate));
		#end
	}
	
	static public function add(callback:Void->Void):Void 
	{
		trace("add");
		running.value = true;
		callbacks.push(callback);
	}
	
	static public function addAt(callback:Void->Void, index:Int):Void 
	{
		running.value = true;
		callbacks.insert(index, callback);
	}
	
	static public function remove(callback:Void->Void):Void 
	{
		var i:Int = callbacks.length - 1;
		while (i >= 0) 
		{
			if (callbacks[i] == callback) {
				callbacks.splice(i, 1);
			}
			i--;
		}
		if (callbacks.length == 0){
			running.value = false;
		}
	}
}