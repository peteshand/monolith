package robotlegs.extensions.impl.services.assets;
import mantle.util.cmd.Cmd;
import mantle.util.fs.File;
import mantle.util.fs.Files;

/**
 * ...
 * @author Thomas Byrne
 */
class S3ResourceSyncService
{

	public function new() 
	{
		
	}
	
	public function syncRemoteToLocal(localPath:String, bucket:String, onComplete:Void -> Void, key:String, secret:String) 
	{
		var localFile = new File(localPath);
		if (!localFile.exists){
			localFile.createDirectory();
		}
		
		var s3 = Files.applicationDir() + "tools\\s3.exe";
		
		var args = [];
		args.push("get");
		args.push(bucket);
		args.push(localPath);
		args.push("/sub");
		args.push("/nogui");
		args.push("/key:" + key);
		args.push("/secret:" + secret);
		
		Cmd.runProgram(s3, args, function(ret:String){
			onComplete();
		});
		
		//s3 get storage.dev.imagsyd.com/test/ C:\Users\tom.byrne\Desktop\s3Test\ /sub /key:XXX /secret:XXX
	}
	
}