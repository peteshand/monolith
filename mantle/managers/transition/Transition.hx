package mantle.managers.transition;

import mantle.managers.transition.plugins.TransitionPlugins;
import mantle.notifier.Notifier;
import mantle.time.Delay;
import motion.Actuate;
import motion.actuators.GenericActuator;
import motion.easing.Linear;
import mantle.util.signals.Signal;
import openfl.errors.Error;

/**
 * ...
 * @author P.J.Shand
 */
class Transition extends BaseNotifier<Null<Float>>
{
	public var showTime:Float = 1;
	public var showDelay:Float = 0;
	
	public var hideTime:Float = 1;
	public var hideDelay:Float = 0;
	
	public var showing:Null<Bool>;
	
	private var transitionObjects = new Array<TransitionObject>();
	private var queuedFunction:Void->Void;
	
	private var transitioningIn = new Notifier<Bool>(false);
	private var transitioningOut = new Notifier<Bool>(false);
	
	private static var tweenCountReg = new Map<Transition, Bool>();
	public static var globalTweenCount = new Notifier<Int>(0);
	public static var globalTransitioning = new Notifier<Bool>(false);
	
	private static var linearEaseNone:motion.easing.Linear.LinearEaseNone;
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	public var onShowStart = new Signal0();														////
	public var onShowUpdate = new Signal0();													////
	public var onShowComplete = new Signal0();													////
																								////
	public var onHideStart = new Signal0();														////
	public var onHideUpdate = new Signal0();													////
	public var onHideComplete = new Signal0();													////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	public var isTweening = new Notifier<Bool>(false);
	public var totalTransTime(get, null):Float;
	
	public var sceneTransition:Bool = false;
	public var queueTransitions:Bool = true;
	
	//private var _value:Null<Float>;
	//public var value(get, set):Float;
	
	
	var target:Dynamic;
	var tween:GenericActuator<Transition>;
	
	//public var state = new Notifier<String>(null);
	
	public var startHidden:Bool = true;
	
	static public inline var SHOW:String = "show";
	static public inline var HIDE:String = "hide";
	// --------------------------------------------------- //
	
	public function new(showTime:Float=1, hideTime:Float=1, showDelay:Float=0, hideDelay:Float=0,startHidden:Bool=true) 
	{
		TransitionPlugins.installStandard();
		
		this.showTime = showTime;
		this.hideTime = hideTime;
		this.showDelay = showDelay;
		this.hideDelay = hideDelay;
		this.startHidden = startHidden;
		
		if (linearEaseNone == null) linearEaseNone = new LinearEaseNone();
		//onShowUpdate.add(ActivityModel.animating);
		//onHideUpdate.add(ActivityModel.animating);
		
		globalTweenCount.change.add(OnTweenCountChange);
		isTweening.change.add(OnIsTweeningChange);
		
		super();
	}
	
	function OnIsTweeningChange() 
	{
		if (sceneTransition) {
			if (isTweening.value) {
				tweenCountReg.set(this, true);
				globalTweenCount.value = countReg(tweenCountReg);
			}
			else {
				tweenCountReg.remove(this);
				globalTweenCount.value = countReg(tweenCountReg);
			}
		}
	}
	
	function OnTweenCountChange() 
	{
		if (globalTweenCount.value == 0) globalTransitioning.value = false;
		else globalTransitioning.value = true;
	}
	
	// --------------------------------------------------- //
	/* @param target Target object whose properties this tween affects. 
	*  @param tweenObject, dynamic object containing properties to tweet, with a [hide, show] value, or [hide, show, hide] value. 
	*  @param options, TransitionSettings typedef object containing tween options. Options are as follows: 
	* "ease", "showEase", "hideEase", "autoVisible", "autoVisObject", "start", "end", "startHidden",
	*  @return Void */
	
	public function add(target:Dynamic, properties:Dynamic=null, options:TransitionSettings=null):ITransitionObject 
	{
		this.target = target;
		
		if (!target) throw new Error("target must not be null");
		var transitionObject = getTransitionObject(target);
		transitionObject.onSet.add(UpdateStartValues);
		transitionObject.set(properties, options);
		
		if (_value == null) {
			if (startHidden) value = -1;
			else value = 0;
		}
		else {
			this.value = _value;
		}
		return cast transitionObject;
	}
	
	private function UpdateStartValues() 
	{
		
	}
	
	public function remove(target:Dynamic, vars:Dynamic=null):Void 
	{
		if (vars != null) {
			getTransitionObject(target).remove(vars);
		}
		else {
			for (transitionObject in transitionObjects) 
			{
				if (transitionObject.target == target) {
					transitionObject.dispose();
					transitionObjects.remove(transitionObject);
				}
			}
		}
	}
	
	
	/*#if swc @:protected #end*/
	private function getTransitionObject(target:Dynamic):TransitionObject 
	{
		var transitionObject = new TransitionObject(target);
		transitionObject.target = target;
		transitionObjects.push(transitionObject);
		return transitionObject;
	}
	
	override private function set_value(v:Null<Float>):Null<Float> 
	{
		if (_value == v && requireChange) return v;
		if (_value != null && _unsetHandlers != null) {
			for(handler in _unsetHandlers) handler(_value);
		}
		
		///////////////////////////////////////////////////////
		///////////////////////////////////////////////////////
		_value = v;
		if (_value == 0) this.showing = true;
		else if (_value <= -1 || _value >= 1) this.showing = false;
		
		if (_value < -1) _value = -1;
		else if (_value > 1) _value = 1;
		
		if (transitionObjects == null) {
			throw new Error("this transition object has been disposed and should not be referenced");
		}
		for (i in 0...transitionObjects.length)
		{	
			transitionObjects[i].update(_value);
		}
		///////////////////////////////////////////////////////
		///////////////////////////////////////////////////////
		
		if (_value != null && _setHandlers != null) {
			for(handler in _setHandlers) handler(_value);
		}
		
		change.dispatch();
		return v;
	}
	
