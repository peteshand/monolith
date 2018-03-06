package robotlegs.extensions.impl;

import robotlegs.extensions.impl.view.ExecuteImagViews;
import robotlegs.bender.framework.api.IContext;
import robotlegs.bender.framework.api.IExtension;
import robotlegs.bender.framework.api.IInjector;
import robotlegs.bender.framework.impl.UID;
import robotlegs.extensions.impl.ImagCommandExtension;

/**
 * ...
 * @author P.J.Shand
 * 
 */
@:keepSub
class ImagViewExtension implements IExtension
{
	/*============================================================================*/
	/* Private Properties                                                         */
	/*============================================================================*/
	
	private var _uid:String;
	private var context:IContext;
	private var injector:IInjector;
	
	public function new() { }
	
	/*============================================================================*/
	/* Public Functions                                                           */
	/*============================================================================*/

	public function extend(context:IContext):Void
	{
		_uid = UID.create(ImagCommandExtension);
		
		this.context = context;
		injector = context.injector;
		
		context.configure([ExecuteImagViews]);
	}
	
	public function toString():String
	{
		return _uid;
	}
}