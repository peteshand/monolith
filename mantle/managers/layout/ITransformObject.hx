package mantle.managers.layout;

/**
 * @author P.J.Shand
 */
interface ITransformObject 
{
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
	
	#if swc @:getter(scaleX) #end
	public function get_scaleX():Float;
	#if swc @:getter(scaleY) #end
	public function get_scaleY():Float;
	
	/*#if swc @:setter(scaleContainerScaleX) #end*/
	public function set_scaleContainerScaleX(value:Float):Float;
	/*#if swc @:setter(scaleContainerScaleY) #end*/
	public function set_scaleContainerScaleY(value:Float):Float;
	/*#if swc @:setter(frameAnchorX) #end*/
	public function set_frameAnchorX(value:Float):Float;
	/*#if swc @:setter(frameAnchorY) #end*/
	public function set_frameAnchorY(value:Float):Float;
	/*#if swc @:setter(displayAnchorX) #end*/
	public function set_displayAnchorX(value:Float):Float;
	/*#if swc @:setter(displayAnchorY) #end*/
	public function set_displayAnchorY(value:Float):Float;
	
	function frameAnchor(fractionX:Float=0, fractionY:Float=0, pixelX:Float=0, pixelY:Float=0):ITransformObject;
	function displayAnchor(fractionX:Float = 0, fractionY:Float = 0, pixelX:Float = 0, pixelY:Float = 0):ITransformObject;
	function frame(value:Dynamic):ITransformObject;
	
	function scaleMode(value:String):ITransformObject;
	function vScaleMode(value:String):ITransformObject;
	function hScaleMode(value:String):ITransformObject;
	
}