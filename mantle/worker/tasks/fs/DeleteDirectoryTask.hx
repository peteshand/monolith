package mantle.worker.tasks.fs;

import mantle.util.worker.Worker;
import mantle.worker.tasks.BaseWorkerTask;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;

/**
 * ...
 * @author Thomas Byrne
 */
class DeleteDirectoryTask extends BaseWorkerTask<DeleteDirectoryTaskData>
{
	var file:File;
	
	public function new() 
	{
		super();
		
		file = new File();
		file.addEventListener(Event.COMPLETE, onDelSuccess);
		file.addEventListener(IOErrorEvent.IO_ERROR, onDelFail);
	}
	
	override public function doJob(data:DeleteDirectoryTaskData):Void
	{
		super.doJob(data);
		tryWrap(function() {
			
			file.nativePath = data.path;
			if (!file.exists) {
				sendSuccess();
				return;
			}
			
			file.deleteDirectoryAsync(data.includingFiles);
		});
	}
	
	private function onDelSuccess(e:Event):Void 
	{
		sendSuccess();
	}
	
	private function onDelFail(e:IOErrorEvent):Void 
	{
		sendError(e.text);
	}
}

class DeleteDirectoryTaskData
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("com.imagination.worker.tasks.DeleteDirectoryTaskData", DeleteDirectoryTaskData);
	}
	
	public var path:String;
	public var includingFiles:Bool;

	public function new(?path:String, includingFiles:Bool=false) 
	{
		set(path, includingFiles);
	}
	
	public function set(path:String, includingFiles:Bool) 
	{
		this.path = path;
		this.includingFiles = includingFiles;
	}
}