//
//  StaticFunctions.swift
//  GeoFile
//
//  Created by knut on 29/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

func findMapPointOfFilepoint(filepoint:Filepoint) -> MapPoint
{
    if(filepoint.imagefile!.mappoint != nil)
    {
        return filepoint.imagefile!.mappoint!
    }
    else
    {
        //if no mappoint in former imagefiles/filepoint, traverse down in tree
        return findMapPointOfFilepoint(filepoint.imagefile!.filepoint!)
    }
    
}

func getFilesFromInbox() -> [UIImage]
{
    var pdfImages:[UIImage] = []
    let filemgr = NSFileManager()
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)
    if paths.count > 0
    {
        let documentsDirectory: String = paths[0] 
        //print(" documentsdirectory \(documentsDirectory)")
        let inboxPath = documentsDirectory.stringByAppendingString("/Inbox")
        //print(" inboxPath \(inboxPath)")
        
        var error:NSError?
        var dirFiles: [AnyObject]?
        do {
            dirFiles = try filemgr.contentsOfDirectoryAtPath(inboxPath)
        } catch let error1 as NSError {
            error = error1
            dirFiles = nil
        }
        if(dirFiles != nil &&  dirFiles?.count > 0)
        {
            //let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("fanfare2", ofType: "wav")!)
            //let url = NSURL(fileURLWithPath: inboxPath.stringByAppendingPathComponent(dirFiles![0] as! String))
            let url = NSURL(fileURLWithPath: inboxPath).URLByAppendingPathComponent(dirFiles![0] as! String)
            //var request = NSURLRequest(URL: url)
            //pdfWebView.scalesPageToFit = true
            //pdfWebView.loadRequest(request)
            pdfImages = pdfToImages(url)
            
            for item in dirFiles!
            {
                //let path = inboxPath.stringByAppendingPathComponent(item as! String)
                let path = NSURL(fileURLWithPath: inboxPath).URLByAppendingPathComponent(item as! String)
                do {
                    try filemgr.removeItemAtPath(path.path!)
                } catch let error1 as NSError {
                    print(error1)
                }
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
            print(" error \(error?.description) ", terminator: "")
        }
    }
    return pdfImages
}

func pdfToImages(url:NSURL) -> [UIImage]
{
    //var imageSize = CGSizeMake(280, 320)
    let imageSize = CGSizeMake(612, 792)
    //var imageSize = CGSizeMake(600, 1024)
    
    let pdf = CGPDFDocumentCreateWithURL(url);
    
    let numberOfPages = CGPDFDocumentGetNumberOfPages(pdf)
    
    var pdfImages:[UIImage] = []
    
    for var currentPage = 1 ; currentPage <= Int(numberOfPages) ; currentPage++
    {
        let page = CGPDFDocumentGetPage(pdf, currentPage)
        
        //test
        let pageRect = CGPDFPageGetBoxRect(page,CGPDFBox.TrimBox)
        var pageSize = pageRect.size
        pageSize = MEDSizeScaleAspectFit(pageSize, maxSize: imageSize)
        //end test
        
        UIGraphicsBeginImageContextWithOptions(pageSize, false, 0.0)
        //UIGraphicsBeginImageContext(imageSize);
        
        let context = UIGraphicsGetCurrentContext();
        
        //test
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        CGContextSetRenderingIntent(context, CGColorRenderingIntent.RenderingIntentDefault)
        //end test
        
        //var pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), path, nil, nil);
        
        //CGContextTranslateCTM(context, 0.0, imageSize.height);
        CGContextTranslateCTM(context, 0.0, pageSize.height);
        
        CGContextScaleCTM(context, 1.0, -1.0);
        
        
        CGContextSaveGState(context);
        
        //var pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, CGRectMake(0, 0, pageSize.width, pageSize.height), 0, true);
        let pdfTransform = CGPDFPageGetDrawingTransform(page, CGPDFBox.TrimBox, CGRectMake(0, 0, pageSize.width, pageSize.height), 0, true);
        
        CGContextConcatCTM(context, pdfTransform);
        
        //setting the white background:
        
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
        CGContextFillRect(context, CGRectMake(0, 0, pageSize.width, pageSize.height));
        
        CGContextDrawPDFPage(context, page);
        
        
        CGContextRestoreGState(context);
        
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        pdfImages.append(resultingImage)
    }
    
    return pdfImages
    
}

func MEDSizeScaleAspectFit(size:CGSize, maxSize:CGSize) -> CGSize
{
    let originalAspectRatio = size.width / size.height;
    let maxAspectRatio = maxSize.width / maxSize.height;
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
    let imageSize = CGSizeMake(280, 320)
    UIGraphicsBeginImageContext(imageSize);
    
    let context = UIGraphicsGetCurrentContext();
    
    //var pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), path, nil, nil);
    
    let pdf = CGPDFDocumentCreateWithURL(url);
    
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
    let numberOfPages = CGPDFDocumentGetNumberOfPages(pdf)
    let page = CGPDFDocumentGetPage(pdf, numberOfPages)
    
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
    
    let pdfTransform = CGPDFPageGetDrawingTransform(page, CGPDFBox.CropBox, CGRectMake(0, 0, imageSize.width, imageSize.height), 0, true);
    
    CGContextConcatCTM(context, pdfTransform);
    
    //setting the white background:
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    
    CGContextDrawPDFPage(context, page);
    
    
    CGContextRestoreGState(context);
    
    let resultingImage = UIGraphicsGetImageFromCurrentImageContext();
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

func convertImageToGrayScale(image:UIImage) -> UIImage
{
    // Create image rectangle with current image width/height
    let imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    let colorSpace = CGColorSpaceCreateDeviceGray()
    
    //let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.None.rawValue)
    // Create bitmap content with current image size and grayscale colorspace
    
    
    //let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
    let context = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), 8, 0, colorSpace, CGBitmapInfo().rawValue)
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, image.CGImage);
    
    // Create bitmap image info from pixel data in current context
    let imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    let newImage = UIImage(CGImage: imageRef!)
    

    
    // Return the new grayscale image
    return newImage
}
