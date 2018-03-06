package mantle.managers.layout;

import mantle.managers.layout.anchor.AnchorSettings;
import mantle.managers.layout.scale.ScaleManager;
import mantle.managers.layout.scale.ScaleMode;
import mantle.managers.layout.scale.ScaleSettings;
import mantle.managers.resize.Resize;
import flash.display.Stage;
/**
 * ...
 * @author P.J.Shand
 */
class BaseTransformObject 
{
	private var stage:Stage;
	private var scaleSettings:ScaleSettings;
	private var anchorSettings:AnchorSettings;
	private var stageRatio:Float = 1;
	
	private var frameWidth:Int;
	private var frameHeight:Int;
	
	private var _scaleContainerScaleX:Float;
	private var _scaleContainerScaleY:Float;
	private var _frameAnchorX:Float;
	private var _frameAnchorY:Float;
	private var _displayAnchorX:Float;
	private var _displayAnchorY:Float;
	
	#if swc @:extern #end
	public var scaleContainerScaleX(null, set):Float;
	#if swc @:extern #end
	public var scaleContainerScaleY(null, set):Float;
	#if swc @:extern #end
	public var frameAnchorX(null, set):Float;
	#if swc @:extern #end
	public var frameAnchorY(null, set):Float;
	#if swc @:extern #end
	public var displayAnchorX(null, set):Float;
	#if swc @:extern #end
	public var displayAnchorY(null, set):Float;
	
	#if swc @:extern #end
	public var scaleX(get, null):Float;
	#if swc @:extern #end
	public var scaleY(get, null):Float;
	
	public function new(stage:Stage) 
	{
		this.stage = stage;
		renest();
		
		Resize.onResize.add(OnStageResize);
		OnStageResize();
	}
	
	private function renest():Void 
	{
		
	}
	
	private function OnStageResize():Void 
	{
		
	}
	
	#if swc @:getter(scaleX) #end
	public function get_scaleX():Float 
	{
		return 1;
	}
	
	#if swc @:getter(scaleY) #end
	public function get_scaleY():Float 
	{
		return 1;
	}
	
	private function calculateScale():Void 
	{
		stageRatio = stage.stageWidth / stage.stageHeight;
		
		var _hScaleMode = Reflect.getProperty(scaleSettings, "hScaleMode");
		var _vScaleMode = Reflect.getProperty(scaleSettings, "vScaleMode");
		
		if (scaleSettings.scaleMode == ScaleMode.LETTERBOX) {
			if (stageRatio > ScaleManager.assetDimensionsRatio()) { // Width is max, Height is min
				letterboxToVertical();
			}
			else { // Height is max, Width is min
				letterboxToHorizontal();
			}
		}
		else if (scaleSettings.scaleMode == ScaleMode.FILL) {
			if (stageRatio > ScaleManager.assetDimensionsRatio()) { // Width is max, Height is min
				fillToHorizontal();
			}
			else { // Height is max, Width is min
				fillToVertical();
			}
		}
		else {
			if (_hScaleMode == ScaleMode.NONE) {
				hScaleNone();
			}
			else if (_hScaleMode == ScaleMode.STRETCH) {
				hStretch();
			}
			else if (_hScaleMode == ScaleMode.HORIZONTAL) {
				hScaleToHorizontal();
			}
			else if (_hScaleMode == ScaleMode.VERTICAL) {
				hScaleToVertical();
			}
			else {
				if (_hScaleMode == ScaleMode.MAXIMUM) {
					if (stageRatio > ScaleManager.assetDimensionsRatio()) { // Width is max, Height is min
						hScaleToHorizontal();
					}
					else { // Height is max, Width is min
						hScaleToVertical();
					}
				}
				else if (_hScaleMode == ScaleMode.MINIMUM) {
					if (stageRatio > ScaleManager.assetDimensionsRatio()) { // Width is max, Height is min
						hScaleToVertical();
					}
					else { // Height is max, Width is min
						hScaleToHorizontal();
					}
				}
			}
			
			
			
			if (_vScaleMode == ScaleMode.NONE) {
				vScaleNone();
			}
			else if (_vScaleMode == ScaleMode.STRETCH) {
				vStretch();
			}
			else if (_vScaleMode == ScaleMode.HORIZONTAL) {
				vScaleToHorizontal();
			}
			else if (_vScaleMode == ScaleMode.VERTICAL) {
				vScaleToVertical();
			}
			else {
				if (_vScaleMode == ScaleMode.MAXIMUM) {
					if (stageRatio > ScaleManager.assetDimensionsRatio()) { // Width is max, Height is min
						vScaleToHorizontal();
					}
					else { // Height is max, Width is min
						vScaleToVertical();
					}

				}
				else if (_vScaleMode == ScaleMode.MINIMUM) {
					if (stageRatio > ScaleManager.assetDimensionsRatio()) { // Width is max, Height is min
						vScaleToVertical();
					}
					else { // Height is max, Width is min
						vScaleToHorizontal();
					}
				}
			}
		}
	}
	
	private function letterboxToVertical():Void 
	{
		
	}
	
	private function letterboxToHorizontal():Void 
	{
		
	}
	
