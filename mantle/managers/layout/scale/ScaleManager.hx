package mantle.managers.layout.scale;

import mantle.managers.layout.anchor.AnchorManager;
import mantle.managers.layout.scale.displaylist.DisplayListScaleObject;
import mantle.managers.layout.scale.starling.ScaleObject;
import mantle.util.layout.Dimensions;
import mantle.util.uid.UID;
import mantle.managers.layout.ITransformObject;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.display.Image;

#if swc
	import flash.display.Stage;
	import flash.errors.Error;
	import flash.geom.Rectangle;
#else
	import openfl.display.Stage;
	import openfl.errors.Error;
	import openfl.geom.Rectangle;
#end

/**
 * ...
 * @author P.J.Shand
 */
class ScaleManager 
{
	
	
	#if swc @:protected #end
	private static var _assetDimensions:Rectangle;
	#if swc @:protected #end
	private static var _stage:Stage;
	#if swc @:protected #end
	private static var scaleObjects = new Map<String, Dynamic>();
	
	#if swc @:extern #end
	public static var stage(get, set):Stage;
	
	#if swc @:extern #end
	public static var assetDimensions(get, set):Rectangle;
	
	public function new() 
	{
		_assetDimensions = Dimensions.D_1080P;
	}		
	
	public static function add(displayObject:Dynamic, scaleSettings:ScaleSettings=null):ITransformObject 
	{
		if (ScaleManager._stage == null) {
			throw new Error("stage much first be set");
		}
		
		var transformObject:ITransformObject = null;
		if (scaleSettings == null) scaleSettings = new ScaleSettings();
		if (!scaleObjects.exists(UID.instanceID(displayObject))) {
			if (Std.is(displayObject, starling.display.DisplayObject)) {
				transformObject = new ScaleObject(ScaleManager._stage, displayObject, scaleSettings);
				scaleObjects.set(UID.instanceID(displayObject), transformObject);
			}
			else if (Std.is(displayObject, #if swc flash.display.DisplayObject #else openfl.display.DisplayObject #end)) {
				transformObject = new DisplayListScaleObject(ScaleManager._stage, displayObject, scaleSettings);
				scaleObjects.set(UID.instanceID(displayObject), transformObject);
			}
		}
		return transformObject;
	}
	
	public static function getScaleObjects(displayObject:Dynamic):ScaleObject 
	{
		if (scaleObjects.exists(UID.instanceID(displayObject))) {
			return scaleObjects.get(UID.instanceID(displayObject));
		}
		return null;
	}
	
	#if swc @:getter(assetDimensions) #end
	public static function get_assetDimensions():Rectangle 
	{
		return _assetDimensions;
	}
	
	#if swc @:setter(assetDimensions) #end
	public static function set_assetDimensions(value:Rectangle):Rectangle 
	{
		return _assetDimensions = value;
	}
	
	#if swc @:getter(stage) #end
	public static function get_stage():Stage 
	{
		return _stage;
	}
	
	#if swc @:setter(stage) #end
	public static function set_stage(value:Stage):Stage 
	{
		return _stage = value;
	}
	
	#if swc @:getter(scaleX) #end
	public static function get_scaleX():Float 
	{
		return _stage.stageWidth / assetDimensions.width;
	}
	
	#if swc @:getter(scaleY) #end
	public static function get_scaleY():Float 
	{
		return _stage.stageHeight / assetDimensions.height;
	}
	
	public static function assetDimensionsRatio():Float 
	{
		if (assetDimensions == null) return 1;
		return assetDimensions.width / assetDimensions.height;
	}
}