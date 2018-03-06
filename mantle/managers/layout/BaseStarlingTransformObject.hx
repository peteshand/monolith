package mantle.managers.layout;

import mantle.managers.layout.anchor.starling.AnchorContainer;
import mantle.managers.layout.scale.starling.ScaleContainer;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

#if swc
	import flash.display.Stage;
	import flash.errors.Error;
	import flash.events.Event;
#else
	import openfl.display.Stage;
	import openfl.errors.Error;
	import openfl.events.Event;
#end

/**
 * ...
 * @author P.J.Shand
 */
class BaseStarlingTransformObject extends BaseTransformObject implements ITransformObject
{
	private var _frameAnchor:AnchorContainer;
	private var _scaleContainer:ScaleContainer;
	private var _displayAnchor:AnchorContainer;
	
	private var displayObject:DisplayObject;
	
	public function new(stage:Stage, displayObject:DisplayObject) 
	{
		this.displayObject = displayObject;
		super(stage);
	}
	
	override private function renest():Void 
	{
		var parent:DisplayObjectContainer = displayObject.parent;
		if (parent == null) {
			throw new Error("displayObject must be added to the displaylist");
		}
		if (Std.is(parent, AnchorContainer)) {
			_displayAnchor = cast(parent, AnchorContainer);
			_scaleContainer = cast(Reflect.getProperty(_displayAnchor, "parent"), ScaleContainer);
			_frameAnchor = cast(Reflect.getProperty(_scaleContainer, "parent"), AnchorContainer);
			return;
		}
		
		var childIndex:Int = parent.getChildIndex(displayObject);
		
		_frameAnchor = new AnchorContainer();
		parent.addChildAt(_frameAnchor, childIndex);
		
		_scaleContainer = new ScaleContainer();
		_frameAnchor.addChild(_scaleContainer);
		
		_displayAnchor = new AnchorContainer();
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
		var value = stage.stageWidth / displayObject.width;
		Reflect.setProperty(this, "scaleContainerScaleX", value);
		xLimits();
	}
	
	override private function vStretch():Void 
	{
		var value = stage.stageHeight / displayObject.height;
		Reflect.setProperty(this, "scaleContainerScaleY", value);
		yLimits();
	}
	
	override private function calculateDisplayAnchor():Void 
	{
		var _displayAnchorX:Float = (anchorSettings.displayAnchor.fraction.x * -Reflect.getProperty(displayObject, "width"));
		var _displayAnchorY:Float = (anchorSettings.displayAnchor.fraction.y * -Reflect.getProperty(displayObject, "height"));
		_displayAnchorX -= anchorSettings.displayAnchor.pixels.x;
		_displayAnchorY -= anchorSettings.displayAnchor.pixels.y;
		
		displayAnchorX = Math.round(_displayAnchorX);
		displayAnchorY = Math.round(_displayAnchorY);
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