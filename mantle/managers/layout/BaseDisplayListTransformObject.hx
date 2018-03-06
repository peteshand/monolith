package mantle.managers.layout;

import mantle.managers.layout.anchor.displaylist.DisplayAnchorContainer;
import mantle.managers.layout.scale.displaylist.DisplayScaleContainer;

#if swc
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.errors.Error;
	import flash.events.Event;
#else
	import openfl.display.DisplayObject;
	import openfl.display.Stage;
	import openfl.errors.Error;
	import openfl.events.Event;
#end
/**
 * ...
 * @author P.J.Shand
 */
class BaseDisplayListTransformObject extends BaseTransformObject implements ITransformObject
{
	private var _frameAnchor:DisplayAnchorContainer;
	private var _scaleContainer:DisplayScaleContainer;
	private var _displayAnchor:DisplayAnchorContainer;
	
	private var displayObject:DisplayObject;
	
	public function new(stage:Stage, displayObject:DisplayObject) 
	{
		this.displayObject = displayObject;
		super(stage);
	}
	
	override private function renest():Void 
	{
		if (displayObject.parent == null) {
			throw new Error("displayObject must be added to the displaylist");
		}
		if (Std.is(displayObject.parent, DisplayAnchorContainer)) {
			_displayAnchor = cast(displayObject.parent, DisplayAnchorContainer);
			_scaleContainer = cast(_displayAnchor.parent, DisplayScaleContainer);
			_frameAnchor = cast(_scaleContainer.parent, DisplayAnchorContainer);
			return;
		}
		
		var childIndex:Int = displayObject.parent.getChildIndex(displayObject);
		
		_frameAnchor = new DisplayAnchorContainer();
		displayObject.parent.addChildAt(_frameAnchor, childIndex);
		
		_scaleContainer = new DisplayScaleContainer();
		_frameAnchor.addChild(_scaleContainer);
		
		_displayAnchor = new DisplayAnchorContainer();
		_scaleContainer.addChild(_displayAnchor);
		
		_displayAnchor.addChild(displayObject);
	}
	
	#if swc @:getter(scaleX) #end
	override public function get_scaleX():Float 
	{
		return _scaleContainer.scaleX;
	}
	
	#if swc @:getter(scaleY) #end
	override public function get_scaleY():Float 
	{
		return _scaleContainer.scaleY;
	}
	
	override private function hStretch():Void 
	{
		Reflect.setProperty(this, "scaleContainerScaleX", stage.stageWidth / displayObject.width);
		xLimits();
	}
	
	override private function vStretch():Void 
	{
		Reflect.setProperty(this, "scaleContainerScaleY", stage.stageHeight / displayObject.height);
		yLimits();
	}
	
	override private function calculateDisplayAnchor():Void 
	{
		var _displayAnchorX:Float = (anchorSettings.displayAnchor.fraction.x * -displayObject.width);
		var _displayAnchorY:Float = (anchorSettings.displayAnchor.fraction.y * -displayObject.height);
		_displayAnchorX -= anchorSettings.displayAnchor.pixels.x;
		_displayAnchorY -= anchorSettings.displayAnchor.pixels.y;
		
		Reflect.setProperty(this, "displayAnchorX", Math.round(_displayAnchorX));
		Reflect.setProperty(this, "displayAnchorY", Math.round(_displayAnchorY));
	}
	
	override public function frameAnchor(fractionX:Float = 0, fractionY:Float = 0, pixelX:Float = 0, pixelY:Float = 0):ITransformObject
	{
		super.frameAnchor(fractionX, fractionY, pixelX, pixelY);
		return this;
	}
	
	override public function displayAnchor(fractionX:Float = 0, fractionY:Float = 0, pixelX:Float = 0, pixelY:Float = 0):ITransformObject
	{
		super.displayAnchor(fractionX, fractionY, pixelX, pixelY);
		return this;
	}
	
	override public function scaleMode(value:String):ITransformObject
	{
		super.scaleMode(value);
		return this;
	}
	
	override public function vScaleMode(value:String):ITransformObject
	{
		super.vScaleMode(value);
		return this;
	}
	
	override public function hScaleMode(value:String):ITransformObject
	{
		super.hScaleMode(value);
		return this;
	}
}