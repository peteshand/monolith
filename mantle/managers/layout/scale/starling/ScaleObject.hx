package mantle.managers.layout.scale.starling;

import mantle.managers.layout.BaseStarlingTransformObject;
import mantle.managers.layout.scale.ScaleManager;
import mantle.managers.layout.scale.ScaleMode;
import mantle.managers.layout.scale.ScaleSettings;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;

#if swc
	import flash.display.Stage;
	import flash.events.Event;
#else
	import openfl.display.Stage;
	import openfl.events.Event;
#end

/**
 * ...
 * @author P.J.Shand
 */
class ScaleObject extends BaseStarlingTransformObject
{
	public function new(stage:Stage, displayObject:DisplayObject, scaleSettings:ScaleSettings) 
	{
		this.scaleSettings = scaleSettings;
		super(stage, displayObject);
	}
	
	override private function OnStageResize():Void 
	{
		if (ScaleManager.assetDimensions == null) {
			trace(this, "WARMING: ScaleManager.assetDimensions must first be set");
		}
		calculateScale();
	}
	
	/*#if swc @:setter(scaleContainerScaleX) #end*/
	override public function set_scaleContainerScaleX(value:Float):Float 
	{
		Reflect.setProperty(_scaleContainer, "scaleX", value);
		return value;
	}
	
	/*#if swc @:setter(scaleContainerScaleY) #end*/
	override public function set_scaleContainerScaleY(value:Float):Float 
	{
		Reflect.setProperty(_scaleContainer, "scaleY", value);
		return value;
	}
}