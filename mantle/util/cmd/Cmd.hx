package mantle.util.cmd;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.Vector;
import openfl.events.IOErrorEvent;

/**
 * ...
 * @author Thomas Byrne
 */
class Cmd
{
	public static function runCmd(win:Bool, cmd:String, ?onComplete:String -> Void) 
	{
		var exe;
		var args = new Vector<String>();
		if (win) {
			exe = new File("C:\\Windows\\System32\\cmd.exe");
			
			cmd = cmd.split("\r\n").join("\n");
			cmd = cmd.split("\r").join(" & ");
			cmd = cmd.split("\n").join(" & ");
			args.push("/C");
			args.push(cmd);
		}else {
			throw "Not yet supported";
		}
		if (!exe.exists) {
			throw "This command is not supported on this platform";
		}
		
		var nativeProcessStartupInfo = new NativeProcessStartupInfo();
		nativeProcessStartupInfo.executable = exe;
		nativeProcessStartupInfo.arguments = args;
		
		var process = new NativeProcess(); 
		var output:Array<String> = [];
		var error:Array<String> = [];
		if(onComplete!=null){
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onCmdOutput.bind(_, output, process, cmd));
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onCmdError.bind(_, error, process));
			process.addEventListener(Event.STANDARD_OUTPUT_CLOSE, onCmdExit.bind(_, output, error, process, onComplete));
		}
		process.start(nativeProcessStartupInfo);
	}
	
	static function onCmdOutput(e:ProgressEvent, output:Array<String>, process:NativeProcess, ?cmd:String):Void 
	{
		if (process.standardOutput.bytesAvailable == 0) return;
		var res = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
		if(res != "")output.push(res);
	}
	
	static function onCmdError(e:ProgressEvent, error:Array<String>, process:NativeProcess):Void 
	{
		if (process.standardOutput.bytesAvailable == 0) return;
		var err = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
		if(err != "")error.push(err);
	}
	
	static function onCmdExit(e:Event, output:Array<String>, error:Array<String>, process:NativeProcess, onComplete:String -> Void):Void 
	{
		var allOutput:String = output.join("");
		var allError:String = error.join("");
		onComplete(allOutput);
	}
	
	
	public static function runProgram(prog:String, ?args:Array<String>, ?onComplete:String -> Void) 
	{
		if (prog.indexOf("/") ==-1 && prog.indexOf("\\") ==-1){
			prog = File.applicationDirectory.nativePath + "/" + prog;
		}
		var exe = new File(prog);
		if (!exe.exists) {
			throw "This program could not be found";
		}
		
		var nativeProcessStartupInfo = new NativeProcessStartupInfo();
		nativeProcessStartupInfo.executable = exe;
		nativeProcessStartupInfo.arguments = Vector.ofArray(args);
		
		var process = new NativeProcess(); 
		var output:Array<String> = [];
		var error:Array<String> = [];
		if(onComplete!=null){
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onCmdOutput.bind(_, output, process));
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onCmdError.bind(_, error, process));
			process.addEventListener(Event.STANDARD_OUTPUT_CLOSE, onCmdExit.bind(_, output, error, process, onComplete));
		}
		process.start(nativeProcessStartupInfo);
	}
	
	/*static function onProgOutput(e:ProgressEvent, output:Array<String>, process:NativeProcess):Void 
	{
		output.push(process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable));
	}
	
	static private function onProgError(e:ProgressEvent, error:Array<String>, process:NativeProcess):Void 
	{
		error.push(process.standardError.readUTFBytes(process.standardError.bytesAvailable));
	}
	
	static function onProgExit(e:Event, output:Array<String>, error:Array<String>, process:NativeProcess, onComplete:String -> Void):Void 
	{
		var allOutput:String = output.join("");
		var allError:String = error.join("");
		if(onComplete!=null)onComplete(allOutput);
	}*/
}