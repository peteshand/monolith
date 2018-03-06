package mantle.util.assets;

import haxe.io.Bytes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

#else
import haxe.Resource;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.utils.ByteArray;
import openfl.events.SecurityErrorEvent;

#end

/**
 * A tool to help with the embedding of bitmapdata at compile time.
 * 
 * 
 * @author Thomas Byrne
 */
class BitmapDataEmbedder
{
	private static var RESOURCE_COUNT:String = "__bitmapembed_count";
	private static var RESOURCE_KEY_PREFIX:String = "__bitmapembed_key_";
	private static var RESOURCE_DATA_PREFIX:String = "__bitmapembed_data_";
	
	#if macro
	
	private static var registered:Bool;
	private static var bitmapCount:Int = 0;
	
	// Called by macros 
	public static function addBitmap(key:String, bytes:Bytes):Void
	{
		
		Context.addResource(RESOURCE_KEY_PREFIX + bitmapCount, Bytes.ofString(key));
		Context.addResource(RESOURCE_DATA_PREFIX + bitmapCount, bytes);
		bitmapCount++;
		Context.addResource(RESOURCE_COUNT, Bytes.ofString(Std.string(bitmapCount)));
	}
	
	
	#else
	
	static private var bitmapKeys:Array < String > = [];
	static private var bitmapBytes:Array < Bytes > = [];
	
	static private var isReady:Bool;
	static private var initHandlers:Array<Void->Void>;
	static private var index:Int = 0;
	static private var imgs:Map<String, BitmapData> = new Map();
	static private var loader:Loader = new Loader();
	static private var currKey:String;
	
	inline public static function getBitmapData(key:String):BitmapData
	{
		return imgs.get(key);
	}
	
	public static function init(onComplete:Void->Void):Void
	{
		if (isReady) {
			onComplete();
			
		}else if (initHandlers != null) {
			initHandlers.push(onComplete);
		}else {
			
			bitmapKeys = [];
			bitmapBytes = [];
			var bitmapCount:Int = Std.parseInt(Resource.getString(RESOURCE_COUNT));
			for (i in 0 ... bitmapCount) {
				var key:String = Resource.getString(RESOURCE_KEY_PREFIX + i);
				var data:Bytes = Resource.getBytes(RESOURCE_DATA_PREFIX + i);
				bitmapKeys.push(key);
				bitmapBytes.push(data);
			}
			
			var infoClass:Dynamic = Type.resolveClass("com.imagination.util.assets.BitmapDataEmbedder.EmbeddedInfo");
			initHandlers = [onComplete];
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCurrentComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			initNext();
		}
	}
	
	static private function onError(e:Event):Void 
	{
		Logger.warn(BitmapDataEmbedder, "Failed to load bitmap");
	}
	
	static private function initNext() 
	{
		if (index < bitmapKeys.length) {
			currKey = bitmapKeys[index];
			var bytes:Bytes = (bitmapBytes[index]);
			
			loader.unload();
			
			#if flash
				var byteArray = bytes.getData();
			#else
				var byteArray = ByteArray.fromBytes(bytes);
			#end
			loader.loadBytes(byteArray);
			
		}else {
			finished();
		}
	}
	
	static private function onCurrentComplete(e:Event):Void 
	{
		var bitmap:Bitmap = cast(loader.content);
		imgs.set(currKey, bitmap.bitmapData);
		index++;
		initNext();
	}
	
	inline static private function finished() 
	{
		isReady = true;
		for (handler in initHandlers) {
			handler();
		}
	}
	
	#end
	
}