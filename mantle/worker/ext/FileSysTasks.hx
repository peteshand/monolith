package mantle.worker.ext;
import mantle.worker.WorkerJob;
import mantle.worker.tasks.fs.DeleteDirectoryTask;
import mantle.worker.tasks.fs.DeleteFilesTask;
import mantle.worker.tasks.fs.DownloadBinaryToDiskTask;
import mantle.worker.tasks.fs.LoadBitmapDataTask;
import mantle.worker.tasks.fs.LoadDataTask;
import mantle.worker.tasks.fs.ReduceDirToSizeTask;
import mantle.worker.tasks.fs.WriteToFileTask;
import mantle.worker.utils.BitmapByteConverter;
//import com.imagination.worker.utils.BitmapByteConverter;
import mantle.util.app.Platform;
import mantle.util.time.EnterFrame;
import mantle.worker.WorkerJob.ErrorHandler;
import mantle.worker.WorkerJob.ProgHandler;
import mantle.worker.WorkerJob.SuccessHandler;
import mantle.worker.WorkerSwitchboard;
import mantle.worker.tasks.fs.LoadDataTask.LoadDataTaskData;
import mantle.worker.tasks.fs.LoadDataTask.LoadDataTaskDataEncoding;
import flash.utils.ByteArray;

#if openfl
import openfl.display.BitmapData;
#else
import flash.display.BitmapData;
#end

/**
 * Designed to be used as a 'using' utility
 * @author Thomas Byrne
 */
class FileSysTasks
{
#if !html5
	public static function writeTextToFile(workerSwitch:WorkerSwitchboard, path:String, text:String, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		mantle.worker.tasks.fs.WriteToFileTask.WriteToFileTaskData.register();
		return workerSwitch.doJob(new mantle.worker.tasks.fs.WriteToFileTask.WriteToFileTaskData(path, null, text, false), onSuccess, onError, onProg);
	}
	public static function appendTextToFile(workerSwitch:WorkerSwitchboard, path:String, text:String, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		mantle.worker.tasks.fs.WriteToFileTask.WriteToFileTaskData.register();
		return workerSwitch.doJob(new mantle.worker.tasks.fs.WriteToFileTask.WriteToFileTaskData(path, null, text, true), onSuccess, onError, onProg);
	}
	
	public static function writeBinaryToFile(workerSwitch:WorkerSwitchboard, path:String, bytes:ByteArray, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		mantle.worker.tasks.fs.WriteToFileTask.WriteToFileTaskData.register();
		return workerSwitch.doJob(new mantle.worker.tasks.fs.WriteToFileTask.WriteToFileTaskData(path, bytes, null, false), onSuccess, onError, onProg);
	}
	public static function appendBinaryToFile(workerSwitch:WorkerSwitchboard, path:String, bytes:ByteArray, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		mantle.worker.tasks.fs.WriteToFileTask.WriteToFileTaskData.register();
		return workerSwitch.doJob(new mantle.worker.tasks.fs.WriteToFileTask.WriteToFileTaskData(path, bytes, null, true), onSuccess, onError, onProg);
	}
	
	public static function deleteDirectory(workerSwitch:WorkerSwitchboard, path:String, includingFiles:Bool, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		mantle.worker.tasks.fs.DeleteDirectoryTask.DeleteDirectoryTaskData.register();
		return workerSwitch.doJob(new mantle.worker.tasks.fs.DeleteDirectoryTask.DeleteDirectoryTaskData(path, includingFiles), onSuccess, onError, onProg);
	}
	
	public static function deleteFiles(workerSwitch:WorkerSwitchboard, paths:Array<String>, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		mantle.worker.tasks.fs.DeleteDirectoryTask.DeleteDirectoryTaskData.register();
		return workerSwitch.doJob(new mantle.worker.tasks.fs.DeleteFilesTask.DeleteFilesTaskData(paths), onSuccess, onError, onProg);
	}
	
