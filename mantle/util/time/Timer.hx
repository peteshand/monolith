package mantle.util.time;
import mantle.util.time.Timer.Interval;


/**
 * More accurate version of built in time functions.
 * 
 * @author Thomas Byrne
 */
class Timer 
{
	/**
	 * This is the amount of milliseconds before an interval
	 * is meant to happen that we still call it (a little
	 * early is better than very late).
	 * 
	 */
	private static var PREEMPT_MS:Int = 10;
	
	
	static private var nextId:UInt = 1; // start at 1 so that accidental clearTimeout(0) doesn't do anything (uninited timer id variable)
	static private var inited:Bool;
	static private var next:Interval;
	static private var pool:Interval;
	static private var intervalLookup:Map<UInt, Interval>;
	
	static public var verbose:Bool = false;
	
	static private function init():Void 
	{
		if (inited) return;
		inited = true;
		intervalLookup = new Map();
		EnterFrame.add(onEnterFrame);
	}
	
	
	static public function getTimer() : Float
	{
		//Logger.info(Timer, "getTimer: "+isRunning+" "+baseTime+" "+EnterFrame.getTimer());
		return (isRunning ? baseTime : EnterFrame.getTimer());
	}
	
	static private function addInterval(atTime:Float, closure:Void -> Void, ?repeatEvery:Int):Interval 
	{
		var ret:Interval;
		if (pool!=null) {
			ret = pool;
			pool = ret.next;
			if(ret.next!=null){
				ret.next.prev = null;
				ret.next = null;
			}
			
		}else ret = new Interval();
		
		Logger.info(Timer, "addInterval: " + atTime+" " + EnterFrame.getTimer() + " " + repeatEvery);
		var now = EnterFrame.getTimer();
		if (atTime < now){
			Logger.warn(Timer, "Interval added in past");
			if (repeatEvery != null){
				atTime = now + repeatEvery - ((now - atTime) % repeatEvery);
			}/*else{
				closure();
				return null;
			}*/
		}
		
		ret.id = nextId++;
		ret.atTime = atTime;
		ret.closure = closure;
		ret.repeatEvery = repeatEvery;
		ret.doRepeat = (repeatEvery!=null);
		intervalLookup.set(ret.id, ret);
		
		next = assignInterval(next, ret);
		
		return ret;
	}
	
	inline static private function assignInterval(head:Interval, interval:Interval):Interval 
	{
		if (head==null) {
			head = interval;
		}else {
			var prev:Interval = null;
			var next:Interval = head;
			while (next!=null && next.atTime <= interval.atTime) {
				prev = next;
				next = next.next;
			}
			interval.next = next;
			interval.prev = prev;
			if (prev==null) {
				head = interval;
			}else {
				prev.next = interval;
			}
			if (next!=null) {
				next.prev = interval;
			}
		}
		return head;
	}
	
	inline static private function assignPool(head:Interval, interval:Interval):Interval 
	{
		if (head!=null) {
			head.prev = interval;
			interval.next = head;
		}
		return interval;
	}
	
	inline static private function recycleInterval(interval:Interval):Void 
	{
		interval.closure = null;
		intervalLookup.remove(interval.id);
		pool = assignPool(pool, interval);
	}
	
	private static var isRunning:Bool;
	private static var baseTime:Float;
	private static var lastLogged:Float;
	
	static private function onEnterFrame():Void 
	{
		
		startCheck();
		var time:Float = EnterFrame.getTimer() + PREEMPT_MS;
		var closure:Void->Void;
		
		if (Math.isNaN(lastLogged) || time - lastLogged >= 10000) {
			if(next!=null){
				Logger.log(Timer, "Next: " + next.atTime, time, timeoutCount, intervalCount);
			}else {
				Logger.log(Timer, "Next: -", time, timeoutCount, intervalCount);
			}
			lastLogged = time;
		}
		
		while (next!=null && next.atTime <= time) {
			var interval:Interval = next;
			next = interval.next;
			if (next!=null) next.prev = null;
			interval.next = null;
			
			closure = interval.closure;
			
			baseTime = interval.atTime;
			
			if (interval.doRepeat) {
				interval.atTime = interval.atTime + interval.repeatEvery;
				next = assignInterval(next, interval);
			}else {
				--timeoutCount;
				recycleInterval(interval);
			}
			
			isRunning = true;
			closure();
			isRunning = false;
		}
	}
	
	static private var nextWas:Interval;
	static private function startCheck() 
	{
		nextWas = next;
	}
	
	static private var timeoutCount:Int = 0;
	static private var intervalCount:Int = 0;
	
