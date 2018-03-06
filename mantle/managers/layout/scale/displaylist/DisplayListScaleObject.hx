package mantle.managers.layout.scale.displaylist;

import mantle.managers.layout.BaseDisplayListTransformObject;
import mantle.managers.layout.scale.ScaleManager;
import mantle.managers.layout.scale.ScaleMode;
import mantle.managers.layout.scale.ScaleSettings;

#if swc
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
#else
	import openfl.display.DisplayObject;
	import openfl.display.Stage;
	import openfl.events.Event;
#end

/**
 * ...
 * @author P.J.Shand
 */
class DisplayListScaleObject extends BaseDisplayListTransformObject
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
		return _scaleContainer.scaleX = value;
	}
	
	/*#if swc @:setter(scaleContainerScaleY) #end*/
	override public function set_scaleContainerScaleY(value:Float):Float 
	{
		return _scaleContainer.scaleY = value;
	}
}