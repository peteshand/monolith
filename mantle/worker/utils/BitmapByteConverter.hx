package mantle.worker.utils;

#if !flash
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
#else 
import flash.display.BitmapData;
import flash.utils.ByteArray;
#end

using Logger;

/**
 * ...
 * @author Thomas Byrne
 */
class BitmapByteConverter
{
	
	public static function toBytes(bitmapData:BitmapData):ByteArray {
		var bytes = new ByteArray();
		bytes.writeInt(bitmapData.width);
		bytes.writeInt(bitmapData.height);
		bytes.writeBoolean(bitmapData.transparent);
		#if flash
		bitmapData.copyPixelsToByteArray(bitmapData.rect, bytes);
		#end
		return bytes;
	}

	public static function toBitmapData(bytes:ByteArray):BitmapData {
		bytes.position = 0;
		var width:Int = bytes.readInt();
		var height:Int = bytes.readInt();
		var transparent:Bool = bytes.readBoolean();
		
		var bitmapData;
		try{
			bitmapData = new BitmapData(width, height, transparent);
		}catch (e:Dynamic){
			Logger.error(BitmapByteConverter, "Failed to create BitmapData: "+width+" "+height+" "+transparent);
			return null;
		}
		try{
			bitmapData.setPixels(bitmapData.rect, bytes);
		}catch (e:Dynamic){
			Logger.error(BitmapByteConverter, "Failed to deserialise BitmapData: "+width+" "+height+" "+transparent+" "+bytes.length);
			return null;
		}
		
		return bitmapData;
	}

	
}