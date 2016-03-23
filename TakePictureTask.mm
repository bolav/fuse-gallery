//
//  TakePictureTask.m
//  GalleryLibrary
//
//  Created by Bjørn-Olav Solum Strand on 22/03/16.
//
//

#import "TakePictureTask.h"
@{GalleryImpl:IncludeDirective}

@implementation TakePictureTask

-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// UIImage
	id image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

	[UIImageJPEGRepresentation(image, 1.0) writeToFile:self.path atomically:YES];

	/*
	var origSize = image.Size;

	NSDictionary metadata = DictionaryForKey(info, MEDIA_METADATA);
	NSNumber orientation = NumberForKey(metadata, ORIENTATION);
	int orientationValue = 0;
					if (orientation != null)
						{
							orientationValue = orientation.IntValue;
						}

					var scaledSize = Fuse.Camera.TakePictureHelpers.GetAspectCorrectedSize(
						_options, int2((int)origSize.Width, (int)origSize.Height));


					var scaleWidth = ((float) scaledSize.X) / origSize.Width;
					var scaleHeight = ((float) scaledSize.Y) / origSize.Height;
					var size = global::iOS.CoreGraphics.Functions.CGSizeApplyAffineTransform(image.Size,
						global::iOS.CoreGraphics.Functions.CGAffineTransformMakeScale(scaleWidth, scaleHeight));

					var hasAlpha = false;
					var scale = 1.0f;

					global::iOS.UIKit.Functions.UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
					image.drawInRect(new CGRect(new CGPoint(0f,0f), size));
					var scaledImage = global::iOS.UIKit.Functions.UIGraphicsGetImageFromCurrentImageContext();

					try
					{
						iOSCameraHelper.SaveImageJPG(scaledImage.Handle, Path);
					}
					catch(Exception e)
					{
						debug_log(e.Message);
					}
					global::iOS.UIKit.Functions.UIGraphicsEndImageContext();
	                imagePicker.dismissModalViewControllerAnimated(true);

	                FireCallback(false);
	                _pendingTask = null;
	*/
	@{GalleryImpl.Picked():Call()};
    [self.uivc dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
     @{GalleryImpl.Cancelled():Call()};
     [self.uivc dismissViewControllerAnimated:YES completion:nil];
}

@end
