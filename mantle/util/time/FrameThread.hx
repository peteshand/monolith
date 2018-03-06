package mantle.util.time;
import mantle.util.ds.LinkedList;
import haxe.Timer;

/**
 * FrameThread class allows Command line programs to behave like
 * frame-based applications, with tasks being scheduled for some time
 * in the future.
 * 
 * @author Thomas Byrne
 */
class FrameThread
{
	@:isVar
	static public var instance(get, null):FrameThread;
	static function get_instance():FrameThread {
		if (instance == null) {
			instance = new FrameThread();
		}
		return instance;
	}
	
	@:isVar
	public var fps(get, null):Float;
	function get_fps():Float {
		return fps;
	}
	
	
	var interval:Float;
	var time:Float;
	
	var schedule:LinkedList<ScheduleItem>;
	
	var onFrames:List<Void->Void>;

	public function new() 
	{
		this.time = 0;
		this.schedule = new LinkedList();
		this.onFrames = new List();
		
	}
	public function begin(fps:Float, ?startFunc:Void->Void) 
	{
		if (startFunc != null) {
			startFunc();
		}
		
		this.fps = fps;
		this.interval = 1 / fps;
		
		var lastFrameDur:Float = 0;
		
		while (true) {
			var sleepTime = this.interval - lastFrameDur;
			if (sleepTime > 0){
				Sys.sleep(sleepTime);
			}
			this.time += sleepTime;
			var t = Timer.stamp();
			
			for (f in onFrames) {
				f();
			}
			
			this.schedule.iterateTillTrue(executeNext, true);
			lastFrameDur = Timer.stamp() - t;
			this.time += lastFrameDur;
		}
	}
	
	public function delay(secs:Float, f:Void->Void):Void
	{
		var item:ScheduleItem = new ScheduleItem(time+secs, f);
		this.schedule.sortedAdd(item, itemSort);
	}
	
	public function addFrame(f:Void->Void):Void
	{
		onFrames.push(f);
	}
	
	public function removeFrame(f:Void->Void):Void
	{
		onFrames.remove(f);
	}
	
	private function itemSort(a:ScheduleItem, b:ScheduleItem):Int 
	{
		if (a.time < b.time) {
			return -1;
		}else {
			return 1;
		}
	}
	
	private function executeNext(item:ScheduleItem):Bool 
	{
		if (item.time > time) return true;
		
		item.f();
		
		return false;
	}
	
}

class ScheduleItem{
	public var time:Float;
	public var f:Void -> Void;
	
	public var prev:ScheduleItem;
	public var next:ScheduleItem;
	
	public function new(time:Float, f:Void -> Void) {
		this.time = time;
		this.f = f;
	}
}