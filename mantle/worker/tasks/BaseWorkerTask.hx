package mantle.worker.tasks;
import mantle.util.time.Timer;
import mantle.worker.IWorkerTask;
import flash.errors.Error;

using Logger;

/**
 * ...
 * @author Thomas Byrne
 */
class BaseWorkerTask<T> implements IWorkerTask<T>
{
	/**
	 * Progress events will be send during processing at regular intervals so that
	 * the parent thread knows if a worker dies.
	 * 
	 * In seconds
	 */
	private static var SEND_PROG_EVERY:Float = 4;
	
	var onSuccess:Dynamic->Void;
	var onError:String->Void;
	var onProgress:Float->Float->Void;
	
	var intervalSet:Bool;
	var intervalId:UInt;
	
	var lastProg:Float;
	var lastTotal:Float;
	
	var data:T;
	var isInWorker:Bool;


	public function new() 
	{
		
	}
	
	public function setup(onSuccess:Null<Dynamic>->Void, onError:String->Void, onProgress:Float->Float->Void, isInWorker:Bool):Void
	{
		this.onSuccess = onSuccess;
		this.onError = onError;
		this.onProgress = onProgress;
		this.isInWorker = isInWorker;
	}
	
	public function doJob(data:T):Void
	{
		this.data = data;
		lastProg = 0;
		lastTotal = 1;
		startInterval();
	}
	
	function startInterval() 
	{
		clearInterval();
		intervalSet = true;
		intervalId = Timer.setInterval(forceSendProgress, SEND_PROG_EVERY * 1000);
	}
	
	function clearInterval() 
	{
		if (!intervalSet) return;
		Timer.clearInterval(intervalId);
		intervalSet = false;
	}
	
	private function sendSuccess(?res:Null<Dynamic>):Void
	{
		if (data == null){
			warn("Attempting to return from already complete Worker Task");
			return;
		}
		data = null;
		clearInterval();
		onSuccess(res);
	}
	
	private function sendError(err:String):Void
	{
		if (data == null){
			warn("Attempting to return from already complete Worker Task");
			return;
		}
		data = null;
		clearInterval();
		onError(err);
	}
	
	private function sendProgress(prog:Float, total:Float):Void
	{
		startInterval();
		lastProg = prog;
		lastTotal = total;
		onProgress(prog, total);
	}
	
	private function forceSendProgress() 
	{
		onProgress(lastProg, lastTotal);
	}
	
	private function tryWrap(f:Void->Void) 
	{
		try {
			f();
		}catch (e:Error) {
			sendError(e.getStackTrace());
		}
	}
}