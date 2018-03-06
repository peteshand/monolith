package mantle.managers.layout.anchor.displaylist;

import mantle.managers.layout.anchor.AnchorSettings;
import mantle.managers.layout.BaseDisplayListTransformObject;

#if swc
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
#else
	import openfl.display.DisplayObject;
	import openfl.display.DisplayObjectContainer;
	import openfl.display.Stage;
	import openfl.events.Event;
#end

/**
 * ...
 * @author P.J.Shand
 */
class DisplayListAnchorObject extends BaseDisplayListTransformObject
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
		return _frameAnchor.x = value;
	}
	
	/*#if swc @:setter(frameAnchorY) #end*/
	override public function set_frameAnchorY(value:Float):Float 
	{
		return _frameAnchor.y = value;
	}
	
	/*#if swc @:setter(displayAnchorX) #end*/
	override public function set_displayAnchorX(value:Float):Float 
	{
		return _displayAnchor.x = value;
	}
	
	/*#if swc @:setter(displayAnchorY) #end*/
	override public function set_displayAnchorY(value:Float):Float 
	{
		return _displayAnchor.y = value;
	}
}