package mantle.worker.tasks.fs;
import mantle.util.worker.Worker;
import mantle.worker.WorkerResponse;
import mantle.worker.WorkerResponse.ResponseType;
import mantle.worker.IWorkerTask;
import flash.errors.Error;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import mantle.worker.tasks.BaseWorkerTask;
import openfl.events.ErrorEvent;
import openfl.events.SecurityErrorEvent;

#if !flash
import openfl.events.IOErrorEvent;
#else
import flash.events.IOErrorEvent;
#end

/**
 * ...
 * @author Thomas Byrne
 */
class WriteToFileTask extends BaseWorkerTask<WriteToFileTaskData>
{
	public static var PARTIAL_SUFFIX:String = ".partial";
	
	var tempFile:File;
	var destFile:File;
	var fileStream:FileStream;
	
	public function new() 
	{
		super();
		
		tempFile = new File();
		destFile = new File();
		fileStream = new FileStream();
		fileStream.addEventListener(Event.CLOSE, onClose);
		
		fileStream.addEventListener(IOErrorEvent.IO_ERROR, onErrorEvent);
		fileStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorEvent);
		
		tempFile.addEventListener(Event.COMPLETE, onMoveComplete);
		tempFile.addEventListener(IOErrorEvent.IO_ERROR, onErrorEvent);
		tempFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorEvent);
	}
	
	override public function doJob(data:WriteToFileTaskData):Void
	{
		super.doJob(data);
		tryWrap(function() {
			
			if (data.path.indexOf("file:/") == 0){
				destFile.url = data.path;
			}else{
				destFile.nativePath = data.path;
			}
			if(data.append){
				tempFile.nativePath = destFile.nativePath;
			}else{
				tempFile.nativePath = destFile.nativePath + PARTIAL_SUFFIX;
			}
			var nonexistant:Array<File> = [];
			var parent = destFile.parent;
			while (!parent.exists){
				nonexistant.unshift(parent);
				parent = parent.parent;
			}
			for(parent in nonexistant){
				parent.createDirectory();
			}
			fileStream.openAsync(tempFile, data.append ? FileMode.APPEND : FileMode.WRITE);
			if (data.binary!=null) {
				fileStream.writeBytes(data.binary);
			}else {
				fileStream.writeUTFBytes(data.text);
			}
			fileStream.close();
			
		});
	}
	
	private function onErrorEvent(e:ErrorEvent):Void 
	{
		sendError(e.text);
	}
	
	private function onClose(e:Event):Void 
	{
		if (data.append){
			sendSuccess();
		}else{
			tempFile.moveToAsync(destFile, true);
		}
	}
	
	private function onMoveComplete(e:Event):Void 
	{
		sendSuccess();
	}
}

class WriteToFileTaskData
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("com.imagination.worker.tasks.WriteToFileTaskData", WriteToFileTaskData);
	}
	
	public var path:String;
	public var binary:ByteArray;
	public var text:String;
	public var append:Bool;

	public function new(?path:String, ?binary:ByteArray, ?text:String, ?append:Bool) 
	{
		set(path, binary, text, append);
	}
	
	public function set(path:String, binary:ByteArray, text:String, append:Bool) 
	{
		this.path = path;
		this.text = text;
		this.binary = binary;
		this.append = append;
	}
}