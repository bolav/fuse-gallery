//
//  TakePictureTask.h
//  GalleryLibrary
//
//  Created by Bjørn-Olav Solum Strand on 22/03/16.
//
//

#import <Foundation/Foundation.h>

@interface TakePictureTask : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) UIViewController *uivc;
@property (nonatomic, copy) NSString *path;

@end
