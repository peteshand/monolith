package mantle.managers.resize;

import mantle.time.EnterFrame;
import mantle.util.signals.Signal;
import openfl.display.Stage;
import openfl.events.Event;

/**
 * ...
 * @author P.J.Shand
 */
class Resize 
{
	private static var repeatResizeForXFrames:Int = 4;
	private static var resizeCount:Int = 0;
	private static var _onResize:Signal0;
	public static var onResize(get, null):Signal0;
	
	public function new(s:Stage) 
	{
		if (_onResize == null) _onResize = new Signal0();
		OnStageResize(null);
		
		EnterFrame.addAt(OnTick, 0);
		OnTick();
		
		s.addEventListener(Event.RESIZE, OnStageResize);
	}
	
	private static function get_onResize():Signal0
	{
		return _onResize;
	}
	
	private static function OnStageResize(e:Event):Void 
	{
		resizeCount = 0;
	}
	
	private static function OnTick():Void 
	{
		resizeCount++;
		if (resizeCount < repeatResizeForXFrames) {
			onResize.dispatch();
		}
	}
}