	/**
	 * Downloads file over HTTP and saves to disk.
	 */
	public static function downloadBinaryToDisk(workerSwitch:WorkerSwitchboard, path:String, remoteUrl:String, ?tempPath:Null<String>, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler, ?bytes:Float):CancelHandler {
		if (Platform.isWindows() && path.length > 256){
			Logger.warn(FileSysTasks, "Warning, path is longer than 256 chars, write might fail" );
		}
		
		mantle.worker.tasks.fs.DownloadBinaryToDiskTask.DownloadBinaryToDiskTaskData.register();
		return workerSwitch.doJob(new mantle.worker.tasks.fs.DownloadBinaryToDiskTask.DownloadBinaryToDiskTaskData(path, remoteUrl, tempPath, bytes), onSuccess, onError, onProg);
	}
	
	
	/**
	 * Removes files from folder (starting with oldest) total size is under specified mbs.
	 */
	public static function reduceDirToSize(workerSwitch:WorkerSwitchboard, path:String, mbs:Float, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler{
		mantle.worker.tasks.fs.ReduceDirToSizeTask.ReduceDirToSizeTaskData.register();
		return workerSwitch.doJob(new mantle.worker.tasks.fs.ReduceDirToSizeTask.ReduceDirToSizeTaskData(path, mbs), onSuccess, onError, onProg);
	}
#end
	
	/**
	 * Loads a binary file into memory and returns it as a ByteArray
	 */
	public static function loadBinary(workerSwitch:WorkerSwitchboard, url:String, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		mantle.worker.tasks.fs.LoadDataTask.LoadDataTaskData.register();
		return workerSwitch.doJob(new LoadDataTaskData(url, LoadDataTaskDataEncoding.BINARY), onSuccess, onError, onProg);
	}
	
	/**
	 * Loads a file into memory and returns it as a String
	 */
	public static function loadString(workerSwitch:WorkerSwitchboard, url:String, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		mantle.worker.tasks.fs.LoadDataTask.LoadDataTaskData.register();
		return workerSwitch.doJob(new LoadDataTaskData(url, LoadDataTaskDataEncoding.STRING), onSuccess, onError, onProg);
	}
	
	/**
	 * Loads a file into memory, parses it as JSON and returns it as a Dynamic object
	 */
	public static function loadJson(workerSwitch:WorkerSwitchboard, url:String, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		mantle.worker.tasks.fs.LoadDataTask.LoadDataTaskData.register();
		return workerSwitch.doJob(new LoadDataTaskData(url, LoadDataTaskDataEncoding.JSON), onSuccess, onError, onProg);
	}
	
	/**
	 * Loads a BitmapData into memory and returns it.
	 * Only decodes one Bitmap per frame to avoid main thread lockup.
	 */
	private static var bitmapJobs:Int = 0;
	private static var frameUsed:Bool;
	private static var queue:Array<Void->Void> = [];
	public static function loadBitmapData(workerSwitch:WorkerSwitchboard, url:String, ?forceTransparent:Null<Bool>, ?onSuccess:SuccessHandler, ?onError:ErrorHandler, ?onProg:ProgHandler):CancelHandler {
		
		#if flash
			// Serialisation / Deserialisation of BitmapData is too expensive, run in main thread.
			// Also, makes Workers consume too much memory, which isn't easy for the main thread to reclaim.
			workerSwitch = WorkerSwitchboard.getInstance();
		#end
		
		if (bitmapJobs == 0){
			EnterFrame.add(doBitmapProcess);
		}
		bitmapJobs++;
		mantle.worker.tasks.fs.LoadBitmapDataTask.LoadBitmapDataTaskData.register();
		return workerSwitch.doJob(new mantle.worker.tasks.fs.LoadBitmapDataTask.LoadBitmapDataTaskData(url, forceTransparent), queueDeserialise.bind(_, onSuccess), onError, onProg);
	}
	
	static private function doBitmapProcess() 
	{
		if (queue.length > 0){
			queue.shift()();
		}else{
			frameUsed = false;
		}
	}
	static function queueDeserialise(result:Dynamic, ?onSuccess:SuccessHandler):Void {
		if (frameUsed){
			queue.push(finaliseDeserialise.bind(result, onSuccess));
		}else{
			frameUsed = true;
			finaliseDeserialise(result, onSuccess);
		}
	}
	static function finaliseDeserialise(result:Dynamic, ?onSuccess:SuccessHandler):Void{
		
		bitmapJobs--;
		if (bitmapJobs == 0){
			EnterFrame.remove(doBitmapProcess);
		}
		
		if (onSuccess == null){
			return;
		}
		
		var bitmap:BitmapData;
		#if flash
		if (Std.is(result, BitmapData)) {
			bitmap = cast result;
		}else {
			var byteArray:ByteArray = cast result;
			bitmap = mantle.worker.utils.BitmapByteConverter.toBitmapData(byteArray);
			byteArray.clear();
		}
		#else
			bitmap = cast result;
		#end
		onSuccess(bitmap);
	}
	
}