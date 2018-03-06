package mantle.worker;

#if !html5
import mantle.worker.tasks.fs.DeleteDirectoryTask;
import mantle.worker.tasks.fs.DeleteFilesTask;
import mantle.worker.tasks.fs.DownloadBinaryToDiskTask;
import mantle.worker.tasks.fs.ReduceDirToSizeTask;
import mantle.worker.tasks.fs.WriteToFileTask;
#end

import mantle.worker.tasks.fs.LoadDataTask;
import mantle.worker.tasks.fs.LoadBitmapDataTask;

import mantle.worker.WorkerResponse.ResponseType;

/**
 * ...
 * @author Thomas Byrne
 */
class WorkerProcessor
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		
		WorkerJob.register();
		WorkerResponse.register();
		
		#if !html5
		WriteToFileTaskData.register();
		DownloadBinaryToDiskTaskData.register();
		ReduceDirToSizeTaskData.register();
		DeleteDirectoryTaskData.register();
		DeleteFilesTaskData.register();
		#end
		
		LoadDataTaskData.register();
		LoadBitmapDataTaskData.register();
	}
	
	private var currentJob:WorkerJob;
	
	private var taskMap:Map<String, IWorkerTask<Dynamic>>;
	private var taskClassMap:Map<String, Class<IWorkerTask<Dynamic>>>;
	private var responseHandler:WorkerResponse->Void;
	
	private var sendResp:WorkerResponse;
	private var isInWorker:Bool;

	public function new(sendResponse:WorkerResponse->Void, isInWorker:Bool) 
	{
		taskMap = new Map();
		taskClassMap = new Map();
		
		this.isInWorker = isInWorker;
		
		this.responseHandler = sendResponse;
		sendResp = new WorkerResponse();
		
		#if !html5
		addTask(WriteToFileTask, WriteToFileTaskData);
		addTask(DownloadBinaryToDiskTask, DownloadBinaryToDiskTaskData);
		addTask(ReduceDirToSizeTask, ReduceDirToSizeTaskData);
		addTask(DeleteDirectoryTask, DeleteDirectoryTaskData);
		addTask(DeleteFilesTask, DeleteFilesTaskData);
		#end
		
		addTask(LoadDataTask, LoadDataTaskData);
		addTask(LoadBitmapDataTask, LoadBitmapDataTaskData);
	}
	
	function addTask<T>(taskClass:Class<IWorkerTask<T>>, taskDataClass:Class<T>) :Void
	{
		var typeName:String = Type.getClassName(taskDataClass);
		taskClassMap.set(typeName, taskClass);
	}
	
	
	public function process<T>(job:WorkerJob) 
	{
		currentJob = job;
		var type:Class<T> = Type.getClass(job.data);
		var typeName:String = Type.getClassName(type);
		
		var task:IWorkerTask<T> = cast taskMap.get(typeName);
		
		if (task != null) {
			task.doJob(cast job.data);
			return;
		}
		
		var taskClass:Class<IWorkerTask<T>> = cast taskClassMap.get(typeName);
		if (taskClass == null) {
			responseHandler(sendResp.set(ResponseType.FAILED, job.id));
			return;
		}
		
		task = Type.createInstance(taskClass, []);
		task.setup(onSuccess, onError, onProgress, isInWorker);
		taskMap.set(typeName, task);
		task.doJob(cast job.data);
		
	}
	
	function onProgress(prog:Float, total:Float) :Void 
	{
		if (currentJob == null) return;
		
		responseHandler(sendResp.set(ResponseType.PROGRESS, currentJob.id, null, null, prog, total));
	}
	
	function onError(err:String) :Void 
	{
		if (currentJob == null) return;
		
		var job:WorkerJob = currentJob;
		currentJob = null;
		responseHandler(sendResp.set(ResponseType.FAILED, job.id, null, err));
	}
	
	function onSuccess(res:Null<Dynamic>):Void 
	{
		if (currentJob == null) return;
		
		var job:WorkerJob = currentJob;
		currentJob = null;
		
		responseHandler(sendResp.set(ResponseType.SUCCESS, job.id, res));
	}
}