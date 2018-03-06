package robotlegs.extensions.impl.commands.config;


import mantle.time.Delay;
import robotlegs.bender.bundles.mvcs.Command;
import robotlegs.extensions.api.model.config.IConfigModel;
import robotlegs.extensions.impl.logic.config.app.SeedConfigLogic;
import robotlegs.extensions.impl.logic.flags.compile.CompileDefineFlagsLogic;

#if (flash && !test_flash)
	import mantle.logic.unexpectedExit.UnexpectedExitLogic;
	import robotlegs.extensions.impl.logic.flags.app.AppFlagsLogic;
	import robotlegs.extensions.impl.logic.config.app.DynamicConfigLogic;
	import robotlegs.extensions.impl.logic.config.app.SaveActiveConfigLogic;
	import robotlegs.extensions.impl.logic.config.app.StaticConfigLogic;
	import robotlegs.extensions.impl.logic.config.app.CommandLineArgsConfigLogic;
#elseif (html5 && !electron)
	import robotlegs.extensions.impl.logic.flags.html.HtmlFlagsLogic;
	import robotlegs.extensions.impl.logic.config.html.HtmlDynamicConfigLogic;
	import robotlegs.extensions.impl.logic.config.html.AttributeConfigLogic;
	import robotlegs.extensions.impl.logic.config.html.QueryConfigLogic;
#end

import robotlegs.extensions.impl.signals.startup.ConfigReadySignal;

/**
 * ...
 * @author P.J.Shand
 */
@:rtti
@:keepSub
class ConfigCommand extends Command 
{
	@inject public var configModel:IConfigModel;
	@inject public var configReadySignal:ConfigReadySignal;
	@inject public var seedConfigLogic:SeedConfigLogic;
	
	@inject public var compileDefineFlagsLogic:CompileDefineFlagsLogic;
	#if (flash && !test_flash)
		@inject public var appFlagsLogic:AppFlagsLogic;
		@inject public var dynamicConfigLogic:DynamicConfigLogic;
		@inject public var staticConfigLogic:StaticConfigLogic;
		@inject public var saveActiveConfigLogic:SaveActiveConfigLogic;
		@inject public var commandLineArgsConfigLogic:CommandLineArgsConfigLogic;
		@inject public var unexpectedExitLogic:UnexpectedExitLogic;
	#elseif (html5 && !electron)
		@inject public var htmlFlagsLogic:HtmlFlagsLogic;
		@inject public var htmlDynamicConfigLogic:HtmlDynamicConfigLogic;
		@inject public var attributeConfigLogic:AttributeConfigLogic;
		@inject public var queryConfigLogic:QueryConfigLogic;
	#end
	
	public function new() { }
	
	override public function execute():Void
	{
		/*#if (flash && !test_flash)
			configSaveService.copyGlobalSeed();
		#end*/
		
		compileDefineFlagsLogic.init();
		
		#if (flash && !test_flash)
			appFlagsLogic.init();
			unexpectedExitLogic.init();
		#end
		
		seedConfigLogic.init();
		
		#if (flash && !test_flash)
			staticConfigLogic.init();
			dynamicConfigLogic.init();
			commandLineArgsConfigLogic.init();
			// for reference only
			saveActiveConfigLogic.init();
		#elseif (html5 && !electron)
			htmlFlagsLogic.init();
			attributeConfigLogic.init();
			queryConfigLogic.init();
		#end
		
		
		
		//configLoadService.onLoadComplete.add(OnLoadComplete);
		//configLoadService.init();
		
		OnLoadComplete();
	}
	
	function OnLoadComplete() 
	{
		// Wait for file to be closed
		Delay.nextFrame(Proceed);
	}
	
	function Proceed() 
	{
		configReadySignal.dispatch();
	}
}