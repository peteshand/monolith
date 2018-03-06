package mantle.worker;

/**
 * @author Thomas Byrne
 */

interface IWorkerTask<DataType>
{
	function setup(onSuccess:Null<Dynamic>->Void, onError:String->Void, onProgress:Float->Float->Void, isInWorker:Bool):Void;
	function doJob(data:DataType):Void;
}