package mantle.model.serialisation;

import haxe.Json;
import mantle.util.signals.Signal;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import openfl.utils.ByteArray;

using Logger;

/**
 * A base class to handle some of the basics of model serialisation (in JSON format).
 * Note: DataSerialisationLogic does not require you to use this base class, it is for convenience only.
 * 
 * @author Thomas Byrne
 */
class BaseSerialisableModel 
{
	public var onSerialisedChange:Void->Void;
	
	var obsfucateSerialisation:Bool;
	

	function addSerialiseTriggers(signals:Array<Dynamic>) 
	{
		for (signal in signals){
			if (Std.is(signal, Signal0)){
				untyped signal.add(triggerSerialise0);
				
			}else if (Std.is(signal, Signal1)){
				untyped signal.add(triggerSerialise1);
				
			}else if (Std.is(signal, Signal2)){
				untyped signal.add(triggerSerialise2);
			}
		}
	}
	
	function triggerSerialise0() 
	{
		if (onSerialisedChange != null) onSerialisedChange();
	}
	function triggerSerialise1(arg1:Dynamic) 
	{
		if (onSerialisedChange != null) onSerialisedChange();
	}
	function triggerSerialise2(arg1:Dynamic, arg2:Dynamic) 
	{
		if (onSerialisedChange != null) onSerialisedChange();
	}
	
	
	
	public function serialisedFileExt():String
	{
		return "json";
	}
	public function deserialise(data:ByteArray) : Void
	{
		if(data != null){
			data.position = 0;
			var str = data.readUTFBytes(data.length);
			if (obsfucateSerialisation){
				try{
					var bytes = Base64.decode(str.substr(1) + str.charAt(0));
					str = bytes.getString(0, bytes.length);
				}catch (e:Dynamic){
					warn("Failed to deserialise obsfucated model (attempting non-obsfucated parse): " + Type.getClassName(Type.getClass(this)));
				}
			}
			var data:Dynamic;
			try{
				data = Json.parse(str);
				
			}catch (e:Dynamic){
				warn("Failed to deserialise model: " + Type.getClassName(Type.getClass(this)));
				return;
			}
			
			deserialiseObj(data);
		}
	}
	var serialised:Dynamic;
	public function serialise(fill:ByteArray) : Void
	{
		if (serialised == null) serialised = {};
		serialised = serialiseToObj(serialised);
		var str = Json.stringify(serialised, null, "\t");
		if (obsfucateSerialisation){
			str = Base64.encode(Bytes.ofString(str));
			str = str.charAt(str.length - 1) + str.substr(0, str.length - 1);
		}
		fill.writeUTFBytes(str);
	}
	
	function deserialiseObj(data:Dynamic) 
	{
		// override
	}
	function serialiseToObj(fill:Dynamic) : Dynamic 
	{
		// override
		return fill;
	}
}