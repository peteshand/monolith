package mantle.services.watch.watcher;
import mantle.util.signals.Signal;
import mantle.util.fs.File;
import mantle.util.signals.Signal.Signal1;

/**
 * @author P.J.Shand
 */
interface IWatcher 
{
	var onFileChanged:Signal1<File>;
	var onFileRemoved:Signal1<File>;
	var onFileAdded:Signal1<File>;
	
	function start():Void;
	function stop():Void;
}