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
			var task = iOSGalleryImpl.CreateTask();
			iOSGalleryImpl.GetPicture(task);
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

[ExportCondition("iOS"), TargetSpecificImplementation]
public class iOSGalleryImpl 
{
	[Foreign(Language.ObjC)]
	public static extern(iOS) void GetPicture (TakePictureTask task) 
	@{
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		picker.delegate = task;
		[[UIApplication sharedApplication].keyWindow.rootViewController 
			presentViewController:picker 
			animated:YES 
			completion:nil];

		/* imagePicker.MediaTypes
		    = UIImagePickerController._availableMediaTypesForSourceType(
		        imagePicker.SourceType);
		imagePicker.Delegate = this;

		UIApplication._sharedApplication().KeyWindow.RootViewController
		    .presentModalViewControllerAnimated(imagePicker, true);
		*/
	@}

	public static TakePictureTask CreateTask () {
		return new TakePictureTask();
	}

	        class TakePictureTask : iOS.UIKit.IUIImagePickerControllerDelegate
	        {
	            // public readonly Uno.Threading.Promise<Fuse.Camera.PictureResult> _futurePath;
	            public readonly string Path;

				private int _rotation;

				/*
	            public TakePictureTask(Uno.Threading.Promise<Fuse.Camera.PictureResult> futurePath)
	            {
	                _futurePath = futurePath;
	                Path = Uno.IO.Path.Combine(Directory.GetUserDirectory(UserDirectory.Data), "temp.jpg");
	            }
				*/
	            public void imagePickerControllerDidFinishPickingMediaWithInfo(
	                iOS.UIKit.UIImagePickerController imagePicker, iOS.Foundation.NSDictionary info)
	            @{
	            	NSLog(@"imagePickerControllerDidFinishPickingMediaWithInfo");
	            @}

	            public void imagePickerControllerDidCancel(iOS.UIKit.UIImagePickerController imagePicker)
	            @{
	            	NSLog(@"imagePickerControllerDidCancel");
	            @}

	            public void FireCallback(bool cancelled)
	            {
	                if (cancelled) {
	                    //_futurePath.Reject(new Exception("User cancelled the image capture"));
		            } else {
	                    //_futurePath.Resolve(new Fuse.Camera.PictureResult(Path, _rotation));
	                }
	            }
	        }


}
