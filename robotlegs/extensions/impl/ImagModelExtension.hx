package robotlegs.extensions.impl;

import robotlegs.extensions.api.model.config.IConfigModel;
import robotlegs.extensions.impl.model.activity.ActivityModel;
import robotlegs.extensions.impl.model.ExecuteImagModels;
import mantle.model.scene.SceneModel;
import robotlegs.extensions.impl.model.flags.FlagsModel;
import robotlegs.extensions.impl.model.fps.FPSThrottleModel;

#if (flash && !test_flash)
import robotlegs.extensions.impl.model.network.NetworkStatusModel;
#end

import robotlegs.extensions.impl.model.timeout.TimeoutModel;
import robotlegs.bender.extensions.matching.InstanceOfType;
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
class ImagModelExtension implements IExtension
{
	/*============================================================================*/
	/* Private Properties                                                         */
	/*============================================================================*/
	public static var ConfigClass:Class<Dynamic>;
	private var _uid = UID.create(ImagModelExtension);
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
		
		
		context.addConfigHandler(InstanceOfType.call(IConfigModel), handleConfigModel);
		injector.map(ActivityModel).asSingleton();
		injector.map(TimeoutModel).asSingleton();
		injector.map(FPSThrottleModel).asSingleton();
		injector.map(SceneModel).asSingleton();
		injector.map(FlagsModel).asSingleton();
		
		
		
		#if (flash && !test_flash)
			injector.map(NetworkStatusModel).asSingleton();
		#end
		
		context.configure(ExecuteImagModels);
	}
	
	private function handleConfigModel(configModel:IConfigModel):Void
	{
		//ImagModelExtension.ConfigClass = configModel.constructor;
		#if cpp
			ImagModelExtension.ConfigClass = Type.getClass(configModel);
		#else
			ImagModelExtension.ConfigClass = Reflect.getProperty(configModel, "constructor");
		#end
		injector.map(IConfigModel).toSingleton(ImagModelExtension.ConfigClass);
	}
	
	public function toString():String
	{
		return _uid;
	}
}