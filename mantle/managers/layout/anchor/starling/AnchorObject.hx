package mantle.managers.layout.anchor.starling;

import mantle.managers.layout.anchor.AnchorSettings;
import mantle.managers.layout.BaseStarlingTransformObject;
import mantle.managers.layout.scale.starling.ScaleContainer;
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
class AnchorObject extends BaseStarlingTransformObject
{
	public function new(stage:Stage, displayObject:DisplayObject, anchorSettings:AnchorSettings) 
	{
		this.anchorSettings = anchorSettings;
		super(stage, displayObject);
	}
	
	override private function OnStageResize():Void 
	{
		calculateAnchor();
	}
	
	/*#if swc @:setter(frameAnchorX) #end*/
	override public function set_frameAnchorX(value:Float):Float 
	{
		Reflect.setProperty(_frameAnchor, "x", value);
		return value;
	}
	
	/*#if swc @:setter(frameAnchorY) #end*/
	override public function set_frameAnchorY(value:Float):Float 
	{
		Reflect.setProperty(_frameAnchor, "y", value);
		return value;
	}
	
	/*#if swc @:setter(displayAnchorX) #end*/
	override public function set_displayAnchorX(value:Float):Float 
	{
		Reflect.setProperty(_displayAnchor, "x", value);
		return value;
	}
	
	/*#if swc @:setter(displayAnchorY) #end*/
	override public function set_displayAnchorY(value:Float):Float 
	{
		Reflect.setProperty(_displayAnchor, "y", value);
		return value;
	}
}