package mantle.worker.tasks.fs;

import haxe.Json;
import mantle.util.worker.Worker;
import mantle.worker.tasks.BaseWorkerTask;

#if !flash
import openfl.display.Bitmap;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import openfl.net.URLLoaderDataFormat;
#else
import flash.display.Bitmap;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.net.URLLoaderDataFormat;
#end

/**
 * ...
 * @author Thomas Byrne
 */
class LoadDataTask extends BaseWorkerTask<LoadDataTaskData>
{
	var loader:URLLoader;
	var byteArray:ByteArray;
	
	public function new() 
	{
		super();
		
		loader = new URLLoader();
		loader.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
		loader.addEventListener(Event.COMPLETE, onLoaderComplete);
		loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
	}
	
	override public function doJob(data:LoadDataTaskData):Void
	{
		super.doJob(data);
		tryWrap(function() {
			
			if(data.encoding == BINARY){
				loader.dataFormat = URLLoaderDataFormat.BINARY;
			}else{
				loader.dataFormat = URLLoaderDataFormat.TEXT;
			}
		
			byteArray = new ByteArray();
			loader.load(new URLRequest(data.url));	
		});
	}
	
	private function onLoaderProgress(e:ProgressEvent):Void 
	{
		var prog:Float = e.bytesLoaded / e.bytesTotal;
		sendProgress(prog * 99, 100);
	}
	
	
	private function onLoaderError(e:Event):Void 
	{
		sendError(e.toString());
	}
	
	private function onLoaderComplete(e:Event):Void 
	{
		var res = loader.data;
		try{
			if (data.encoding == JSON){
				res = Json.parse(untyped res);
			}
		}catch (e:Dynamic){
			sendError(e.toString());
			return;
		}
		sendSuccess(res);
	}
}

class LoadDataTaskData
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("com.imagination.worker.tasks.LoadDataTaskData", LoadDataTaskData);
	}
	
	public var url:String;
	public var encoding:LoadDataTaskDataEncoding;

	public function new(?url:String, encoding:LoadDataTaskDataEncoding) 
	{
		set(url, encoding);
	}
	
	public function set(url:String, encoding:LoadDataTaskDataEncoding) 
	{
		this.url = url;
		this.encoding = encoding;
	}
}

@:enum
abstract LoadDataTaskDataEncoding(String){
	public var BINARY = "binary";
	public var STRING = "string";
	public var JSON = "json";
}