	private function fillToHorizontal():Void 
	{
		
	}
	
	private function fillToVertical():Void 
	{
		
	}
	
	private function hScaleNone():Void 
	{
		scaleContainerScaleX = 1;
		xLimits();
	}
	
	private function hStretch():Void 
	{
		
		xLimits();
	}
	
	private function hScaleToVertical():Void 
	{
		scaleContainerScaleX = stage.stageHeight / ScaleManager.assetDimensions.height;
		xLimits();
	}
	
	private function hScaleToHorizontal():Void 
	{
		scaleContainerScaleX = stage.stageWidth / ScaleManager.assetDimensions.width;
		xLimits();
	}
	
	
	
	
	
	private function vScaleNone():Void 
	{
		scaleContainerScaleY = 1;
		yLimits();
	}
	
	private function vStretch():Void 
	{
		yLimits();
	}
	
	private function vScaleToVertical():Void 
	{
		scaleContainerScaleY = stage.stageHeight / ScaleManager.assetDimensions.height;
		yLimits();
	}
	
	private function vScaleToHorizontal():Void 
	{
		scaleContainerScaleY = stage.stageWidth / ScaleManager.assetDimensions.width;
		yLimits();
	}
	
	private function xLimits():Void 
	{
		
	}
	
	private function yLimits():Void 
	{
		
	}
	
	
	
	
	/*#if swc @:setter(scaleContainerScaleX) #end*/
	public function set_scaleContainerScaleX(value:Float):Float 
	{
		return _scaleContainerScaleX = value;
	}
	
	/*#if swc @:setter(scaleContainerScaleY) #end*/
	public function set_scaleContainerScaleY(value:Float):Float 
	{
		return _scaleContainerScaleY = value;
	}
	
	/*#if swc @:setter(frameAnchorX) #end*/
	public function set_frameAnchorX(value:Float):Float 
	{
		return _frameAnchorX = value;
	}
	
	/*#if swc @:setter(frameAnchorY) #end*/
	public function set_frameAnchorY(value:Float):Float 
	{
		return _frameAnchorY = value;
	}
	
	/*#if swc @:setter(displayAnchorX) #end*/
	public function set_displayAnchorX(value:Float):Float 
	{
		return _displayAnchorX = value;
	}
	
	/*#if swc @:setter(displayAnchorY) #end*/
	public function set_displayAnchorY(value:Float):Float 
	{
		return _displayAnchorY = value;
	}
	
	private function calculateAnchor():Void 
	{
		calculateFrameAnchor();
		calculateDisplayAnchor();
	}
	
	private function calculateFrameAnchor():Void 
	{
		if (Reflect.getProperty(anchorSettings, "frame") != null) {
			var frame = Reflect.getProperty(anchorSettings, "frame");
			frameWidth = frame.width;
			frameHeight = frame.height;
		}
		else {
			frameWidth = stage.stageWidth;
			frameHeight = stage.stageHeight;
		}
		
		var _frameAnchorX:Float = (anchorSettings.frameAnchor.fraction.x * frameWidth);
		var _frameAnchorY:Float = (anchorSettings.frameAnchor.fraction.y * frameHeight);
		_frameAnchorX += anchorSettings.frameAnchor.pixels.x;
		_frameAnchorY += anchorSettings.frameAnchor.pixels.y;
		
		frameAnchorX = Math.round(_frameAnchorX);
		frameAnchorY = Math.round(_frameAnchorY);
	}
	
	private function calculateDisplayAnchor():Void 
	{
		// OVERRIDE
	}
	
	public function frameAnchor(fractionX:Float = 0, fractionY:Float = 0, pixelX:Float = 0, pixelY:Float = 0):ITransformObject
	{
		anchorSettings.frameAnchor.fraction.setTo(fractionX, fractionY);
		anchorSettings.frameAnchor.pixels.setTo(pixelX, pixelY);
		OnStageResize();
		// OVERRIDE AND CALL SUPER
		return null;
	}
	
	public function displayAnchor(fractionX:Float = 0, fractionY:Float = 0, pixelX:Float = 0, pixelY:Float = 0):ITransformObject
	{
		anchorSettings.displayAnchor.fraction.setTo(fractionX, fractionY);
		anchorSettings.displayAnchor.pixels.setTo(pixelX, pixelY);
		OnStageResize();
		// OVERRIDE AND CALL SUPER
		return null;
	}
	
	public function frame(value:Dynamic):ITransformObject
	{
		anchorSettings.frame = value;
		OnStageResize();
		// OVERRIDE AND CALL SUPER
		return null;
	}
	
	public function scaleMode(value:String):ITransformObject
	{
		scaleSettings.scaleMode = value;
		OnStageResize();
		// OVERRIDE AND CALL SUPER
		return null;
	}
	
	public function vScaleMode(value:String):ITransformObject
	{
		scaleSettings.vScaleMode = value;
		OnStageResize();
		// OVERRIDE AND CALL SUPER
		return null;
	}
	
	public function hScaleMode(value:String):ITransformObject
	{
		scaleSettings.hScaleMode = value;
		OnStageResize();
		// OVERRIDE AND CALL SUPER
		return null;
	}
}