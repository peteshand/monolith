package mantle.worker.ext;
import mantle.worker.WorkerSwitchboard;
import mantle.worker.tasks.schedule.BuildDayTask;
import mantle.worker.WorkerJob;
import imagsyd.dsp.utils.schedule.Schedulable;
import mantle.worker.WorkerJob.ErrorHandler;
import mantle.worker.WorkerJob.ProgHandler;
import mantle.worker.WorkerJob.SuccessHandler;
import mantle.worker.tasks.schedule.BuildDayTask.BuildDayTaskData;

/**
 * ...
 * @author Thomas Byrne
 */
class SchedulingTasks
{
	public static function buildDay(workerSwitch:WorkerSwitchboard, seed:Int, schedulable:Array<Schedulable>, now:Float, rescheduleHour:Int, contentGap:Int=0, ?fallbackId:Null<Int>, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):Void {
		BuildDayTaskData.register();
		workerSwitch.doJob(new BuildDayTaskData(seed, schedulable, now, rescheduleHour, contentGap, fallbackId), onSuccess, onError, onProg);
	}
	
}