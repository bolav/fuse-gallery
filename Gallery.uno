using Uno;
using Uno.Collections;
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse;
using Uno.Compiler.ExportTargetInterop;

public class Gallery : NativeModule {
	public Gallery () {
		AddMember(new NativeFunction("load", (NativeCallback)Load));
		AddMember(new NativeFunction("getPictureSync", (NativeCallback)GetPictureSync));
		//AddMember(new NativePromise<Fuse.Camera.PictureResult, Scripting.Object>("getPicture", GetPicture, Converter));

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

	/*
	object GetPicture (Context c, object[] args)
	{
		if defined(iOS) {

		}
		throw new Fuse.Scripting.Error("Unsupported platform");
	}
	*/

}

[ForeignInclude(Language.ObjC, "TakePictureTask.h")]
[ExportCondition("iOS"), TargetSpecificImplementation]
public class iOSGalleryImpl 
{
	static bool InProgress {
		get; set;
	}

	static iOSGalleryImpl () {
		Cancelled();
	}

	[Foreign(Language.ObjC)]
	public static extern(iOS) void GetPicture (string path) 
	@{
		if (@{InProgress:Get()}) {
			return;
		}
		@{InProgress:Set(true)};
		TakePictureTask *task = [[TakePictureTask alloc] init];
		UIViewController *uivc = [UIApplication sharedApplication].keyWindow.rootViewController;
		[task setUivc:uivc];
		[task setPath:path];
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
	}

	/*
	public static ObjC.ID CreateTask () {
		// return new TakePictureTask();
		return null;
	}*/

}
