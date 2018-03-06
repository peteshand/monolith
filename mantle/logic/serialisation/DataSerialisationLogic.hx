package mantle.logic.serialisation;
import mantle.time.Delay;
import com.imagination.idm.core.model.apps.remote.RemoteAppsModel;
import com.imagination.idm.core.model.base.BaseRemoteAccessModel;
import mantle.logic.serialisation.DataDeserialisedSignal;
import mantle.util.fs.File;
import mantle.util.fs.Files;
import mantle.util.time.EnterFrame;
import mantle.worker.WorkerSwitchboard;
import openfl.utils.ByteArray;
using Logger;

/**
 * ...
 * @author Thomas Byrne
 */
@:rtti
class DataSerialisationLogic
{
	@inject public var dataDeserialised:DataDeserialisedSignal;
	
	var folderPath:String;
	var file:File;
	
	var models:Array<ModelInfo> = [];
	var isPending:Bool = false;
	var pendingSave:Array<ModelInfo> = [];
	var loading:Int = 0;
	
	var worker:WorkerSwitchboard;

	public function new() 
	{
		worker = WorkerSwitchboard.getInstance();
	}
	
	public function setup() 
	{
		folderPath = Files.appDocsDir() + "serialised/";
		file = new File(folderPath);
		if (!file.exists){
			file.createDirectory();
		}
	}
	
	public function addModel(object:SerialisableObject, name:String, ?deserialiseImmediately:Bool) 
	{
		var path = folderPath + name + "/";
		file.nativePath = path;
		if (!file.exists){
			file.createDirectory();
		}
		var modelInfo:ModelInfo = {path:path, writing:false, byteArray:new ByteArray(), object:object, name:name, fileExt:object.serialisedFileExt()};
		models.push(modelInfo);
		
		if (deserialiseImmediately){
			deserialise(modelInfo);
		}
		
		object.onSerialisedChange = onSerialisedChange.bind(modelInfo);
	}
	
	public function deserialiseAll() 
	{
		for (modelInfo in models){
			deserialise(modelInfo);
		}
	}
	
	function deserialise(modelInfo:ModelInfo) 
	{
		file.nativePath = modelInfo.path + "full." + modelInfo.fileExt;
		if (file.exists){
			loading++;
			worker.loadBinary(file.url, onLoadSuccess.bind(_, modelInfo), onLoadFail.bind(_, modelInfo));
		}else{
			modelInfo.object.deserialise(null);
			EnterFrame.delay(checkLoading);
		}
	}
	
	function checkLoading() 
	{
		if (loading > 0) return;
		
		if (dataDeserialised != null) dataDeserialised.dispatch();
	}
	
	function onLoadSuccess(byteArray:ByteArray, modelInfo:ModelInfo) 
	{
		loading--;
		modelInfo.object.deserialise(byteArray);
		checkLoading();
	}
	
	function onLoadFail(err:String, modelInfo:ModelInfo) 
	{
		loading--;
		modelInfo.object.deserialise(null);
		error("Failed to load model data (" + modelInfo.name + "): " + err);
		checkLoading();
	}
	
	function onSerialisedChange(modelInfo:ModelInfo) 
	{
		if (pendingSave.indexOf(modelInfo) != -1) return;
		
		pendingSave.push(modelInfo);
		startPending();
	}
	
	function startPending() 
	{
		if (!isPending){
			isPending = true;
			Delay.byTime(1, doSave);
		}
	}
	
	function doSave() 
	{
		isPending = false;
		var i = 0;
		while (i < pendingSave.length){
			var modelInfo = pendingSave[i];
			if (modelInfo.writing){
				i++;
				continue;
			}
			
			modelInfo.writing = true;
			modelInfo.byteArray.clear();
			modelInfo.byteArray.position = 0;
			modelInfo.object.serialise(modelInfo.byteArray);
			
			file.nativePath = modelInfo.path + "full." + modelInfo.fileExt;
			worker.writeBinaryToFile(file.url, modelInfo.byteArray, onSaveSuccess.bind(_, modelInfo), onSaveFail.bind(_, modelInfo));
			
			pendingSave.splice(i, 1);
		}
	}
	
	function onSaveSuccess(err:String, modelInfo:ModelInfo) 
	{
		modelInfo.writing = false;
		if (pendingSave.length > 0) startPending();
	}
	
	function onSaveFail(err:String, modelInfo:ModelInfo) 
	{
		modelInfo.writing = false;
		error("Failed to save model data (" + modelInfo.name + "): " + err);
		if (pendingSave.length > 0) startPending();
	}
	
}

typedef ModelInfo =
{
	writing:Bool,
	byteArray:ByteArray,
	object:SerialisableObject,
	name:String,
	path:String,
	fileExt:String
}

typedef SerialisableObject =
{
	var onSerialisedChange:Void->Void;
	function serialisedFileExt() : String;
	function deserialise(data:ByteArray) : Void;
	function serialise(fill:ByteArray) : Void;
}