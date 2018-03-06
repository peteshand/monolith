package robotlegs.bundles;

import robotlegs.bender.bundles.mvcs.MVCSBundle;
import robotlegs.bender.extensions.display.stage3D.Stage3DStackExtension;
import robotlegs.extensions.impl.ImagCommandExtension;
import robotlegs.extensions.impl.ImagLogicExtension;
import robotlegs.extensions.impl.ImagModelExtension;
import robotlegs.extensions.impl.ImagServiceExtension;
import robotlegs.extensions.impl.ImagSignalExtension;
import robotlegs.extensions.impl.ImagViewExtension;
import robotlegs.bender.extensions.signalCommandMap.SignalCommandMapExtension;
import robotlegs.bender.extensions.viewManager.ManualStageObserverExtension;
import robotlegs.bender.framework.api.IBundle;
import robotlegs.bender.framework.api.IContext;
import robotlegs.bender.framework.api.LogLevel;

/**
 * The <code>CoreBundle</code> class will include all extensions
 * which are required to create basic sytle applications.
 */

@:keepSub
class CoreBundle implements IBundle
{
	public static var VERSION:String = "1.2";
	/*============================================================================*/
	/* Public Functions                                                           */
	/*============================================================================*/

	/** @inheritDoc **/
	public function extend(context:IContext):Void
	{
		context.install([MVCSBundle]);
		
		context.logLevel = LogLevel.INFO;
		
		context.install([
			ManualStageObserverExtension, 
			SignalCommandMapExtension, 
			ImagLogicExtension,
			ImagViewExtension,
			ImagSignalExtension,
			ImagModelExtension,
			ImagServiceExtension,
			ImagCommandExtension,
			Stage3DStackExtension
		]);
	}
}