	private function queue(func:Void->Void):Void 
	{
		queuedFunction = func;
	}
	
	// --------------------------------------------------- //
	
	public function Show():Void
	{
		if (isTweening.value && queueTransitions) {
			queue(Show);
			return;
		}
		
		if (showing == true) return;
		if (showing == null) {
			ShowJump();
			showing = true;
			return;
		}
		showing = true;
		
		if(_value == 1) this.value = -1;
		
		KillDelays();
		isTweening.value = true;
		if (showTime == 0) {
			if (showDelay == 0) ShowJump();
			else Delay.byTime(showDelay, ShowJump);
		}
		else {
			if (showDelay == 0) ShowTween();
			else Delay.byTime(showDelay, ShowTween);
		}
	}
	
	function KillDelays() 
	{
		Delay.killDelay(HideJump);
		Delay.killDelay(HideTween);
		Delay.killDelay(ShowJump);
		Delay.killDelay(ShowTween);
	}
	
	private function ShowTween():Void 
	{
		PrivateShowOnStart();
		Actuate.stop(this);
		if (tween != null) {
			Actuate.unload(tween);
		}
		tween = Actuate.tween(this, showTime, { value:0 } ).onUpdate(PrivateShowOnUpdate).onComplete(PrivateShowOnComplete).ease(linearEaseNone);
	}
	
	private function ShowJump():Void 
	{
		PrivateShowOnStart();
		this.value = 0;
		PrivateShowOnUpdate();
		PrivateShowOnComplete();
	}
	
	public function Hide():Void
	{
		if (isTweening.value && queueTransitions) {
			queue(Hide);
			return;
		}
		
		if (showing == false) return;
		if (showing == null) {
			HideJump();
			showing = false;
			return;
		}
		showing = false;
		
		KillDelays();
		isTweening.value = true;
		if (hideTime == 0) {
			if (hideDelay == 0) HideJump();
			else Delay.byTime(hideDelay, HideJump);
		}
		else {
			if (hideDelay == 0) HideTween();
			else Delay.byTime(hideDelay, HideTween);
		}
	}
	
	public function dispose() 
	{
		if (transitionObjects == null) return;
		
		Actuate.stop(this);
		
		var i:Int = transitionObjects.length - 1;
		while (i >= 0) 
		{
			transitionObjects[i].dispose();
			transitionObjects.splice(i, 1);
			i--;
		}
		queuedFunction = null;
		change.removeAll();
		onShowStart.removeAll();
		onShowUpdate.removeAll();
		onShowComplete.removeAll();
		onHideStart.removeAll();
		onHideUpdate.removeAll();
		onHideComplete.removeAll();
		target = null;
		
		if (tween != null) Actuate.unload(tween);
		
		tween = null;
	}
	
	private function HideTween():Void
	{
		PrivateHideOnStart();
		Actuate.stop(this);
		if (tween != null){
			Actuate.unload(tween);
		}
		tween = Actuate.tween(this, hideTime, { value:1 } ).onUpdate(PrivateHideOnUpdate).onComplete(PrivateHideOnComplete).ease(linearEaseNone);
	}
	
	private function HideJump():Void 
	{
		PrivateHideOnStart();
		this.value = 1;
		PrivateHideOnUpdate();
		PrivateHideOnComplete();
	}
	
	// --------------------------------------------------- //
	
	private function PrivateShowOnStart():Void 
	{
		transitioningIn.value = true;
		for (i in 0...transitionObjects.length) transitionObjects[i].showBegin();
		onShowStart.dispatch();
	}
	
	private function PrivateShowOnUpdate():Void 
	{
		onShowUpdate.dispatch();
	}
	
	private function PrivateShowOnComplete():Void 
	{
		isTweening.value = false;
		transitioningIn.value = false;
		for (i in 0...transitionObjects.length) transitionObjects[i].showEnd();
		onShowComplete.dispatch();
		checkQueue();
	}
	
	// --------------------------------------------------- //
	
	private function PrivateHideOnStart():Void 
	{
		transitioningOut.value = true;
		for (i in 0...transitionObjects.length) transitionObjects[i].hideBegin();
		onHideStart.dispatch();
	}
	
	private function PrivateHideOnUpdate():Void 
	{
		onHideUpdate.dispatch();
	}
	
	private function PrivateHideOnComplete():Void 
	{
		isTweening.value = false;
		transitioningOut.value = false;
		for (i in 0...transitionObjects.length) transitionObjects[i].hideEnd();
		onHideComplete.dispatch();
		checkQueue();
	}
	
	function countReg(tweenCountReg:Map<Transition, Bool>):Int
	{
		var count:Int = 0;
		for (key in tweenCountReg.keys()) 
		{
			count++;
		}
		return count;
	}
	
	private function checkQueue():Void 
	{
		if (queuedFunction != null) {
			queuedFunction();
			queuedFunction = null;
		}
	}
	
	function get_totalTransTime():Float 
	{
		return showDelay + showTime + hideDelay + hideTime;
	}
}
