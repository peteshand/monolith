package mantle.logic.unexpectedExit;
import mantle.util.app.App;
import mantle.util.app.AppExit;
import mantle.util.fs.FileTools;
import mantle.util.fs.Files;

using Logger;

/**
 * This adds a file to the disk when the app is running and deletes it during the exit process.
 * This means that if the app starts up and the file exists then the exit was unexpected.
 * 
 * @author Thomas Byrne
 */
class UnexpectedExitLogic 
{
	var filePath:String;

	public function new() 
	{
		
	}
	
	public function init() 
	{
		#if debug
		return;
		#end
		filePath = Files.appDocsDir() + Files.slash() + "running";
		
		
		if (FileTools.exists(filePath)){
			error("Last time the application run it quit unexpectedly.");
		}else{
			FileTools.saveContent(filePath, "This file is saved while the app is running and deleted when it exits.");
		}
		
		AppExit.addExitCleanup(onAppExit);
	}
	
	function onAppExit(code:Int, contHandler:Void->Void) 
	{
		FileTools.deleteFile(filePath);
	}
}