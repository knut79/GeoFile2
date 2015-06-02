//
//  StaticFunctions.swift
//  GeoFile
//
//  Created by knut on 29/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

func findProjectOfFilepoint(filepoint:Filepoint) -> Project
{
    if(filepoint.imagefile!.project != nil)
    {
        return filepoint.imagefile!.project!
    }
    else
    {
        //if no project in former imagefiles/filepoint, traverse down in tree
        return findProjectOfFilepoint(filepoint.imagefile!.filepoint!)
    }
    
}

func getFilesFromInbox() -> [UIImage]
{
    var pdfImages:[UIImage] = []
    var filemgr = NSFileManager()
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)
    if(paths != nil)
    {
        var documentsDirectory: String = paths[0] as! String
        //print(" documentsdirectory \(documentsDirectory)")
        var inboxPath = documentsDirectory.stringByAppendingString("/Inbox")
        //print(" inboxPath \(inboxPath)")
        
        var error:NSError?
        var dirFiles = filemgr.contentsOfDirectoryAtPath(inboxPath, error: &error)
        if(dirFiles != nil &&  dirFiles?.count > 0)
        {
            var url = NSURL.fileURLWithPath(inboxPath.stringByAppendingPathComponent(dirFiles![0] as! String))
            var request = NSURLRequest(URL: url!)
            //pdfWebView.scalesPageToFit = true
            //pdfWebView.loadRequest(request)
            pdfImages = pdfToImages(url!)
            
            for item in dirFiles!
            {
                var path = inboxPath.stringByAppendingPathComponent(item as! String)
                filemgr.removeItemAtPath(path, error: &error)
                /*
                if(filemgr.isDeletableFileAtPath(path))
                {
                print("file deleted")
                filemgr.removeItemAtPath(path, error: &error)
                }*/
            }
        }
        if(error != nil)
        {
            print(" error \(error?.description) ")
        }
    }
    return pdfImages
}

func pdfToImages(url:NSURL) -> [UIImage]
{
    //var imageSize = CGSizeMake(280, 320)
    var imageSize = CGSizeMake(612, 792)
    //var imageSize = CGSizeMake(600, 1024)
    
    var pdf = CGPDFDocumentCreateWithURL(url);
    
    var numberOfPages = CGPDFDocumentGetNumberOfPages(pdf)
    
    var pdfImages:[UIImage] = []
    
    for var currentPage = 1 ; currentPage <= Int(numberOfPages) ; currentPage++
    {
        var page = CGPDFDocumentGetPage(pdf, currentPage)
        
        //test
        var pageRect = CGPDFPageGetBoxRect(page,kCGPDFTrimBox)
        var pageSize = pageRect.size
        pageSize = MEDSizeScaleAspectFit(pageSize, imageSize)
        //end test
        
        UIGraphicsBeginImageContextWithOptions(pageSize, false, 0.0)
        //UIGraphicsBeginImageContext(imageSize);
        
        var context = UIGraphicsGetCurrentContext();
        
        //test
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        CGContextSetRenderingIntent(context, kCGRenderingIntentDefault)
        //end test
        
        //var pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), path, nil, nil);
        
        //CGContextTranslateCTM(context, 0.0, imageSize.height);
        CGContextTranslateCTM(context, 0.0, pageSize.height);
        
        CGContextScaleCTM(context, 1.0, -1.0);
        
        
        CGContextSaveGState(context);
        
        //var pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, CGRectMake(0, 0, pageSize.width, pageSize.height), 0, true);
        var pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFTrimBox, CGRectMake(0, 0, pageSize.width, pageSize.height), 0, true);
        
        CGContextConcatCTM(context, pdfTransform);
        
        //setting the white background:
        
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
        CGContextFillRect(context, CGRectMake(0, 0, pageSize.width, pageSize.height));
        
        CGContextDrawPDFPage(context, page);
        
        
        CGContextRestoreGState(context);
        
        var resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        pdfImages.append(resultingImage)
    }
    
    return pdfImages
    
}

func MEDSizeScaleAspectFit(size:CGSize, maxSize:CGSize) -> CGSize
{
    var originalAspectRatio = size.width / size.height;
    var maxAspectRatio = maxSize.width / maxSize.height;
    var newSize = maxSize;
    // The largest dimension will be the `maxSize`, and then we need to scale
    // the other dimension down relative to it, while maintaining the aspect
    // ratio.
    if (originalAspectRatio > maxAspectRatio) {
        newSize.height = maxSize.width / originalAspectRatio
    } else {
        newSize.width = maxSize.height * originalAspectRatio
    }
    
    return newSize
}

func pdfToImage(url:NSURL) -> (UIImage)
{
    var imageSize = CGSizeMake(280, 320)
    UIGraphicsBeginImageContext(imageSize);
    
    var context = UIGraphicsGetCurrentContext();
    
    //var pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), path, nil, nil);
    
    var pdf = CGPDFDocumentCreateWithURL(url);
    
    CGContextTranslateCTM(context, 0.0, imageSize.height);
    
    
    /*
    //You should extract the proper metrics form the pdf, with code like this:
    
    cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    rotate = CGPDFPageGetRotationAngle(page);
    
    Also, as you see, the pdf might has rotation info, so you need to use the CGContextTranslateCTM/CGContextRotateCTM/CGContextScaleCTM depending on the angle.
    
    You also might wanna clip any content that is outside of the CropBox area, as pdf has various viewPorts that you usually don't wanna display (e.g. for printers so that seamless printing is possible) -> use CGContextClip.
    
    
    
    -----------------
    
    For more generic rendering code, i always do the rotation like this:
    */
    var numberOfPages = CGPDFDocumentGetNumberOfPages(pdf)
    var page = CGPDFDocumentGetPage(pdf, numberOfPages)
    
    /*
    var rotation = CGPDFPageGetRotationAngle(page);
    
    CGContextTranslateCTM(context, 0, imageSize.height);//moves up Height
    CGContextScaleCTM(context, 1.0, -1.0)//flips horizontally down
    CGContextRotateCTM(context, CGFloat( Double(-rotation) * M_PI / 180))//rotates the pdf
    var placement = CGContextGetClipBoundingBox(context)//get the flip's placement
    CGContextTranslateCTM(context, placement.origin.x, placement.origin.y)//moves the the correct place
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    
    //do all your drawings
    CGContextDrawPDFPage(context, page)
    
    //undo the rotations/scaling/translations
    CGContextTranslateCTM(context, -placement.origin.x, -placement.origin.y);
    CGContextRotateCTM(context,CGFloat( Double(rotation) * M_PI / 180))
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -imageSize.height);
    */
    
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSaveGState(context);
    
    var pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, CGRectMake(0, 0, imageSize.width, imageSize.height), 0, true);
    
    CGContextConcatCTM(context, pdfTransform);
    
    //setting the white background:
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    
    CGContextDrawPDFPage(context, page);
    
    
    CGContextRestoreGState(context);
    
    var resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //UIImageJPEGRepresentation(image, 1)
    
    return resultingImage;
}

func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
    
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
    imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    return scaledImage
}
