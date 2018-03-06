package mantle.util.log.air;
import mantle.util.log.Log;
import mantle.time.Delay;
import mantle.util.app.App;
import mantle.util.fs.Files;
import mantle.util.log.Log.LogLevel;
import mantle.util.log.customTrace.CustomTrace;
import flash.display.DisplayObject;
import flash.errors.Error;
import flash.events.UncaughtErrorEvent;
import flash.system.Capabilities;
import mantle.util.log.LogFormatImpl;
import mantle.util.log.MassErrorQuitLogger;
import mantle.util.log.MethodCallLogger;
import mantle.util.log.TraceLogger;

#if raven
	import mantle.util.log.SentryLogger;
#end

/**
 * ...
 * @author Thomas Byrne
 */
class DefaultAirLog
{
	private static var installed:Bool;
	public static var criticalErrorCodes:Array<Int> = [
					3691 // Resource limit exceeded
					];
					
	private static var restartRequested:Bool;
	
	public static function install(root:DisplayObject, ?restartApp:Void->Void):Void
	{
		if (installed) return;
		installed = true;
		
		var docsDir:String  = Files.appDocsDir();
		
		// Must be runtime conditional because of SWC packaging
		//if(Capabilities.isDebugger){
			Log.mapHandler(new TraceLogger(LogFormatImpl.fdFormat), Log.ALL_LEVELS);
		//}
		
		Log.mapHandler(new HtmlFileLogger(docsDir + "log" + Files.slash(), true), Log.ALL_LEVELS);
		
		Log.mapHandler(new HtmlFileLogger(docsDir + "errorLog" + Files.slash(), false), [LogLevel.UNCAUGHT_ERROR, LogLevel.ERROR, LogLevel.CRITICAL_ERROR]);
		
		Log.mapHandler(new HtmlFileLogger(docsDir + "errorLog" + Files.slash(), false), [LogLevel.CRITICAL_ERROR]);
		
		Log.mapHandler(new MassErrorQuitLogger(), [LogLevel.UNCAUGHT_ERROR, LogLevel.CRITICAL_ERROR]);
		
		if(restartApp != null) Log.mapHandler(new MethodCallLogger(restartApp), [LogLevel.CRITICAL_ERROR]);
		
		root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError.bind(_, restartApp));
		
		CustomTrace.install();
	}
	
	#if raven
	public static function installSentry(sentryDsn:String, ?terminalName:String):Void
	{
		if(terminalName==null)Logger.log(DefaultAirLog, "No 'terminalName' found, will track using IP address (set this up with global config in ~/Docs/imagination/_global/config.json)");
		Log.mapHandler(new SentryLogger(App.getAppId(), sentryDsn, terminalName), [LogLevel.UNCAUGHT_ERROR, LogLevel.ERROR, LogLevel.CRITICAL_ERROR, LogLevel.WARN]);
	}
	#end
	
	
	public static function installIdmLog():Void
	{
		var docsDir:String  = Files.appDocsDir();
		var jsonLogger:SimpleJsonLogger = new SimpleJsonLogger(docsDir + "idm/log", false);
		Log.mapHandler(jsonLogger, [LogLevel.UNCAUGHT_ERROR, LogLevel.ERROR, LogLevel.CRITICAL_ERROR]);
	}
	
	private static function onUncaughtError(e:UncaughtErrorEvent, ?restartApp:Void->Void):Void 
	{
		var message:String;
		if (Reflect.hasField(e.error, "message"))
		{
			message = Reflect.field(e.error, "message");
		}
		else if (Reflect.hasField(e.error, "text"))
		{
			message = Reflect.field(e.error, "text");
		}
		else
		{
			message = Std.string(e.error);
		}
		var err:Error = cast(e.error);
		if (err != null) {
			Log.log(e.target, LogLevel.UNCAUGHT_ERROR, [criticalErrorCodes.indexOf(err.errorID), "\n"+err.getStackTrace()]);
			
			if (!restartRequested && restartApp!=null && criticalErrorCodes.indexOf(err.errorID) != -1){
				Logger.error(e.target, "Critical error "+err.errorID+" caught, attempting restart");
				Delay.byFrames(1, restartApp);
				restartRequested = true;
			}
		}else {
			Logger.error(e.target, message);
		}
		e.preventDefault();
		
	}
	
}