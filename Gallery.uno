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

[ForeignInclude(Language.Java,
                "android.app.Activity",
                "android.content.Intent",
                "android.net.Uri",
                "android.os.Bundle",
                "android.provider.MediaStore",
                "java.io.InputStream",
                "java.io.FileOutputStream",
                "java.io.File")]
[ForeignInclude(Language.ObjC, "TakePictureTask.h")]
public class GalleryImpl
{
	static int BAD_ID = 1234;

	static bool InProgress {
		get; set;
	}

	static Promise<Fuse.Camera.PictureResult> FuturePath {
		get; set;
	}

	static string Path;

	static extern(Android) Java.Object _intentListener;

	public static Future<Fuse.Camera.PictureResult> GetPicture (string path) {
		if (InProgress) {
			return null;
		}
		InProgress = true;
		if defined(Android) {
			 if (_intentListener == null)
				_intentListener = Init();
		}
		Path = path;
		GetPictureImpl();
		FuturePath = new Promise<Fuse.Camera.PictureResult>();
		return FuturePath;
	}

	[Foreign(Language.Java)]
	static extern(Android) Java.Object Init()
	@{
	    com.fuse.Activity.ResultListener l = new com.fuse.Activity.ResultListener() {
	        @Override public boolean onResult(int requestCode, int resultCode, android.content.Intent data) {
	            return @{OnRecieved(int,int,Java.Object):Call(requestCode, resultCode, data)};
	        }
	    };
	    com.fuse.Activity.subscribeToResults(l);
	    return l;
	@}

	[Foreign(Language.Java)]
	static extern(Android) bool OnRecieved(int requestCode, int resultCode, Java.Object data)
	@{
		debug_log("Got resultCode " + resultCode);
		debug_log("(Okay is: " + Activity.RESULT_OK);

	    if (requestCode == @{BAD_ID}) {
	    	if (resultCode == Activity.RESULT_OK) {
	    		Intent i = (Intent)data;

	    		Activity a = com.fuse.Activity.getRootActivity();

	    		// File outFile = new File(@{Path});
	    		// http://stackoverflow.com/questions/10854211/android-store-inputstream-in-file
	    		try {
	    			FileOutputStream output = new FileOutputStream(@{Path:Get()});
	    			InputStream input = a.getContentResolver().openInputStream(i.getData());

	    			byte[] buffer = new byte[4 * 1024]; // or other buffer size
	    			int read;

	    			while ((read = input.read(buffer)) != -1) {
	    			    output.write(buffer, 0, read);
	    			}
	    			output.flush();
	    			output.close();
	    			input.close();
	    		    debug_log("And it's ours!, and done");
	    		    @{Picked():Call()};
	    		} catch (Exception e) {
	    		    e.printStackTrace(); // handle exception, define IOException and others
	    		    @{Cancelled():Call()};

	    		}
	    	}
	    	else {
	    		@{Cancelled():Call()};
	    	}

	    }

	    return (requestCode == @{BAD_ID});
	@}

	static extern(!Mobile) void GetPictureImpl () {
		throw new Fuse.Scripting.Error("Unsupported platform");
	}

	[Foreign(Language.Java)]
	static extern(Android) void GetPictureImpl ()
	@{
		Activity a = com.fuse.Activity.getRootActivity();
		// Intent intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		Intent intent = new Intent();
		intent.setType("image/*");
		intent.setAction(Intent.ACTION_GET_CONTENT);
		a.startActivityForResult(intent, @{BAD_ID});

		// http://stackoverflow.com/questions/5309190/android-pick-images-from-gallery
	@}

	[Require("Entity","GalleryImpl.Cancelled()")]
	[Require("Entity","GalleryImpl.Picked()")]
	[Foreign(Language.ObjC)]
	static extern(iOS) void GetPictureImpl ()
	@{
		TakePictureTask *task = [[TakePictureTask alloc] init];
		UIViewController *uivc = [UIApplication sharedApplication].keyWindow.rootViewController;
		[task setUivc:uivc];
		[task setPath:@{Path}];
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
