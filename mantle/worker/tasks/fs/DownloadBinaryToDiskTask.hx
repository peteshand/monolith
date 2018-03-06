package mantle.worker.tasks.fs;
import mantle.worker.WorkerResponse;
import mantle.util.time.EnterFrame;
import mantle.util.worker.Worker;
import mantle.worker.WorkerResponse.ResponseType;
import flash.errors.Error;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import mantle.worker.tasks.BaseWorkerTask;

using Logger;

/**
 * ...
 * @author Thomas Byrne
 */
class DownloadBinaryToDiskTask extends BaseWorkerTask<DownloadBinaryToDiskTaskData>
{
	public static var PARTIAL_SUFFIX:String = ".partial";
	
	var file:File;
	var fileStream:FileStream;
	var stream:URLStream;
	var percentWas:Int;
	var byteArray:ByteArray;
	var deleting:Bool;
	var totalBytes:UInt;
	var isLoaded:Bool;
	
	public function new() 
	{
		super();
		
		byteArray = new ByteArray();
		
		file = new File();
		
		fileStream = new FileStream();
		fileStream.addEventListener(Event.CLOSE, onWriteSuccess );
		fileStream.addEventListener(IOErrorEvent.IO_ERROR, onWriteFail );
		
		stream = new URLStream();
		stream.addEventListener(ProgressEvent.PROGRESS, onDownloadBinProg, false, 0, true); 
		stream.addEventListener(Event.COMPLETE, onDownloadBinComplete, false, 0, true);
		stream.addEventListener(IOErrorEvent.IO_ERROR, onDownloadBinError, false, 0, true); 
		stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadBinError, false, 0, true);
	}
	
	override public function doJob(data:DownloadBinaryToDiskTaskData):Void
	{
		if (data.bytes == 0) data.bytes = null;
		this.deleting = false;
		totalBytes = 0;
		
		super.doJob(data);
		tryWrap(function() {
		
			percentWas = 0;
			
			if (data.tempPath == null){
				data.tempPath = data.path + PARTIAL_SUFFIX;
			}
		
			file.nativePath = data.tempPath;
			if (!file.parent.exists) {
				file.parent.createDirectory();
				
			}else if (file.exists) {
				file.deleteFile();
			}
			
			fileStream.openAsync(file, FileMode.WRITE);
			var request:URLRequest = new URLRequest(data.remoteUrl);
			stream.load(request);	
		});
	}
	
	
	
	private function onDownloadBinProg(e:ProgressEvent):Void 
	{
		tryWrap(function() {
			if (data == null){
				return;
			}
			
			if (stream.bytesAvailable>0) {
				if (byteArray.bytesAvailable>0) {
					byteArray.clear();
					byteArray.position = 0;
				}
				totalBytes += stream.bytesAvailable;
				stream.readBytes(byteArray, 0, stream.bytesAvailable);
				
				fileStream.writeBytes(byteArray, 0, byteArray.bytesAvailable);
				
				byteArray.clear();
				byteArray.position = 0;
				
				isLoaded = (e.bytesLoaded >= e.bytesTotal - 32);
				
				var percent:Int = Math.round(e.bytesLoaded / e.bytesTotal * 90);
				if (percent - percentWas >= 1) {
					sendProgress(percent, 100);
					percentWas = percent;
				}
			}
			
		});
	}
	
	private function onDownloadBinComplete(e:Event):Void 
	{
		if(isLoaded){
			tryWrap(function(){
				fileStream.close();
				stream.close();
				sendProgress(90, 100);
			});
		}else{
			attemptDelete("Download failed");
		}
	}
	
	private function onDownloadBinError(e:ErrorEvent):Void 
	{
		super.tryWrap(function(){
			attemptDelete(e.errorID + ": " + e.text);
		});
	}
	
	function attemptDelete(error:String, attempt:Int=0) 
	{
		this.deleting = true; // Avoids success handler (if delete needs to wait)
		try{
			fileStream.close();
			if (stream.connected) stream.close();
			
			file.nativePath = data.path;
			if (file.exists){
				file.deleteFile();
			}
			
			file.nativePath = data.tempPath;
			if (file.exists){
				file.deleteFile();
			}
			
		}catch (e:Dynamic) {
			if(attempt < 3){
				EnterFrame.delay(attemptDelete.bind(error, attempt+1), 2);
				return;
			}
		}
		sendError(error);
	}
	
	private function onWriteSuccess(e:Event):Void 
	{
		if (this.data == null || deleting) return; // failed
		
		var dataNow = this.data;
		
		tryWrap(function() {
			
			file.nativePath = data.tempPath;
			
			if (data.bytes != null && file.size != data.bytes){
				attemptDelete("File size check failed - expected:" + data.bytes +" actual:" + file.size + " " + data.remoteUrl);
				return;
			}
			
			var destFile:File = new File(data.path);
			if (destFile.exists){
				if (data.bytes != null && file.size != data.bytes){
					info("File already downloaded by another process");
				}else{
					destFile.deleteFile();
					file.moveTo(destFile);
				}
			}else{
				file.moveTo(destFile);
			}
			
			
		});
		if (dataNow == this.data && !deleting && totalBytes>0){ // totalBytes check confirms that it hasn't restarted on the same asset
			sendSuccess();
		}
			
	}
	
	
	override private function tryWrap(f:Void->Void) 
	{
		try {
			f();
		}catch (e:Error) {
			attemptDelete(e.getStackTrace());
		}
	}
	
	private function onWriteFail(e:IOErrorEvent):Void 
	{
		if (this.data == null || deleting) return; // failed
		attemptDelete(e.errorID + ": " + e.text);
	}
	
}
class DownloadBinaryToDiskTaskData
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("com.imagination.worker.tasks.DownloadBinaryToDiskTaskData", DownloadBinaryToDiskTaskData);
	}
	
	public var path:String;
	public var remoteUrl:String;
	public var tempPath:String;
	public var bytes:Null<Float>;

	public function new(?path:String, ?remoteUrl:String, ?tempPath:Null<String>, ?bytes:Float) 
	{
		set(path, remoteUrl, tempPath, bytes);
	}
	
	public function set(path:String, remoteUrl:String, ?tempPath:Null<String>, ?bytes:Float) 
	{
		this.path = path;
		this.remoteUrl = remoteUrl;
		this.bytes = bytes;
		this.tempPath = tempPath;
	}
}