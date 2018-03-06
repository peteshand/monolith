package robotlegs.extensions.impl.services.startup;
import mantle.util.time.EnterFrame;
import msignal.Signal;
import robotlegs.extensions.impl.signals.AppSetupCompleteSignal;
import robotlegs.bender.framework.api.IInjector;

/**
 * ...
 * @author Thomas Byrne
 */
@:rtti
@:keepSub
class StartupService 
{
	@inject public var injector(default, set):IInjector;
	public function set_injector(value:IInjector):IInjector {
		if (injector == value) return value;
		injector = value;
		
		for (type in types) {
			bindType(type);
		}
		
		return value;
	}
	
	
	@inject public var appReady:AppSetupCompleteSignal;
	
	private var waitingFor:Int = 0;
	private var readyDispatched:Bool;
	private var setupMethods:Array<Void->Void> = [];
	private var setupMethodTypes:Array<Class<Setupable>> = [];
	
	
	private var types:Array<Class<Signal0>>;

	public function new(?signalTypes:Array<Class<Signal0>>) 
	{
		types = [];
		if (signalTypes != null) addStartupSignalTypes(signalTypes);
	}
	
	function bindType(type:Class<Signal0>) 
	{
		var signal:Signal0 = injector.getInstance(type);
		signal.addOnce(onSignal);
	}
	
	function onSignal() 
	{
		--waitingFor;
		if (waitingFor == 0) {
			EnterFrame.delay(recheck);
		}
	}
	
	function recheck() 
	{
		if (waitingFor == 0) {
			readyDispatched = true;
			appReady.dispatch();
			executeSetupMethods();
		}
	}
	
	public function addStartupSignalTypes(signalTypes:Array<Class<Signal0>>) 
	{
		for (type in signalTypes) {
			addStartupSignalType(type);
		}
	}
	
	public function addStartupSignalType(type:Class<Signal0>) 
	{
		if (readyDispatched) throw "Startup has already been fired";
		waitingFor++;
		types.push(type);
		if (injector != null) {
			bindType(type);
		}
	}
	
	public function addStartupSignal(signal:Signal0) 
	{
		if (readyDispatched) throw "Startup has already been fired";
		waitingFor++;
		signal.addOnce(onSignal);
	}
	
	public function addSetupMethod(method:Void->Void) 
	{
		setupMethods.push(method);
	}
	
	public function addSetupMethodType(type:Class<Setupable>) 
	{
		setupMethodTypes.push(type);
	}
	
	
	function executeSetupMethods() 
	{
		if(setupMethods.length > 0){
			for (method in setupMethods){
				method();
			}
			setupMethods = [];
		}
		if(setupMethodTypes.length > 0){
			for (type in setupMethodTypes){
				var setupable:Setupable = injector.getInstance(type);
				setupable.setup();
			}
			setupMethodTypes = [];
		}
	}
}

typedef Setupable =
{
	function setup():Void;
}