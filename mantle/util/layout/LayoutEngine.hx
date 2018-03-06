package mantle.util.layout;
import mantle.util.geom.Matrix;
import mantle.util.geom.Point;
import mantle.util.geom.Rectangle;
import mantle.util.layout.Layout;
import mantle.util.layout.Layout.ILayoutTracker;
import mantle.util.layout.Layout.LayoutBoundsMode;
import mantle.util.layout.Layout.LayoutRatioMode;
import mantle.util.layout.Layout.LayoutScaleMode;
import mantle.util.layout.Layout.LayoutSpaceMode;
import mantle.util.layout.Layout.ILayoutAdapter;
import mantle.util.time.EnterFrame;
import mantle.util.layout.LayoutFrame;
import msignal.Signal.Signal0;

/**
 * ...
 * @author Thomas Byrne
 */
class LayoutEngine extends LayoutFrame implements ILayoutTracker
{
	private static var DUMMY_POINT:Point = new Point();
	private static var DUMMY_MATRIX:Matrix = new Matrix();
	private static var DUMMY_RECT:Rectangle = new Rectangle();
	
	
	public var alignXFract(get, set):Float;
	public var alignYFract(get, set):Float;
	public var alignXOffset(get, set):Float;
	public var alignYOffset(get, set):Float;
	
	var _alignXFract:Float = 0;
	var _alignYFract:Float = 0;
	var _alignXOffset:Float = 0;
	var _alignYOffset:Float = 0;
	
	public var centerXFract(get, set):Null<Float>;
	public var centerYFract(get, set):Null<Float>;
	public var centerXOffset(get, set):Float;
	public var centerYOffset(get, set):Float;
	
	var _centerXFract:Null<Float>;
	var _centerYFract:Null<Float>;
	var _centerXOffset:Float = 0;
	var _centerYOffset:Float = 0;
	
	var posMode:LayoutPosMode = LayoutPosMode.NONE;
	
	var scaleModeX:LayoutScaleMode = LayoutScaleMode.NEVER;
	var scaleModeY:LayoutScaleMode = LayoutScaleMode.NEVER;
	var ratioMode:LayoutRatioMode = LayoutRatioMode.STRETCH;
	var boundsMode:LayoutBoundsMode = LayoutBoundsMode.NATURAL;
	
	var _posX:Float = 0;
	var _posY:Float = 0;
	
	var rectSet:Bool;
	
	var pendingUpdate:Bool;
	var renderEveryFrame:Bool;
	var isFrame:Bool;
	var level:Int;
	

	public function new(layoutSubject:ILayoutAdapter, requestContext:LayoutFrame->Void, sizeProv:ILayoutSizeProvider, level:Int) 
	{
		super(layoutSubject, requestContext, sizeProv);
		this.level = level;
		_frameSpace = LayoutSpaceMode.INHERIT;
		
		sizeProv.sizeChanged.addWithPriority(onSizeChanged, -level);
		markForUpdate();
	}
	
	function onSizeChanged() 
	{
		if(pendingUpdate)EnterFrame.remove(doUpdate);
		update();
	}
	
	public function align(xFract:Float, yFract:Float, ?xOffset:Float, ?yOffset:Float):ILayoutTracker 
	{
		if (posMode==LayoutPosMode.ALIGN && _alignXFract == xFract && _alignYFract == yFract &&
		(xOffset == null || _alignXOffset == xOffset) && (yOffset == null || _alignYOffset == yOffset)) return this;
		
		posMode = LayoutPosMode.ALIGN;
		
		_alignXFract = xFract;
		_alignYFract = yFract;
		
		if (xOffset != null) _alignXOffset = xOffset;
		if (yOffset != null) _alignYOffset = yOffset;
		markForUpdate();
		
		return this;
	}
	
	public function alignOffset(xOffset:Float, yOffset:Float):ILayoutTracker 
	{
		if (_alignXOffset == xOffset && _alignYOffset == yOffset) return this;
		
		_alignXOffset = xOffset;
		_alignYOffset = yOffset;
		if(posMode==LayoutPosMode.ALIGN)markForUpdate();
		
		return this;
	}
	
