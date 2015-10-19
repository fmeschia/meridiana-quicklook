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
    
    CGRect rect = CGRectIntegral(CGRectInset([meridiana getStrictBoundingBox],-20,-20));
    //CGRect rect = CGRectMake(-150,-150,300,300);
    //rect.origin = CGPointZero;
    CFDictionaryRef attrs =
    (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithFloat:rect.size.height],
                               (NSString *)kQLPreviewPropertyHeightKey,
                               [NSNumber numberWithFloat:rect.size.width],
                               (NSString *)kQLPreviewPropertyWidthKey, nil];
    CGContextRef ctxt = QLPreviewRequestCreateContext(preview, rect.size, false, attrs);
    CGContextSaveGState(ctxt);
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctxt flipped:NO]];
    //CGContextClearRect(ctxt, rect);
    CGContextSetInterpolationQuality(ctxt, kCGInterpolationHigh);
    CGContextTranslateCTM(ctxt, 10, 10);
    //CGContextClearRect(ctxt, [meridiana getStrictBoundingBox]);
    [meridiana drawRect: rect];
    CGContextRestoreGState(ctxt);
    CGContextFlush(ctxt);
    QLPreviewRequestFlushContext(preview, ctxt);
    CGContextRelease(ctxt);
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
