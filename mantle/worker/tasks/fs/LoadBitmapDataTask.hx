package mantle.worker.tasks.fs;

import mantle.time.Delay;
import mantle.util.geom.Point;
import mantle.util.worker.Worker;
import mantle.worker.tasks.BaseWorkerTask;
import mantle.worker.tasks.fs.LoadBitmapDataTask.LoadBitmapDataTaskData;
import openfl.net.URLRequestHeader;
//import com.imagination.worker.utils.BitmapByteConverter;
import mantle.worker.utils.BitmapByteConverter;

#if !flash
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
#else
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;
#end

/**
 * ...
 * @author Thomas Byrne
 */
class LoadBitmapDataTask extends BaseWorkerTask<LoadBitmapDataTaskData>
{
	var loader:Loader;
	var loaderContext:LoaderContext;
	
	public function new() 
	{
		super();
		
		loader = new Loader();
		loaderContext = new LoaderContext();
		
		#if flash
		untyped loaderContext.imageDecodingPolicy = flash.system.ImageDecodingPolicy.ON_LOAD;
		#end

		loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
		loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
	}
	
	override public function doJob(data:LoadBitmapDataTaskData):Void
	{
		super.doJob(data);
		tryWrap(function() {
			loader.unload();
			var request = new URLRequest(data.url);
			request.requestHeaders.push(new URLRequestHeader("Access-Control-Allow-Origin", "*"));
			request.requestHeaders.push(new URLRequestHeader("X-HTTP-Method-Override", "GET")); // GET is sometimes changed to OPTIONS under the hood (because of CORS)
			loader.load(request);
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
		if (!Std.is(loader.content, Bitmap)) {
			sendError("Loaded asset was not a bitmap");
		}else {
			var	bitmap:Bitmap = cast loader.content;
			var bitmapData:BitmapData = bitmap.bitmapData;
			if (data.forceTransparent != null && data.forceTransparent != bitmapData.transparent) {
				// Force transparency change
				var bd:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, data.forceTransparent);
				bd.copyPixels(bitmapData, bitmapData.rect, new Point());
				bitmapData = bd;
				bitmap.bitmapData.dispose();
			}else{
				bitmapData = bitmapData.clone();
			}
			
			#if flash
			if (isInWorker){
				var bytes = mantle.worker.utils.BitmapByteConverter.toBytes(bitmapData);
				sendSuccess(bytes);
				bytes.clear();
				bitmapData.dispose();
				flash.system.System.gc();
				return;
			}
			#end
			sendSuccess(bitmapData);
			// don't dispose bitmapData as it may be still being used
			if(data == null)loader.unload();
		}
	}
}

class LoadBitmapDataTaskData
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("com.imagination.worker.tasks.LoadBitmapDataTaskData", LoadBitmapDataTaskData);
	}
	
	public var url:String;
	public var forceTransparent:Null<Bool>;

	public function new(?url:String, ?forceTransparent:Null<Bool>) 
	{
		set(url, forceTransparent);
	}
	
	public function set(url:String, forceTransparent:Null<Bool>) 
	{
		this.url = url;
		this.forceTransparent = forceTransparent;
	}
}