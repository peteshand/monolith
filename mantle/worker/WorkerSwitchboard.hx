package mantle.worker;
import mantle.util.time.EnterFrame;
import mantle.util.time.Timer;
import mantle.util.worker.Worker;
import mantle.worker.WorkerJob;
import mantle.worker.WorkerJob.ErrorHandler;
import mantle.worker.WorkerJob.ProgHandler;
import mantle.worker.WorkerJob.SuccessHandler;
import mantle.worker.WorkerProcessor;
import mantle.worker.WorkerResponse;
import mantle.worker.WorkerSwitchboard.PendingJob;
import mantle.worker.WorkerSwitchboard.WorkerTracker;

#if flash
import flash.events.Event;
import flash.system.MessageChannel;
import flash.system.WorkerDomain;
#end

import haxe.io.Bytes;

using Logger;

/**
 * ...
 * @author Thomas Byrne
 */
class WorkerSwitchboard
{
	
	// This is just here to allow SWC building
	public static function main() { }
	
	private static var _instance:WorkerSwitchboard;
	public static function getInstance():WorkerSwitchboard {
		if (_instance == null)_instance = new WorkerSwitchboard(false);
		return _instance;
	}
	
	private static var _worker:WorkerSwitchboard;
	public static function getWorker():WorkerSwitchboard {
		if (_worker == null)_worker = new WorkerSwitchboard(false);
		return _worker;
	}
	
	public var initWorkers:Int = 3;
	public var maxWorkers:Int = 3;
	public var maxAttempts:Int = 3;

	private var nextJobId:UInt = 0;
	
	private var workers:Array<WorkerTracker>;
	private var allowWorker:Bool;
	private var pendingJobs:Array<PendingJob>;
	
	private var jobPool:Array<WorkerJob>;

	public function new(allowWorker:Bool=true) 
	{
		WorkerJob.register();
		WorkerResponse.register();
		
		
		jobPool = [];
		pendingJobs = [];
		this.allowWorker = allowWorker && Worker.isSupported;
		
		workers = [];
		for (i in 0 ... initWorkers) {
			workers.push(new WorkerTracker(onWorkerDone, allowWorker));
		}
	}
	
	function onWorkerDone(worker:WorkerTracker, job:PendingJob, success:Bool) 
	{
		if (success || job.attempted >= maxAttempts){
			worker.completeJobDone();
			recycleJob(job);
		}else{
			pendingJobs.push(job);
		}
		
		if (pendingJobs.length > 0) {
			var pending = pendingJobs.shift();
			worker.doJob(pending);
		}
	}

	public function doJob(jobData:Dynamic, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProgress:ProgHandler ) : CancelHandler
	{
		var job:WorkerJob = createJob(jobData);
		var pendingJob:PendingJob = { job:job, attempted:0, onSuccess:onSuccess, onError:onError, onProgress:onProgress };
		var worker:WorkerTracker = findAvailWorker();
		if (worker == null) {
			if (workers.length < maxWorkers) {
				worker = new WorkerTracker(onWorkerDone, allowWorker);
				workers.push(worker);
				worker.doJob(pendingJob);
			}else {
				pendingJobs.push(pendingJob);
			}
		}else {
			worker.doJob(pendingJob);
		}
		return cancelJob.bind(pendingJob);
	}
	
	function cancelJob(job:PendingJob) : Void
	{
		if (job.job == null) return;
		
		var index = pendingJobs.indexOf(job);
		if (index !=-1){
			pendingJobs.splice(index, 1);
			recycleJob(job);
		}else{
			job.cancelled = true;
		}
		
	}
	
	function recycleJob(job:PendingJob) 
	{
		job.job.data = null;
		jobPool.push(job.job);
		
		job.job = null;
		job.onProgress = null;
		job.onSuccess = null;
		job.onError = null;
	}
	
	function createJob(jobData:Dynamic):WorkerJob 
	{
		var job:WorkerJob;
		if (jobPool.length>0) {
			job = jobPool.pop();
		}else {
			job = new WorkerJob();
		}
		job.id = nextJobId++;
		job.data = jobData;
		return job;
	}
	
	function findAvailWorker() :Null<WorkerTracker>
	{
		for (worker in workers) {
			if (worker.currentJob == null) {
				return worker;
			}
		}
		return null;
	}
	
}

class WorkerTracker
{
	/*
	 * Time (in seconds) that worker is non-responsive before being considered crashed.
	 */
	private static var WORKER_TIMEOUT:Float = 8.2;
	
	/*
	 * Amount of MS that completion handlers should be allowed to take per frame.
	 * If a completion handlers take more than this (combined) then further completion events will be cached till next frame.
	 */
	private static var DONE_MS_ALLOCATION:Int = 16;
	
	static var staticInited:Bool;
	static var allocationTaken:Float = 0;
	static var frameWorkers:Array<WorkerTracker> = [];
	static inline function init():Void{
		if (staticInited) return;
		staticInited = true;
		EnterFrame.add(onEnterFrame);
	}
	static inline function addToFrame(tracker:WorkerTracker):Void{
		if (frameWorkers.indexOf(tracker) != -1) return;
		frameWorkers.push(tracker);
	}
	static inline function removeFromFrame(tracker:WorkerTracker):Void{
		frameWorkers.remove(tracker);
	}
	static private function onEnterFrame() 
	{
		allocationTaken = 0;
		for (tracker in frameWorkers){
			removeFromFrame(tracker);
			tracker.attemptJobDone();
			if (allocationTaken >= DONE_MS_ALLOCATION) return;
		}
	}
	
