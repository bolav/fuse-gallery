using Uno;
using Uno.Collections;
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;

public class Gallery : NativeModule {
	public Gallery () {
		AddMember(new NativeFunction("load", (NativeCallback)Load));
		AddMember(new NativeFunction("getPictureSync", (NativeCallback)GetPictureSync));
		AddMember(new NativePromise<Fuse.Camera.PictureResult, Fuse.Scripting.Object>("getPicture", GetPicture, Converter));

	}

	// Load a image as a 
	object Load (Context c, object[] args)
	{
		throw new Fuse.Scripting.Error("Not yet implemented");
		if defined(iOS) {

		}
		throw new Fuse.Scripting.Error("Unsupported platform");
	}

	// Copy picture from gallery to app
	object GetPictureSync (Context c, object[] args)
	{
		if defined(iOS) {
			var path = Uno.IO.Path.Combine(Uno.IO.Directory.GetUserDirectory(Uno.IO.UserDirectory.Data), "temp.jpg");
			debug_log path;
			iOSGalleryImpl.GetPicture(path);
			return null;
		}
		throw new Fuse.Scripting.Error("Unsupported platform");
	}

	static Future<Fuse.Camera.PictureResult> GetPicture(object[] args)
	{
		if defined(iOS) {
			var path = Uno.IO.Path.Combine(Uno.IO.Directory.GetUserDirectory(Uno.IO.UserDirectory.Data), "temp.jpg");
			debug_log path;
			return iOSGalleryImpl.GetPicture(path);
		}
		throw new Fuse.Scripting.Error("Unsupported platform");
	}

    static Fuse.Scripting.Object Converter(Context context, Fuse.Camera.PictureResult result)
    {
		var func = (Fuse.Scripting.Function)context.GlobalObject["File"];
		var file = (Fuse.Scripting.Object)func.Construct();
		file["path"] = result.Path;
		file["name"] = Uno.IO.Path.GetFileName(result.Path);
    	return file;
    }


}

[ForeignInclude(Language.ObjC, "TakePictureTask.h")]
[ExportCondition("iOS"), TargetSpecificImplementation]
public class iOSGalleryImpl 
{
	static bool InProgress {
		get; set;
	}

	static Promise<Fuse.Camera.PictureResult> FuturePath {
		get; set;
	}

	public static string Path {
		get; set;
	}

	public static Future<Fuse.Camera.PictureResult> GetPicture (string path) {
		if (InProgress) {
			return null;
		}
		InProgress = true;
		Path = path;
		GetPictureImpl();
		FuturePath = new Promise<Fuse.Camera.PictureResult>();
		return FuturePath;
	}

	[Require("Entity","iOSGalleryImpl.Cancelled()")]
	[Require("Entity","iOSGalleryImpl.Picked()")]
	[Foreign(Language.ObjC)]
	public static extern(iOS) void GetPictureImpl () 
	@{
		TakePictureTask *task = [[TakePictureTask alloc] init];
		UIViewController *uivc = [UIApplication sharedApplication].keyWindow.rootViewController;
		[task setUivc:uivc];
		[task setPath:@{Path:Get()}];
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		picker.delegate = task;
		[uivc 
			presentViewController:picker 
			animated:YES 
			completion:nil];

	@}

	public static void Cancelled () {
		InProgress = false;
		FuturePath.Reject(new Exception("User cancelled the gallery select"));
	}

	public static void Picked () {
		InProgress = false;
		FuturePath.Resolve(new Fuse.Camera.PictureResult(Path, 0));
	}

}
