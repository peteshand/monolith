package robotlegs.extensions.impl.commands.assets;

import mantle.util.app.App;
import mantle.util.fs.Files;
import robotlegs.bender.bundles.mvcs.Command;
import robotlegs.extensions.api.model.config.IConfigModel;
import robotlegs.extensions.impl.model.config.BaseConfigModel;
import robotlegs.extensions.impl.services.startup.StartupService;
import robotlegs.extensions.impl.signals.assets.S3ResourceSyncComplete;
import robotlegs.bender.framework.api.IInjector;

#if air
	import robotlegs.extensions.impl.services.assets.S3ResourceSyncService;
#end
/**
 * ...
 * @author Thomas Byrne
 */
@:rtti
class SetupS3ResourceSyncCommand extends Command
{
	@inject public var injector:IInjector;
	@inject public var configModel:IConfigModel;
	@inject public var startupService:StartupService;
	@inject public var assetSyncComplete:S3ResourceSyncComplete;

	public function new() { }
	
	override public function execute():Void 
	{
		if (!configModel.resourceSyncEnabled) return;
		
		var remoteAppId:String = configModel.resourceAppId == null ? App.getAppId() : configModel.resourceAppId;
		
		#if air
			var syncService = new S3ResourceSyncService();
			var assetSyncComplete = new S3ResourceSyncComplete();
			injector.map(S3ResourceSyncService).toValue(syncService);
			startupService.addStartupSignal(assetSyncComplete);
			var localPath = Files.resourcesDir();
			syncService.syncRemoteToLocal(localPath, "resource.imagsyd.com/" + remoteAppId + "/", assetSyncComplete.dispatch, "AKIAIJIXWJRKJZDXZGXQ", "vA5FDBCtx2wCPbTC/cxSkjLCqe3RhGzFcl3qQtdV");
		#elseif html5
			Files.setResourceLocation("http://resource.imagsyd.com/" + remoteAppId + "/");
			assetSyncComplete.dispatch();
		#end
	}
}