	public function center(xFract:Float, yFract:Float, ?xOffset:Float, ?yOffset:Float):ILayoutTracker 
	{
		if (_centerXFract == xFract && _centerYFract == yFract &&
		(xOffset == null || _centerXOffset == xOffset) && (yOffset == null || _centerYOffset == yOffset)) return this;
		
		_centerXFract = xFract;
		_centerYFract = yFract;
		
		if (xOffset != null) _centerXOffset = xOffset;
		if (yOffset != null) _centerYOffset = yOffset;
		markForUpdate();
		
		return this;
	}
	
	public function centerOffset(xOffset:Float, yOffset:Float):ILayoutTracker 
	{
		if (_centerXOffset == xOffset && _centerYOffset == yOffset) return this;
		
		_centerXOffset = xOffset;
		_centerYOffset = yOffset;
		markForUpdate();
		
		return this;
	}
	
	public function pos(x:Float, y:Float) : ILayoutTracker
	{
		if (posMode==LayoutPosMode.ABSOLUTE && _posX == x && _posY == y) return this;
		
		posMode = LayoutPosMode.ABSOLUTE;
		_posX = x;
		_posY = y;
		markForUpdate();
		return this;
	}
	override public function size(w:Float, h:Float) : ILayoutTracker
	{
		if (_sizeW == w && _sizeH == h && scaleModeX == LayoutScaleMode.NEVER && scaleModeY == LayoutScaleMode.NEVER) return this;
		
		_sizeW = w;
		_sizeH = h;
		markForUpdate();
		return scale(LayoutScaleMode.NEVER);
	}
	
	public function fill():ILayoutTracker 
	{
		return scale(LayoutScaleMode.ALWAYS);
	}
	
	public function noScale():ILayoutTracker 
	{
		return scale(LayoutScaleMode.NEVER);
	}
	
	public function scale(mode:LayoutScaleMode):ILayoutTracker 
	{
		if (scaleModeX == mode && scaleModeY == mode) return this;
		
		scaleModeX = mode;
		scaleModeY = mode;
		markForUpdate();
		
		return this;
	}
	
	public function scaleX(mode:LayoutScaleMode):ILayoutTracker 
	{
		if (scaleModeX == mode) return this;
		
		scaleModeX = mode;
		markForUpdate();
		
		return this;
	}
	
	public function scaleY(mode:LayoutScaleMode):ILayoutTracker 
	{
		if (scaleModeY == mode) return this;
		
		scaleModeY = mode;
		markForUpdate();
		
		return this;
	}
	
	public function ratio(mode:LayoutRatioMode):ILayoutTracker 
	{
		if (ratioMode == mode) return this;
		
		ratioMode = mode;
		markForUpdate();
		
		return this;
	}
	
	public function bounds(mode:LayoutBoundsMode):ILayoutTracker 
	{
		if (boundsMode == mode) return this;
		
		boundsMode = mode;
		markForUpdate();
		
		return this;
	}
	
	public function everyFrame():ILayoutTracker 
	{
		renderEveryFrame = true;
		EnterFrame.signal.addWithPriority(update, -level);
		sizeProv.sizeChanged.remove(onSizeChanged);
		return this;
	}
	
	override function updateFrame() 
	{
		markForUpdate();
	}
	
	function markForUpdate() 
	{
		if (pendingUpdate || renderEveryFrame) return;
		pendingUpdate = true;
		EnterFrame.signal.addOnceWithPriority(doUpdate, -level);
	}
	
	function doUpdate() 
	{
		pendingUpdate = false;
		update();
	}
	
