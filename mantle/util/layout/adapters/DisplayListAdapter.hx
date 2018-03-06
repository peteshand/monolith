package mantle.util.layout.adapters;
import mantle.util.layout.Layout;
import mantle.util.geom.Matrix;
import mantle.util.geom.Rectangle;
import mantle.util.layout.Layout.ILayoutAdapter;
import mantle.util.layout.adapters.DisplayListAdapter.DisplayListAdapterApplyMode;

#if openfl
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
#else
import flash.display.*;
import flash.geom.*;
import flash.events.*;
#end

/**
 * ...
 * @author Thomas Byrne
 */
class DisplayListAdapter implements ILayoutAdapter
{
	private static var STAGE_ADAPTER:DisplayListAdapter;
	
	
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
		}
		return value;
	}
	
	var displayObjectContainer:DisplayObjectContainer;
	var _cachedWidth:Float;
	var _cachedHeight:Float;
	var applyMode:DisplayListAdapterApplyMode;

	public function new(displayObject:DisplayObject, ?applyMode:DisplayListAdapterApplyMode, autoRemove:Bool=true) 
	{
		this.displayObject = displayObject;
		
		if (applyMode == null) {
			this.applyMode = DisplayListAdapterApplyMode.TRANSFORM;
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
	public function forceRemove():Void 
	{
		Layout.remove(displayObject, this);
	}
	public function dispose():Void
	{
		displayObject = null;
	}
	
	
	public var width(get, set):Float;
	function get_width():Float{
		if (displayObject.scrollRect != null || applyMode == DisplayListAdapterApplyMode.TRANSFORM) {
			return _cachedWidth * displayObject.transform.matrix.a;
		}else{
			return displayObject.width;
		}
	}
	function set_width(value:Float):Float{
		return displayObject.width = value;
	}
	
	public var height(get, set):Float;
	function get_height():Float {
		if (displayObject.scrollRect != null || applyMode == DisplayListAdapterApplyMode.TRANSFORM) {
			return _cachedHeight * displayObject.transform.matrix.d;
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
			return displayObject.transform.matrix;
		}else {
			return transformationMatrix;	
		}
	}
	function set_transformationMatrix(value:Matrix):Matrix {
		transformationMatrix = value;
		switch(applyMode) {
			case DisplayListAdapterApplyMode.TRANSFORM:
				displayObject.transform.matrix = value;
			case DisplayListAdapterApplyMode.WIDTH_HEIGHT:
				displayObject.x = value.tx;
				displayObject.y = value.ty;
				displayObject.width = _cachedWidth * value.a;
				displayObject.height = _cachedHeight * value.d;
			case DisplayListAdapterApplyMode.SCALE:
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
		
		if (value != null) {
			
			displayObject.scrollRect = value;
			displayObject.x += value.x * displayObject.transform.matrix.a;
			displayObject.y += value.y * displayObject.transform.matrix.d;
		}else {
			displayObject.scrollRect = null;
		}
		
		return value;
	}
	
	public var stage(get, null):ILayoutAdapter;
	function get_stage():ILayoutAdapter {
		if (displayObject.stage == null) return null;
		if (STAGE_ADAPTER == null) {
			STAGE_ADAPTER = new DisplayListAdapter(displayObject.stage, null, false);
		}
		return STAGE_ADAPTER;
	}
	
	private var _parent:DisplayListAdapter;
	public var parent(get, null):ILayoutAdapter;
	function get_parent():ILayoutAdapter {
		var parentStage:Bool = (displayObject.parent == displayObject.stage);
		if (displayObject.parent == null || parentStage) {
			if (parent != null) {
				_parent.dispose();
				_parent = null;
			}
			if (parentStage) {
				return stage;
			}else{
				return null;
			}
		}
		if (parent == null) {
			_parent = new DisplayListAdapter(displayObject.parent, null, false);
		}else if (_parent.displayObject != displayObject.parent) {
			_parent.displayObject = displayObject.parent;
		}
		return _parent;
	}
	
	public function updateSize():Void
	{
		_cachedWidth = displayObject.width / displayObject.transform.matrix.a;
		_cachedHeight = displayObject.height / displayObject.transform.matrix.d;
	}
	
	public function getTransformationMatrix(targetSpace:Dynamic, ?resultMatrix:Matrix):Matrix
	{
		var mat:Matrix = displayObject.transform.concatenatedMatrix;
		if(targetSpace.displayObject != displayObject.stage){
			var other:Matrix = targetSpace.displayObject.transform.concatenatedMatrix;
			other.invert();
			mat.concat(other);
		}
		if (resultMatrix != null) {
			resultMatrix.copyFrom(mat);
			return resultMatrix;
		}else {
			return mat;
		}
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

enum DisplayListAdapterApplyMode
{
	TRANSFORM;
	WIDTH_HEIGHT;
	SCALE;
}