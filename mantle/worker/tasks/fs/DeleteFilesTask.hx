package mantle.worker.tasks.fs;
import mantle.util.fs.File;
import mantle.util.worker.Worker;
import flash.events.Event;
import flash.events.IOErrorEvent;
import mantle.worker.tasks.BaseWorkerTask;

/**
 * ...
 * @author ...
 */
class DeleteFilesTask extends BaseWorkerTask<DeleteFilesTaskData>
{
	var currentInd:Int;
	var file:File;
	var errors:Array<String>;
	
	public function new() 
	{
		super();
		file = new File();
		file.addEventListener(Event.COMPLETE, onDelSuccess);
		file.addEventListener(IOErrorEvent.IO_ERROR, onDelFail);
	}
	
	override public function doJob(data:DeleteFilesTaskData):Void
	{
		currentInd = 0;
		errors = [];
		
		super.doJob(data);
		deleteNext();
	}
	
	function deleteNext() 
	{
		tryWrap(function() {
			
			if (currentInd == data.files.length){
				if (errors.length > 0){
					sendError(errors.join("\n"));
				}else{
					sendSuccess();
				}
				return;
			}
			
			var path = data.files[currentInd];
			currentInd++;
			file.nativePath = path;
			if (!file.exists) {
				deleteNext();
				return;
			}
			
			
			if(file.isDirectory){
				file.deleteDirectoryAsync(true);
			}else{
				file.deleteFileAsync();
			}
		});
	}
	
	private function onDelSuccess(e:Event):Void 
	{
		deleteNext();
	}
	
	private function onDelFail(e:IOErrorEvent):Void 
	{
		errors.push(file.nativePath);
		deleteNext();
	}
}

class DeleteFilesTaskData
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("com.imagination.worker.tasks.DeleteFilesTaskData", DeleteFilesTaskData);
	}
	
	public var path:String;
	public var files:Array<String>;

	public function new(?path:String, files:Array<String>) 
	{
		set(path, files);
	}
	
	public function set(path:String, files:Array<String>) 
	{
		this.path = path;
		this.files = files;
	}
}