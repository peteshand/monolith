package mantle.managers.layout.anchor;

import mantle.managers.layout.anchor.displaylist.DisplayListAnchorObject;
import mantle.managers.layout.anchor.starling.AnchorObject;
import mantle.managers.layout.scale.ScaleManager;
import haxe.ds.ObjectMap;
import mantle.managers.layout.ITransformObject;
import starling.display.DisplayObject;

#if swc
	import flash.errors.Error;
	import flash.display.DisplayObject;
	import flash.display.Stage;
#else
	import openfl.errors.Error;
	import openfl.display.DisplayObject;
	import openfl.display.Stage;
#end

/**
 * ...
 * @author P.J.Shand
 */
class AnchorManager 
{
	public static var stage:Stage;
	private static var anchorObjects = new ObjectMap<{},Dynamic>();
	
	public function new() 
	{
		
	}		
	
	public static function add(displayObject:Dynamic, anchorSettings:AnchorSettings=null):ITransformObject 
	{
		//UID.instanceID(object)
		if (stage == null) {
			throw new Error("stage much first be set");
		}
		if (anchorSettings == null) anchorSettings = new AnchorSettings();
		return createAnchorObject(displayObject, anchorSettings);
	}
	
	private static function createAnchorObject(displayObject:Dynamic, anchorSettings:AnchorSettings):ITransformObject 
	{
		var transformObject:ITransformObject = null;
		if (anchorObjects.exists(displayObject) == false)
		{
			if (Std.is(displayObject, starling.display.DisplayObject)){
				transformObject = new AnchorObject(stage, displayObject, anchorSettings);
				anchorObjects.set(displayObject, transformObject);
			}
			else if (Std.is(displayObject, #if swc flash.display.DisplayObject #else openfl.display.DisplayObject #end)) {
				transformObject = new DisplayListAnchorObject(stage, displayObject, anchorSettings);
				anchorObjects.set(displayObject, transformObject);
			}
		}
		return transformObject;
	}
}