	public function update() : Void
	{
		if (!layoutSubject.added) return;
		
		if (pendingUpdate) {
			pendingUpdate = false;
			EnterFrame.remove(doUpdate);
		}
		var alignBoxY:Float = sizeProv.y;
		var alignBoxX:Float = sizeProv.x;
		var alignBoxW:Float = sizeProv.width;
		var alignBoxH:Float = sizeProv.height;
		
		if (alignBoxW == 0 || alignBoxH == 0) return;
		
		if(rectSet){
			layoutSubject.clipRect = null;
			rectSet = false;
		}
			
		
		DUMMY_MATRIX.copyFrom(layoutSubject.transformationMatrix);
		DUMMY_MATRIX.invert();
		
		DUMMY_POINT.x = layoutSubject.width;
		DUMMY_POINT.y = layoutSubject.height;
		DUMMY_POINT = DUMMY_MATRIX.deltaTransformPoint(DUMMY_POINT);
		
		var displayW = DUMMY_POINT.x;
		var displayH = DUMMY_POINT.y;
		
		var boundsW:Float;
		var boundsH:Float;
		switch(boundsMode) {
			case LayoutBoundsMode.OBJECT:
				boundsW = displayW;
				boundsH = displayH;
						
			case LayoutBoundsMode.NATURAL:
				boundsW = sizeProv.naturalWidth;
				boundsH = sizeProv.naturalHeight;
				
		}
		
		var destScaleX:Float = alignBoxW / boundsW;
		var destScaleY:Float = alignBoxH / boundsH;
		
		switch(scaleModeX) {
			case LayoutScaleMode.ALWAYS:
				// ignore
			case LayoutScaleMode.NEVER:
				if (_sizeW != null) {
					destScaleX = _sizeW / boundsW;
				}else{
					destScaleX = 1;
				}
			case LayoutScaleMode.DOWN_ONLY:
				if (destScaleX > 1) destScaleX = 1;
			case LayoutScaleMode.UP_ONLY:
				if (destScaleX < 1) destScaleX = 1;
				
		}
		
		switch(scaleModeY) {
			case LayoutScaleMode.ALWAYS:
				// ignore
			case LayoutScaleMode.NEVER:
				if (_sizeH != null) {
					destScaleY = _sizeH / boundsH;
				}else{
					destScaleY = 1;
				}
			case LayoutScaleMode.DOWN_ONLY:
				if (destScaleY > 1) destScaleY = 1;
			case LayoutScaleMode.UP_ONLY:
				if (destScaleY < 1) destScaleY = 1;
				
		}
		
		var destW:Float;
		var destH:Float;
		var crop:Bool = false;
		var cropV:Bool = false;
		
		switch(ratioMode) {
			case LayoutRatioMode.CROP:
				crop = true;
				if (destScaleX > destScaleY) {
					destScaleY = destScaleX;
					cropV = true;
				}else {
					destScaleX = destScaleY;
					cropV = false;
				}
				
			case LayoutRatioMode.PAD:
				if (destScaleX < destScaleY) {
					destScaleY = destScaleX;
				}else {
					destScaleX = destScaleY;
				}
				
			case LayoutRatioMode.STRETCH:
				
			case LayoutRatioMode.HORIZONTAL:
				crop = destScaleY < destScaleX;
				cropV = true;
				destScaleY = destScaleX;
				
			case LayoutRatioMode.VERTICAL:
				crop = destScaleX < destScaleY;
				cropV = false;
				destScaleX = destScaleY;
				
		}
		destW = destScaleX * boundsW;
		destH = destScaleY * boundsH;
		
		var centX:Float = (_centerXFract==null ? _alignXFract : _centerXFract) + _centerXOffset;
		var centY:Float = (_centerYFract==null ? _alignYFract : _centerYFract) + _centerYOffset;
		
		var alignPointX:Float = alignBoxX + alignBoxW * _alignXFract + _alignXOffset;
		var alignPointY:Float = alignBoxY + alignBoxH * _alignYFract + _alignYOffset;
		
		var mat:Matrix = new Matrix();
		mat.scale(destW / boundsW, destH / boundsH);
		
		var destX:Float;
		var destY:Float;
		if (posMode == LayoutPosMode.ABSOLUTE) {
			destX = _posX;
			destY = _posY;
			
		}else {
			/*if (crop) {
				destX = alignPointX - alignBoxW * centX;
				destY = alignPointY - alignBoxH * centY;
			
			}else {*/
				destX = alignPointX - (displayW * destScaleX) * centX;
				destY = alignPointY - (displayH * destScaleY) * centY;
			//}
			
			mat.translate(destX, destY);
		}
		
		var parentTrans:Matrix = cast layoutSubject.parent.getTransformationMatrix(getDisplaySpace(), DUMMY_MATRIX);
		parentTrans.invert();
		
		mat.concat(parentTrans);
		if (posMode == LayoutPosMode.NONE) {
			mat.tx = layoutSubject.transformationMatrix.tx;
			mat.ty = layoutSubject.transformationMatrix.ty;
		}
		
		layoutSubject.transformationMatrix = mat;
		
		if (crop) {
			var rect:Rectangle = DUMMY_RECT;
			if(cropV){
				rect.width = destW;
				rect.x = 0;
				rect.height = alignBoxH;
				rect.y = (destH - alignBoxH - (boundsH - displayH) * destScaleY) * centY;
			}else {
				rect.width = alignBoxW;
				rect.x = (destW - alignBoxW - (boundsW - displayW) * destScaleX) * centX;
				rect.height = destH;
				rect.y = 0;
			}
			
			rect.x *= parentTrans.a / mat.a;
			rect.y *= parentTrans.d / mat.d;
			rect.width *= parentTrans.a / mat.a;
			rect.height *= parentTrans.d / mat.d;
			layoutSubject.clipRect = rect;
			rectSet = true;
		}
		
		if(sizeChanged != null){
			if (isFrame) {
				setFrameSize(0,0,destW,destH);
			}else {
				setFrameSize(-destX,-destY,alignBoxW,alignBoxH);
			}
		}
	}
	override private function dispose():Void 
	{
		sizeProv.sizeChanged.remove(onSizeChanged);
		if(pendingUpdate)EnterFrame.remove(doUpdate);
		super.dispose();
	}
	
	
	// Getter/Setters, mostly for tweening
	function get_alignXFract():Float 
	{
		return _alignXFract;
	}
	function set_alignXFract(value:Float):Float 
	{
		_alignXFract = value;
		markForUpdate();
		return value;
	}
	
