package robotlegs.extensions.impl;

import robotlegs.extensions.api.services.keyboard.IKeyboardMap;
import robotlegs.extensions.impl.services.activity.ActivityMonitorService;
import robotlegs.extensions.impl.services.config.ConfigLoadService;
import robotlegs.extensions.impl.services.config.ConfigSaveService;
import robotlegs.extensions.impl.services.email.EmailService;
import robotlegs.extensions.impl.services.fps.FpsThrottleService;
import robotlegs.extensions.impl.services.keyboard.KeyboardMap;
//import robotlegs.extensions.imag.impl.services.parse.ParseService;
import robotlegs.extensions.impl.services.startup.StartupService;
import robotlegs.extensions.impl.services.timeout.TimeoutService;
import robotlegs.bender.framework.api.IContext;
import robotlegs.bender.framework.api.IExtension;
import robotlegs.bender.framework.api.IInjector;
import robotlegs.bender.framework.impl.UID;

/**
 * ...
 * @author P.J.Shand
 * 
 */
@:keepSub
class ImagServiceExtension implements IExtension
{
	/*============================================================================*/
	/* Private Properties                                                         */
	/*============================================================================*/
	
	private var _uid:String = UID.create(ImagServiceExtension);
	private var context:IContext;
	private var injector:IInjector;
	
	public function new() { }
	
	/*============================================================================*/
	/* Public Functions                                                           */
	/*============================================================================*/
	
	public function extend(context:IContext):Void
	{
		this.context = context;
		injector = context.injector;
		
		injector.map(IKeyboardMap).toSingleton(KeyboardMap);
		
		injector.map(StartupService).asSingleton();
		
		injector.map(ConfigSaveService).asSingleton();
		injector.map(ConfigLoadService).asSingleton();
		
		injector.map(TimeoutService).asSingleton();
		injector.map(ActivityMonitorService).asSingleton();
		injector.map(FpsThrottleService).asSingleton();
	}
	
	public function toString():String
	{
		return _uid;
	}
}