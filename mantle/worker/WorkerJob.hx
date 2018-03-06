package mantle.worker;
import mantle.util.worker.Worker;

/**
 * ...
 * @author Thomas Byrne
 */
class WorkerJob
{
	private static var registered:Bool;
	public static function register():Void {
		if (registered) return;
		registered = true;
		Worker.registerClass("com.imagination.worker.WorkerJob", WorkerJob);
	}
	
	public var id:UInt;
	public var data:Dynamic;
	
	public var onSuccess:SuccessHandler;
	public var onError:ErrorHandler;
	public var onProgress:ProgHandler;

	public function new(?id:UInt, ?data:Dynamic) 
	{
		set(id, data);
	}
	
	public function set(?id:UInt, ?data:Dynamic):WorkerJob 
	{
		this.id = id;
		this.data = data;
		return this;
	}
	
}
typedef SuccessHandler = Null<Dynamic>->Void;
typedef ErrorHandler = String->Void;
typedef ProgHandler = Float->Float->Void;