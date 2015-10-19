#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Cocoa/Cocoa.h>
#include "QLMeridiana-Swift.h"

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSData *data = [NSData dataWithContentsOfURL:(__bridge NSURL *)url];
    NSMutableDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    MeridianaModel *theModel = [[MeridianaModel alloc] init];
    [theModel fromDictionary:dict];
    Meridiana *meridiana = [[Meridiana alloc] init];
    meridiana.theModel = theModel;
    meridiana.ridotto = true;
    [meridiana calcola];
    
    NSRect rect = CGRectIntegral([meridiana getStrictBoundingBox]);
    rect.origin = CGPointZero;
    
    float scale = fmin(maxSize.height*0.90 /rect.size.height, maxSize.width*0.90 / rect.size.width);
    NSSize scaleSize = NSMakeSize(scale, scale);
    CGSize thumbSize = NSSizeToCGSize((CGSize) { maxSize.width, maxSize.height});
    CGContextRef ctxt = QLThumbnailRequestCreateContext(thumbnail, maxSize, false, NULL);
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctxt flipped:NO]];
    //CGContextClearRect(ctxt, rect)
    CGContextSetRGBFillColor(ctxt, 1, 1, 1, 1);
    CGContextFillRect(ctxt, rect);
    CGContextSetInterpolationQuality(ctxt, kCGInterpolationHigh);
    CGContextTranslateCTM(ctxt, -(rect.size.width * scale - maxSize.width) / 2,
                          -(rect.size.height * scale - maxSize.height) / 2);
    CGContextScaleCTM(ctxt,scale,scale);
    //CGContextTranslateCTM(ctxt,40,40);
    [meridiana drawRect:rect];
    QLThumbnailRequestFlushContext(thumbnail, ctxt);
    CGContextRelease(ctxt);

    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
