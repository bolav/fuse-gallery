using Uno;
using Uno.Collections;
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;

public class Gallery : NativeModule {
	public Gallery () {
		// Add Load function to load image as a texture
		AddMember(new NativePromise<Fuse.Camera.PictureResult, Fuse.Scripting.Object>("getPicture", GetPicture, Converter));
	}

	static Future<Fuse.Camera.PictureResult> GetPicture(object[] args)
	{
		var path = Uno.IO.Path.Combine(Uno.IO.Directory.GetUserDirectory(Uno.IO.UserDirectory.Data), "temp.jpg");
		return GalleryImpl.GetPicture(path);
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
public class GalleryImpl
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

	static extern(!Mobile) void GetPictureImpl () {
		throw new Fuse.Scripting.Error("Unsupported platform");
	}

	[Foreign(Language.Java)]
	static extern(Android) void GetPictureImpl ()
	@{
		// http://stackoverflow.com/questions/5309190/android-pick-images-from-gallery
		android.content.Intent intent = new android.content.Intent(android.content.Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		startActivityForResult(intent, 101);
		// startActivityForResult(intent, TFRequestCodes.GALLERY);
		/*
		Intent intent = new Intent();
		intent.setType("image/*");
		intent.setAction(Intent.ACTION_GET_CONTENT);
		startActivityForResult(Intent.createChooser(intent, "Select Picture"), PICK_IMAGE);
		*/
	@}

	[Require("Entity","GalleryImpl.Cancelled()")]
	[Require("Entity","GalleryImpl.Picked()")]
	[Foreign(Language.ObjC)]
	static extern(iOS) void GetPictureImpl ()
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