	public static function setTimeout(closure:Void->Void, delay:Float):UInt {
		init();
		timeoutCount++;
		var atTime = Timer.getTimer() + delay;
		var interval = addInterval(atTime, closure);
		if (interval == null){
			return -1;
		}
		return interval.id;
	}
	
	public static function clearTimeout(id:UInt):Void {
		startCheck();
		//checkTimes("clearTimeout 1");
		if (!inited) return;
		var interval:Interval = intervalLookup[id];
		if (interval==null) return;
		if (interval.prev!=null) {
			interval.prev.next = interval.next;
			if (interval.next!=null) {
				interval.next.prev = interval.prev;
				interval.next = null;
			}
			interval.prev = null;
		}else {
			next = interval.next;
			if (interval.next!=null) {
				next.prev = null;
			}
			interval.next = null;
		}
		if(!interval.doRepeat){
			--timeoutCount;
		}else {
			--intervalCount;
		}
		recycleInterval(interval);
	}
	
	public static function setInterval(closure:Void -> Void, delay:Float):UInt {
		startCheck();
		init();
		++intervalCount;
		var now = Timer.getTimer();
		var atTime = now + delay;
		Logger.info(Timer, "setInterval: " + now + " " + delay);
		var interval = addInterval(atTime, closure, Std.int(delay));
		if (interval == null){
			return -1;
		}
		var ret = interval.id;
		return ret;
	}
	
	public static function clearInterval(id:UInt):Void {
		clearTimeout(id);
	}
	
	
	/**
	 * Instance API
	 */
	
	@:isVar public var delay(default, set):Int = -1; // in ms
	function set_delay(value:Int):Int{
		if (delay == value) return value;
		delay = value;
		restart();
		return value;
	}
	
	public var running(get, null):Bool;
	function get_running():Bool{
		return (delayId != -1);
	}
	
	var repeatCount:Int = 1;
	
	var delayId:Int = -1;
	var startedDelayAt:Float = -1;
	var intervalDelay:Int = -1;
	var pauseTimeElapsed:Int;
	var repeated:Int = 0;
	var onTickHandler:Void->Void;
	
	public function new(?onTick:Void->Void, ?ms:Int) 
	{
		if (onTick != null) this.onTick(onTick);
		if (ms != null) this.ms(ms);
	}
	public function ms(value:Int) : Timer
	{
		delay = value;
		return this;
	}
	public function secs(value:Float) : Timer
	{
		delay = Std.int(value * 1000);
		return this;
	}
	public function mins(value:Float) : Timer
	{
		delay = Std.int(value * 60 * 1000);
		return this;
	}
	public function repeat(repeat:Int=0) : Timer
	{
		this.repeatCount = repeat;
		return this;
	}
	public function noRepeat() : Timer
	{
		this.repeatCount = 1;
		return this;
	}
	public function onTick(onTickHandler:Void->Void) : Timer
	{
		this.onTickHandler = onTickHandler;
		return this;
	}
	
	
	function restart() 
	{
		if (delayId == -1) return;
		pause();
		go();
	}
	public function go(resetRepeat:Bool=true) :Timer
	{
		if (delayId != -1) return this;
		if (delay == -1) throw "Can't start timer before setting delay";
		
		if (resetRepeat){
			repeated = 0;
		}else if (repeatCount > 0 && repeated >= repeatCount){
			return this;
		}
		while (pauseTimeElapsed > delay){
			pauseTimeElapsed -= delay;
		}
		startedDelayAt = Timer.getTimer();
		intervalDelay = delay - pauseTimeElapsed;
		delayId = Timer.setInterval(onTimerTick, intervalDelay);
		pauseTimeElapsed = 0;
		return this;
	}
	public function stop() :Timer
	{
		pauseTimeElapsed = 0;
		if (delayId == -1)return this;
		Timer.clearInterval(delayId);
		delayId = -1;
		return this;
	}
	public function pause() :Timer
	{
		if (delayId == -1) return this;
		pauseTimeElapsed = cast (Timer.getTimer() - startedDelayAt);
		Timer.clearInterval(delayId);
		delayId = -1;
		return this;
	}
	
	public function reset() 
	{
		if (delayId == -1){
			stop();
		}else{
			stop().go();
		}
	}
	
	
	function onTimerTick() 
	{
		repeated++;
		if (repeatCount > 0 && repeated >= repeatCount){
			stop();
			repeated = 0;
		}else if (intervalDelay != delay){
			stop();
			go(false);
		}
		
		if (onTickHandler != null) onTickHandler();
	}
}


class Interval {
	
	public var id:UInt;
	public var atTime:Float;
	public var closure:Void -> Void;
	public var repeatEvery:Int;
	public var doRepeat:Bool;
	
	public var prev:Interval;
	public var next:Interval;
	
	public function new() {
	}
}