	public var currentJob:PendingJob;
	
#if flash
	private var _worker:Worker;
	private var _mainToWorker:MessageChannel;
	private var _workerToMain:MessageChannel;
#end
	
	private var jobDone:WorkerTracker->PendingJob->Bool->Void;
	private var _processor:WorkerProcessor;
	private var _ready:Bool;
	
	private var _successResp:Dynamic;
	private var _errorResp:String;
	private var _wasError:Bool;
	
	private var totalAttempts:Int;
	private var currAttempts:Int;
	
	private var intervalSet:Bool;
	private var intervalId:UInt;
	
	public function new(jobDone:WorkerTracker->PendingJob->Bool->Void, allowWorker:Bool, totalAttempts:Int = 1) {
		init();
		
		this.jobDone = jobDone;
		
#if flash
		if (allowWorker) {
			loadWorker();
			return;
		}
#end
		_ready = true;
		_processor = new WorkerProcessor(processResponse, false);
		
	}
	
#if flash
	function loadWorker() 
	{
		if (_mainToWorker!=null) {
			_mainToWorker.close();
			_workerToMain.close();
			_worker.terminate();
		}
		_ready = false;
		
		var bytes:Bytes = haxe.Resource.getBytes("general_worker");
		_worker = WorkerDomain.current.createWorker(bytes.getData(), true);
		
		// Set up a MessageChannel to send messages from the main thread to a worker thread
		// Since this is called from the main thread, Worker.current is the main thread
		_mainToWorker = Worker.current.createMessageChannel(_worker);
		_worker.setSharedProperty("mainToWorker", _mainToWorker);
		 
		// Set up a MessageChannel to receive messages from a worker thread into the main thread
		_workerToMain = _worker.createMessageChannel(Worker.current);
		_workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
		_worker.setSharedProperty("workerToMain", _workerToMain);
		
		_worker.start();
	}
	
	private function onWorkerToMain(e:Event):Void 
	{
		processResponse(cast _workerToMain.receive());
	}
	
	function startInterval() 
	{
		clearInterval();
		intervalSet = true;
		intervalId = Timer.setTimeout(workerCrashed, WORKER_TIMEOUT * 1000);
	}
	
	function workerCrashed() 
	{
		error("Worker crashed, restarting: "+currentJob.job.data);
		loadWorker();
	}
#end
	
	public function doJob(job:PendingJob) 
	{
		job.attempted++;
		
		currentJob = job;
		
		_errorResp = null;
		_successResp = null;
		_wasError = false;
		
		if (!_ready) return;
		send();
	}
	
	function processResponse(resp:WorkerResponse) 
	{
		var job = currentJob;
		var type = (resp == null ? ResponseType.FAILED : resp.type);
		switch(type) {
			case ResponseType.STARTUP_COMPLETE:
				_ready = true;
				if (currentJob!=null) send();
				
			case ResponseType.PROGRESS:
				#if flash
					if (_processor == null) startInterval();
				#end
				if (job.onProgress != null) {
					job.onProgress(resp.prog, resp.total);
				}
				
			case ResponseType.SUCCESS:
				if (_processor == null) clearInterval();
				_successResp = resp.res;
				attemptJobDone();
				
			case ResponseType.FAILED:
				if(_processor==null)clearInterval();
				_wasError = true;
				_errorResp = resp == null ? null : resp.err;
				attemptJobDone();
				
				
		}
	}
	
	public function attemptJobDone() 
	{
		if (allocationTaken >= DONE_MS_ALLOCATION){
			addToFrame(this);
			return;
		}
		jobDone(this, currentJob, !_wasError);
	}
	
	public function completeJobDone() 
	{
		var job = currentJob;
		var time = Timer.getTimer();
		if(_wasError/* || job.cancelled*/){ // doing this would prevent bitmaps from being disposed (for example)
			if (job.onError != null) {
				job.onError(_errorResp);
			}
			_errorResp = null;
		}else{
			if (job.onSuccess != null) {
				job.onSuccess(_successResp);
			}
			_successResp = null;
		}
		currentJob = null;
		allocationTaken += Timer.getTimer() - time;
	}
	
	function send():Void 
	{
		#if flash
		if (_processor==null) {
			_mainToWorker.send(currentJob.job);
			startInterval();
		}else {
			_processor.process(currentJob.job);
		}
		#else
		_processor.process(currentJob.job);
		#end
	}
	
	function clearInterval() 
	{
		if (!intervalSet) return;
		Timer.clearTimeout(intervalId);
		intervalSet = false;
	}

}


typedef PendingJob =
{
	?job:WorkerJob,
	?cancelled:Bool,
	?onSuccess:SuccessHandler,
	?onError:ErrorHandler,
	?onProgress:ProgHandler,
	attempted:Int
}


typedef CancelHandler = Void -> Void;