	function get_alignYFract():Float 
	{
		return _alignYFract;
	}
	function set_alignYFract(value:Float):Float 
	{
		_alignYFract = value;
		markForUpdate();
		return value;
	}
	
	function get_alignXOffset():Float 
	{
		return _alignXOffset;
	}
	function set_alignXOffset(value:Float):Float 
	{
		_alignXOffset = value;
		markForUpdate();
		return value;
	}
	
	function get_alignYOffset():Float 
	{
		return _alignYOffset;
	}
	function set_alignYOffset(value:Float):Float 
	{
		_alignYOffset = value;
		markForUpdate();
		return value;
	}
	
	function get_centerXFract():Null<Float> 
	{
		return _centerXFract;
	}
	function set_centerXFract(value:Null<Float>):Null<Float> 
	{
		_centerXFract = value;
		markForUpdate();
		return value;
	}
	
	function get_centerYFract():Null<Float> 
	{
		return _centerYFract;
	}
	function set_centerYFract(value:Null<Float>):Null<Float> 
	{
		_centerYFract = value;
		markForUpdate();
		return value;
	}
	
	function get_centerXOffset():Float 
	{
		return _centerXOffset;
	}
	function set_centerXOffset(value:Float):Float 
	{
		_centerXOffset = value;
		markForUpdate();
		return value;
	}
	
	function get_centerYOffset():Float 
	{
		return _centerYOffset;
	}
	function set_centerYOffset(value:Float):Float 
	{
		_centerYOffset = value;
		markForUpdate();
		return value;
	}
	
}

interface ILayoutSizeProvider 
{
	var sizeChanged:Signal0;
	
	var x(get, null):Float;
	var y(get, null):Float;
	var width(get, null):Float;
	var height(get, null):Float;
	var naturalWidth(get, null):Float;
	var naturalHeight(get, null):Float;
	
	function getDisplaySpace():Null<ILayoutAdapter>;
}


@:enum
abstract LayoutPosMode(String)
{
    var NONE = "none";
    var ABSOLUTE = "absolute";
    var ALIGN = "align";
}