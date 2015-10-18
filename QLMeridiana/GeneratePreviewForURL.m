#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Cocoa/Cocoa.h>
#include <QuartzCore/QuartzCore.h>
#include "QLMeridiana-Swift.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    NSData *data = [NSData dataWithContentsOfURL:(__bridge NSURL *)url];
    NSMutableDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    MeridianaModel *theModel = [[MeridianaModel alloc] init];
    [theModel fromDictionary:dict];
    Meridiana *meridiana = [[Meridiana alloc] init];
    meridiana.theModel = theModel;
    meridiana.ridotto = true;
    [meridiana calcola];
    
    NSRect rect = CGRectInset([meridiana getStrictBoundingBox],-20,-20);
    rect.origin = CGPointZero;
    CGContextRef ctxt = QLPreviewRequestCreateContext(preview, rect.size, false, NULL);
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctxt flipped:NO]];
    //CGContextClearRect(ctxt, rect);
    CGContextSetInterpolationQuality(ctxt, kCGInterpolationHigh);
    CGContextTranslateCTM(ctxt, 10, 10);
    [meridiana drawRect:rect];
    QLPreviewRequestFlushContext(preview, ctxt);
    CGContextRelease(ctxt);
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
