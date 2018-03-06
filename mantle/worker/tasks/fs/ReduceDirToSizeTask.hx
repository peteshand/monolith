package mantle.worker.tasks.fs;
import mantle.util.ds.ArraySortAsync;
import mantle.util.worker.Worker;
import flash.events.Event;
import flash.events.FileListEvent;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.Lib;
import mantle.worker.tasks.BaseWorkerTask;

/**
 * ...
 * @author Thomas Byrne
 */
class ReduceDirToSizeTask extends BaseWorkerTask<ReduceDirToSizeTaskData>
{
	var file:File;
	var toDelete:Int = 0;
	var files:Array<File>;
	var t:Int;
	//var arraySorter:ArraySortAsync<File>;
	var moddedLookup:Map<File, Float>;

	public function new() 
	{
		super();
		
		file = new File();
		file.addEventListener(FileListEvent.DIRECTORY_LISTING, onListing);
	}
	
	override public function doJob(data:ReduceDirToSizeTaskData):Void
	{
		super.doJob(data);
		
		tryWrap(function() {
			toDelete = 0;
			moddedLookup = new Map();
			file.nativePath = data.path;
			file.getDirectoryListingAsync();
		});
	}
	
	private function onListing(e:FileListEvent):Void 
	{
		tryWrap(function() {
			
			var bytes:Float = data.mbs * 1048576;
			var totalSize:Float = 0;
			
			files = e.files;
			for (file in files) {	
				moddedLookup.set(file, file.modificationDate.getTime());
				totalSize += file.size;
			}
			
			if (totalSize < bytes){
				// Can skip rest
				sendSuccess();
				return;
			}
			
			// Seems to have a bug
			//arraySorter = new ArraySortAsync(files, arrangeFilesByModified, onSortFinished);
			files.sort(arrangeFilesByModified);
			onSortFinished();
		});
	}
	
	function onSortFinished() 
	{
		tryWrap(function() {
			moddedLookup = null;
			//files = arraySorter.result;
			
			var bytes:Float = data.mbs * 1048576;
			
			var totalSize:Float = 0;
			for (file in files) {
				totalSize += file.size;
			}
			
			var i:Int = 0;
			while (totalSize > bytes && i<files.length) {
				var file:File = files[i];
				totalSize -= file.size;
				file.addEventListener(Event.COMPLETE, onDeleteComplete);
				file.addEventListener(IOErrorEvent.IO_ERROR, onDeleteFail);
				file.deleteFileAsync();
				i++;
				toDelete++;
			}
			if (toDelete == 0) {
				sendSuccess();
			}
		});
	}
	
	private function onDeleteFail(e:IOErrorEvent):Void 
	{
		onDeleteComplete(e);
	}
	
	private function onDeleteComplete(e:Event):Void 
	{
		var file:File = cast (e.target);
		toDelete--;
		file.removeEventListener(Event.COMPLETE, onDeleteComplete);
		file.removeEventListener(IOErrorEvent.IO_ERROR, onDeleteFail);
		if (toDelete == 0) {
			sendSuccess();
		}
	}
	
	function arrangeFilesByModified(file1:File, file2:File):Int
	{
		var mod1 = moddedLookup.get(file1);
		var mod2 = moddedLookup.get(file2);
		if ( mod1 < mod2) {
			return -1;
		}else if(mod1 > mod2 ) {
			return 1;
		} else{
			return 0;
		}
	}
	
}

class ReduceDirToSizeTaskData
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("mantle.worker.tasks.ReduceDirToSizeTaskData", ReduceDirToSizeTaskData);
	}
	
	public var path:String;
	public var mbs:Float;

	public function new(?path:String, ?mbs:Float) 
	{
		set(path, mbs);
	}
	
	public function set(path:String, mbs:Float) 
	{
		this.path = path;
		this.mbs = mbs;
	}
}