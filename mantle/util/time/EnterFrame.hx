package mantle.util.time;

import msignal.Signal;

#if openfl

import openfl.display.Shape;

#elseif flash

import flash.display.Shape;

#else

import mantle.util.sys.SysTools;

#end

#if cpp
	import mantle.util.time.FrameThread;
#end

/**
 * Cross-platform way of listening to enter frame events.
 * 
 * @author Thomas Byrne
 */
class EnterFrame
{
	public static function add(listener:Void -> Void):Void {
		signal.add(listener);
	}
	public static function remove(listener:Void -> Void):Void {
		signal.remove(listener);
	}
	
	public static function addDelta(listener:Int -> Void):Void {
		deltaSignal.add(listener);
	}
	public static function removeDelta(listener:Int -> Void):Void {
		deltaSignal.remove(listener);
	}
	
	public static var signal(get, null):Signal0;
	public static function get_signal():Signal0 {
		if (_signal==null) {
			_signal = new Signal0();
			setupListener();
		}
		return _signal;
	}
	
	public static var deltaSignal(get, null):Signal1<Int>;
	public static function get_deltaSignal():Signal1<Int> {
		if (_deltaSignal==null) {
			_deltaSignal = new Signal1();
			setupListener();
		}
		return _deltaSignal;
	}
	
	static private function onEnterFrame():Void 
	{
		var newT:Int = getTimer();
		if(_signal!=null)_signal.dispatch();
		if(_deltaSignal!=null)_deltaSignal.dispatch(newT - _lastT);
		_lastT = newT;
	}
	
	private static var _signal:Signal0;
	private static var _deltaSignal:Signal1<Int>;
	private static var _lastT:Int;
	private static var _delayPool:Array<DelayTracker>;
	
	#if flash
	static var _exit:Signal0;
	static public var exit(get, null):Signal0;
	static function get_exit():Signal0 {
		if (_exit == null){
			setupListener();
			shape.addEventListener(flash.events.Event.EXIT_FRAME, function(e:flash.events.Event) { _exit.dispatch(); } );
			_exit = new Signal0();
		}
		return _exit;
	}
	#end
	
	#if (flash || openfl)
	private static var shape:Shape;
	#end
	
	static private function setupListener():Void
	{
		#if (flash || openfl)
			shape = new Shape();
			shape.addEventListener(flash.events.Event.ENTER_FRAME, function(e:flash.events.Event) { onEnterFrame(); } );
			#if !flash
				// other targets don't dispatch this event unless added to stage
				openfl.Lib.current.stage.addChild(shape);
			#end
		#elseif cpp
			mantle.util.time.FrameThread.instance.addFrame(onEnterFrame);
		#end
		_lastT = getTimer();
	}
	
	inline static public function getTimer():Int {
		#if openfl
			return openfl.Lib.getTimer();
		#elseif flash
			return flash.Lib.getTimer();
		#else
			return Std.int(SysTools.time() * 1000);
		#end
	}
	
	inline static public function getFPS():Float {
		#if openfl
			return openfl.Lib.current.stage.frameRate;
		#elseif flash
			return flash.Lib.current.stage.frameRate;
		#else
			return mantle.util.time.FrameThread.instance.fps;
		#end
	}
	
	static public function delay(handler:Void->Void, frames:Int=1) 
	{
		if (frames == 1) {
			signal.addOnce(handler);
		}else {
			var delay:DelayTracker = getDelay(handler, frames);
			signal.add(delay.handleFrame);
		}
	}
	
	inline static private function getDelay(handler:Void->Void, frames:Int) 
	{
		var delay:DelayTracker;
		if (_delayPool!=null && _delayPool.length>0) {
			delay = _delayPool.pop();
		}else {
			delay = new DelayTracker();
		}
		delay.remaining = frames;
		delay.handler = handler;
		delay.finished = onDelayFinished;
		return delay;
	}
	
	static private function onDelayFinished(delay:DelayTracker) 
	{
		if (_delayPool == null)_delayPool = [];
		delay.finished = null;
		delay.handler = null;
		_delayPool.push(delay);
		_signal.remove(delay.handleFrame);
	}
	
}

class DelayTracker
{
	public var remaining:Int;
	public var handler:Void->Void;
	public var finished:DelayTracker->Void;
	
	public function new() {
		
	}
	
	public function handleFrame() 
	{
		remaining--;
		if (remaining == 0) {
			handler();
			finished(this);
		}
	}
}
