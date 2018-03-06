package mantle.worker;
import mantle.util.worker.Worker;

/**
 * ...
 * @author Thomas Byrne
 */
class WorkerResponse
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("com.imagination.worker.WorkerResponse", WorkerResponse);
	}
	
	public var type:ResponseType;
	public var jobId:Int;
	public var res:Null<Dynamic>;
	public var err:String;
	public var prog:Float;
	public var total:Float;

	public function new(?type:ResponseType, ?jobId:Int) 
	{
		this.type = type;
		this.jobId = jobId;
	}
	
	public function set(?type:ResponseType, ?jobId:Int, ?res:Null<Dynamic>, ?err:String, ?prog:Float, ?total:Float):WorkerResponse 
	{
		this.type = type;
		this.jobId = jobId;
		this.res = res;
		this.err = err;
		this.prog = prog;
		this.total = total;
		return this;
	}
	
	
}

@:enum
abstract ResponseType(String)
{
	var STARTUP_COMPLETE = "startupComplete";
	var SUCCESS = "success";
	var FAILED = "failed";
	var PROGRESS = "progress";
}