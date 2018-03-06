package mantle.util.layout;
import mantle.util.layout.LayoutEngine;
import mantle.util.layout.Layout;
import mantle.util.layout.Layout.ILayoutAdapter;
import mantle.util.layout.LayoutEngine.ILayoutSizeProvider;
import mantle.util.time.EnterFrame;
import msignal.Signal.Signal0;

#if openfl
import openfl.Lib;
import openfl.display.*;
import openfl.events.Event;
#else
import flash.Lib;
import flash.display.*;
import flash.events.Event;
#end

/**
 * ...
 * @author Thomas Byrne
 */
class StageSizeProvider implements ILayoutSizeProvider
{
	
	@:isVar public var x(get, null):Float;
	@:isVar public var y(get, null):Float;
	@:isVar public var width(get, null):Float;
	@:isVar public var height(get, null):Float;
	@:isVar public var naturalWidth(get, null):Float;
	@:isVar public var naturalHeight(get, null):Float;
	
	function get_x():Float 
	{
		return x;
	}
	
	function get_y():Float 
	{
		return y;
	}
	
	function get_width():Float 
	{
		return width;
	}
	
	function get_height():Float 
	{
		return height;
	}
	
	function get_naturalWidth():Float 
	{
		return naturalWidth;
	}
	
	function get_naturalHeight():Float 
	{
		return naturalHeight;
	}
	
	
	public var sizeChanged:Signal0 = new Signal0();
	
	var stage:Stage;

	public function new(?naturalWidth:Null<Float>, ?naturalHeight:Null<Float>) 
	{
		x = 0;
		y = 0;
		stage = Lib.current.stage;
		stage.addEventListener(Event.RESIZE, onStageResize);
		onStageResize();
		this.naturalWidth = naturalWidth == null ? stage.stageWidth : naturalWidth;
		this.naturalHeight = naturalHeight == null ? stage.stageHeight : naturalHeight;
		
		if (width == 0 || height == 0) {
			EnterFrame.add(checkSize);
		}
	}
	
	public function getDisplaySpace():Null<ILayoutAdapter> 
	{
		return null;
	}
	
	public function setNaturalSize(w:Float, h:Float) 
	{
		if (naturalWidth == w && naturalHeight == h) return;
		naturalWidth = w;
		naturalHeight = h;
		sizeChanged.dispatch();
	}
	
	function checkSize() 
	{
		onStageResize();
		if (width != 0 && height != 0) {
			EnterFrame.remove(checkSize);
		}
	}
	
	private function onStageResize(?e:Event):Void 
	{
		if (width == stage.stageWidth && height == stage.stageHeight) return;
		
		width = stage.stageWidth;
		height = stage.stageHeight;
		
		sizeChanged.dispatch();
	}
	
}