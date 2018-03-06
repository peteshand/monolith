package mantle.util.layout.adapters;
import mantle.util.layout.Layout;
import mantle.util.layout.Layout.ILayoutAdapter;
import starling.events.Event;

#if starling //For SWC Gen


import mantle.util.geom.Matrix;
import mantle.util.geom.Rectangle;

import starling.display.*;

#if openfl
import openfl.geom.*;
#else
import flash.geom.*;
#end

/**
 * ...
 * @author Thomas Byrne
 */
class StarlingAdapter implements ILayoutAdapter
{
	private static var STAGE_ADAPTER:StarlingAdapter;
	
	
	public var added(get, null):Bool;
	
	@:isVar public var displayObject(get, set):DisplayObject;
	function get_displayObject():DisplayObject 
	{
		return displayObject;
	}
	function set_displayObject(value:DisplayObject):DisplayObject 
	{
		if (displayObject != null){
			this.displayObject.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			if (_parent != null) {
				_parent.dispose();
				_parent = null;
			}
		}
		if(Std.is(value, DisplayObjectContainer)){
			this.displayObjectContainer = cast value;
		}else {
			this.displayObjectContainer = null;
		}
		this.displayObject = value;
		if(displayObject!=null){
			_cachedWidth = displayObject.width;
			_cachedHeight = displayObject.height;
			
			if (Std.is(sprite, Sprite)){
				sprite = cast value;
			}else{
				sprite = null;
			}
		}else{
			sprite = null;
		}
		return value;
	}
	
	var displayObjectContainer:DisplayObjectContainer;
	var _cachedWidth:Float;
	var _cachedHeight:Float;
	var applyMode:StarlingAdapterApplyMode;
	var sprite:Sprite;

	public function new(displayObject:DisplayObject, ?applyMode:StarlingAdapterApplyMode, autoRemove:Bool=true) 
	{
		this.displayObject = displayObject;
		
		if (applyMode == null) {
			this.applyMode = StarlingAdapterApplyMode.TRANSFORM;
		}else {
			this.applyMode = applyMode;
		}
		
		if (autoRemove){
			this.displayObject.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
	}
	
	private function onRemovedFromStage(e:Event):Void 
	{
		forceRemove();
	}
	public function dispose():Void
	{
		displayObject = null;
	}
	
	public function forceRemove():Void{
		Layout.remove(displayObject, this);
	}
	
	
	public var width(get, set):Float;
	function get_width():Float{
		if (clipRect != null || applyMode == StarlingAdapterApplyMode.TRANSFORM) {
			return _cachedWidth * displayObject.transformationMatrix.a;
		}else{
			return displayObject.width;
		}
	}
	function set_width(value:Float):Float{
		return displayObject.width = value;
	}
	
	public var height(get, set):Float;
	function get_height():Float {
		if (clipRect != null || applyMode == StarlingAdapterApplyMode.TRANSFORM) {
			return _cachedHeight * displayObject.transformationMatrix.d;
		}else{
			return displayObject.height;
		}
	}
	function set_height(value:Float):Float{
		return displayObject.height = value;
	}
	
	@:isVar public var transformationMatrix(get, set):Matrix;
	function get_transformationMatrix():Matrix {
		if(this.transformationMatrix == null){
			return displayObject.transformationMatrix;
		}else {
			return transformationMatrix;	
		}
	}
	function set_transformationMatrix(value:Matrix):Matrix {
		transformationMatrix = value;
		switch(applyMode) {
			case StarlingAdapterApplyMode.TRANSFORM:
				displayObject.transformationMatrix = value;
			case StarlingAdapterApplyMode.WIDTH_HEIGHT:
				displayObject.x = value.tx;
				displayObject.y = value.ty;
				displayObject.width = _cachedWidth * value.a;
				displayObject.height = _cachedHeight * value.d;
			case StarlingAdapterApplyMode.SCALE:
				displayObject.x = value.tx;
				displayObject.y = value.ty;
				displayObject.scaleX = value.a;
				displayObject.scaleY = value.d;
		}
		return value;
	}
	
	@:isVar public var clipRect(get, set):Rectangle;
	function get_clipRect():Rectangle{
		return clipRect;
	}
	function set_clipRect(value:Rectangle):Rectangle {
		clipRect = value;
		if(sprite != null){
			//sprite.clipRect = value;
		}
		return value;
	}
	
	public var stage(get, null):ILayoutAdapter;
	function get_stage():ILayoutAdapter {
		if (displayObject.stage == null) return null;
		if (STAGE_ADAPTER == null) {
			STAGE_ADAPTER = new StarlingAdapter(displayObject.stage, null, false);
		}
		return STAGE_ADAPTER;
	}
	
	private var _parent:StarlingAdapter;
	public var parent(get, null):ILayoutAdapter;
	function get_parent():ILayoutAdapter {
		var parentStage:Bool = (displayObject.parent == displayObject.stage);
		if (displayObject.parent == null || parentStage) {
			if (_parent != null) {
				_parent.dispose();
				_parent = null;
			}
			if (parentStage) {
				return stage;
			}else{
				return null;
			}
		}
		if (_parent == null) {
			_parent = new StarlingAdapter(displayObject.parent, null, false);
		}else if (_parent.displayObject != displayObject.parent) {
			_parent.displayObject = displayObject.parent;
		}
		return _parent;
	}
	
	public function updateSize():Void
	{
		_cachedWidth = displayObject.width / displayObject.transformationMatrix.a;
		_cachedHeight = displayObject.height / displayObject.transformationMatrix.d;
	}
	
	public function getTransformationMatrix(targetSpace:Dynamic, ?resultMatrix:Matrix):Matrix
	{
		return displayObject.getTransformationMatrix(targetSpace.displayObject, resultMatrix);
	}
	public function getChildIndex(child:Dynamic):Int
	{
		return displayObjectContainer.getChildIndex(child.displayObject);
	}
	
	function get_added():Bool 
	{
		return displayObject.stage != null;
	}
}

enum StarlingAdapterApplyMode
{
	TRANSFORM;
	WIDTH_HEIGHT;
	SCALE;
}

#end