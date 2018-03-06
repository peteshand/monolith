package mantle.worker.tasks.schedule;

import imagsyd.dsp.utils.schedule.Schedulable;
import imagsyd.dsp.utils.schedule.Scheduler;
import mantle.util.worker.Worker;
import mantle.worker.tasks.BaseWorkerTask;

/**
 * ...
 * @author Thomas Byrne
 */
class BuildDayTask extends BaseWorkerTask<BuildDayTaskData>
{
	
	public function new() 
	{
		super();
	}
	
	override public function doJob(data:BuildDayTaskData):Void
	{
		super.doJob(data);
		tryWrap(function() {
			
			sendSuccess(Scheduler.buildDay(data.seed, data.schedulable, data.now, data.rescheduleHour, data.contentGap, data.fallbackId));
		});
	}
}

class BuildDayTaskData
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("com.imagination.worker.tasks.BuildDayTaskData", BuildDayTaskData);
	}
	
	public var seed:Int;
	public var schedulable:Array<Schedulable>;
	public var now:Float;
	public var rescheduleHour:Int;
	public var contentGap:Int;
	public var fallbackId:Null<Int>;

	public function new(?seed:Int, ?schedulable:Array<Schedulable>, ?now:Float, ?rescheduleHour:Int, ?contentGap:Int, ?fallbackId:Null<Int>) 
	{
		set(seed, schedulable, now, rescheduleHour, contentGap);
	}
	
	public function set(?seed:Int, ?schedulable:Array<Schedulable>, now:Float, rescheduleHour:Int, contentGap:Int, ?fallbackId:Null<Int>) 
	{
		this.seed = seed;
		this.schedulable = schedulable;
		this.now = now;
		this.rescheduleHour = rescheduleHour;
		this.contentGap = contentGap;
		this.fallbackId = fallbackId;
	}
}