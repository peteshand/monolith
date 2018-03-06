package mantle.worker;
import mantle.worker.WorkerProcessor;
import mantle.worker.WorkerResponse;
import mantle.worker.WorkerResponse.ResponseType;
import flash.Lib;
import flash.events.Event;
import flash.system.MessageChannel;
import flash.system.Worker;

/**
 * ...
 * @author Thomas Byrne
 */
class WorkerEntry
{
	static private var _worker:WorkerEntry;
	public static function main() 
	{
		_worker = new WorkerEntry();
		Lib.current.stage.frameRate = 1;
	}
	
	
	var processor:WorkerProcessor;
	
	var mainToWorker:MessageChannel;
	var workerToMain:MessageChannel;
	var sendResp:WorkerResponse;

	public function new() 
	{
		WorkerProcessor.register();
		
		processor = new WorkerProcessor(sendResponse, true);
		sendResp = new WorkerResponse();
		
		// Receive from main
		// Since this is called from the worker thread, Worker.current is the worker thread
		mainToWorker = Worker.current.getSharedProperty("mainToWorker");
		mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
 
		// Send to main
		workerToMain = Worker.current.getSharedProperty("workerToMain");
		
		workerToMain.send(sendResp.set(ResponseType.STARTUP_COMPLETE));
	}
	
	function sendResponse(resp:WorkerResponse) 
	{
		workerToMain.send(resp);
	}
	
	private function onMainToWorker(e:Event):Void 
	{
		processor.process(cast mainToWorker.receive());
	}
	
}