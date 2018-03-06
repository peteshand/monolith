package mantle.util.layout;
import mantle.util.layout.LayoutEngine;
import mantle.util.layout.Layout;
import mantle.util.geom.Matrix;
import mantle.util.geom.Point;
import mantle.util.layout.Layout.IFrameTracker;
import mantle.util.layout.Layout.LayoutSpaceMode;
import mantle.util.layout.Layout.ILayoutAdapter;
import mantle.util.layout.LayoutEngine.ILayoutSizeProvider;
import mantle.util.layout.LayoutFrame;
import mantle.util.time.EnterFrame;
import msignal.Signal.Signal0;

/**
 * ...
 * @author Thomas Byrne
 */
class LayoutFrame implements IFrameTracker implements ILayoutSizeProvider
{
	private static var DUMMY_POINT:Point = new Point();
	private static var DUMMY_MATRIX:Matrix = new Matrix();
	
	public var sizeChanged:Signal0;
	
	
	var _paddingT:Float = 0;
	var _paddingB:Float = 0;
	var _paddingL:Float = 0;
	var _paddingR:Float = 0;
	
	var _sizeW:Null<Float>;
	var _sizeH:Null<Float>;
	
	var _frameSpace:LayoutSpaceMode = LayoutSpaceMode.LOCAL;
	var sizeProv:ILayoutSizeProvider;
	
	var requestContext:LayoutFrame->Void;
	
	public var layoutSubject:ILayoutAdapter;

	public function new(layoutSubject:ILayoutAdapter, requestContext:LayoutFrame->Void, sizeProv:ILayoutSizeProvider) 
	{
		this.layoutSubject = layoutSubject;
		this.sizeProv = sizeProv;
		this.requestContext = requestContext;
		this.naturalWidth = layoutSubject.width;
		this.naturalHeight = layoutSubject.height;
	}
	
	@:final
	public function remove():Void 
	{
		if (layoutSubject == null) return;
		layoutSubject.forceRemove();
	}
	
	@:allow(mantle.util.layout.Layout)
	private function dispose():Void 
	{
		requestContext = null;
		layoutSubject = null;
		sizeProv = null;
	}
	
	
	public function frame():IFrameTracker 
	{
		if (sizeChanged == null) sizeChanged = new Signal0();
		requestContext(this);
		return this;
	}
	
	public function pad(l:Float = 0, t:Float = 0, r:Float = 0, b:Float = 0) : IFrameTracker
	{
		if (_paddingT == t && _paddingB == b && _paddingL == l && _paddingR == r) return this;
		
		_paddingT = t;
		_paddingB = b;
		_paddingL = l;
		_paddingR = r;
		updateFrame();
		return this;
	}
	
	public function frameSpace(mode:LayoutSpaceMode) : IFrameTracker
	{
		if (_frameSpace == mode) return this;
		updateFrame();
		_frameSpace = mode;
		return this;
	}
	
	public function size(w:Float, h:Float) : IFrameTracker
	{
		if (_sizeW == w && _sizeH == h) return this;
		
		if (naturalWidth == 0) naturalWidth = w;
		if (naturalHeight == 0) naturalHeight = h;
		
		_sizeW = w;
		_sizeH = h;
		updateFrame();
		return this;
	}
	public function getDisplaySpace():Null<ILayoutAdapter>
	{
		if (_frameSpace == LayoutSpaceMode.GLOBAL){
			return layoutSubject.stage;
		}else if (_frameSpace == LayoutSpaceMode.INHERIT) {
			var ret = sizeProv.getDisplaySpace();
			if (ret == null) ret = layoutSubject.stage;
			return ret;
		}else {
			return layoutSubject;
		}
	}
	
	
	
	
	function updateFrame() 
	{
		var frameX:Float = _paddingL;
		var frameY:Float = _paddingT;
		var frameW:Float = _sizeW - _paddingL - _paddingR;
		var frameH:Float = _sizeH - _paddingT - _paddingB;
		
		if (this.x == frameX && this.y == frameY && this.width == frameW && this.height == frameH) return;
		
		setFrameSize(frameX, frameY, frameW, frameH);
	}
	
	function setFrameSize(x:Float, y:Float, w:Float, h:Dynamic) {
		
		var space:ILayoutAdapter = getDisplaySpace();
		if (space != layoutSubject) {
			var parentTrans:Matrix = cast layoutSubject.getTransformationMatrix(space, DUMMY_MATRIX);
			parentTrans.invert();
			
			DUMMY_POINT.x = x;
			DUMMY_POINT.y = y;
			
			parentTrans.transformPoint(DUMMY_POINT);
			x = DUMMY_POINT.x;
			y = DUMMY_POINT.y;
		}
		
		this.x = x;
		this.y = y;
		this.width = w;
		this.height = h;
		if(sizeChanged!=null) sizeChanged.dispatch();
	}
	
	@:isVar public var x(get, null):Float = 0;
	@:isVar public var y(get, null):Float = 0;
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
}