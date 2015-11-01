//
//  FilepointView2.swift
//  GeoFile
//
//  Created by knut on 08/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class FilepointView2:DrawingBase
{
    var imagefile:Imagefile?
    
    
    init(imagefile:Imagefile)
    {
        self.imagefile = imagefile
        let image = UIImage(data: imagefile.file)

        
        super.init(frame: CGRectMake(0, 0, image!.size.width, image!.size.height))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func drawRect(rect: CGRect)
    {
        
        let context = UIGraphicsGetCurrentContext()
        //CGContextDrawImage(context, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height), originalImage.CGImage)
        //originalImage.drawInRect(CGRectMake(0, 0, originalImage.size.width, originalImage.size.height))
        var image = UIImage(data: imagefile!.file)
        if imagefile!.locked == true
        {
            image = convertImageToGrayScale(image!)
        }
        image?.drawInRect(self.bounds)
        CGContextSetLineCap(context, CGLineCap.Round)
        if let imagefileitem = imagefile
        {

            
            for item in imagefileitem.measures
            {
                let measure = item as! Drawingmeasure
                drawMeasurement(context!,measurement: measure)
            }
            
            for item in imagefileitem.angles
            {
                let angle = item as! Drawingangle
                drawAngle(context!,angle: angle)
            }
            
            for item in imagefileitem.lines
            {
                let line = item as! Drawingline
                setStrokeColor(context!,color: drawColorEnum(rawValue: Int(line.color))! )
                CGContextSetLineWidth(context, drawingLineWidth);
                CGContextMoveToPoint(context, CGFloat(line.startX), CGFloat(line.startY))
                CGContextAddLineToPoint(context, CGFloat(line.endX), CGFloat(line.endY))
                
                CGContextStrokePath(context)
            }
            
            for item in imagefileitem.texts
            {
                let text = item as! Drawingtext
                drawText(context!,text: text)
            }
        }
    }
    
    func drawText(context:CGContext,text:Drawingtext)
    {
        /*
        var label = UILabel(frame: CGRectMake(0,0,100,40))
        label.font = UIFont.systemFontOfSize(drawingTextPointSize)
        label.text = text.text
        label.textAlignment = NSTextAlignment.Center
        label.textColor = getUIColor( drawColorEnum(rawValue: Int(text.color))!)
        self.addSubview(label)
        label.center = text.center
        */
        

        let angle = angleOfPointsToFixedPoint(text.start, p2: text.end)

        let label = UILabel(frame: CGRectMake(0,0,100,40))
        label.font = UIFont.systemFontOfSize(drawingTextPointSize)
        label.textAlignment = NSTextAlignment.Center
        label.text = text.text
        label.textColor = getUIColor( drawColorEnum(rawValue: Int(text.color))!)
        label.center = getPointBetweenPoints(CGPointMake(CGFloat(text.startX),CGFloat(text.startY)), p2: CGPointMake(CGFloat(text.endX),CGFloat(text.endY)), offset: CGPointMake(10, -10))
        self.addSubview(label)
        label.transform = CGAffineTransformIdentity
        label.transform = CGAffineTransformMakeRotation(angle * CGFloat(M_PI) / 180.0)
    }
    
    func drawAngle(context:CGContext,angle:Drawingangle)
    {
        
        CGContextBeginPath(context)
        setStrokeColor(context,color: drawColorEnum(rawValue: Int(angle.color))!)
        CGContextSetLineWidth(context, drawingLineWidth)
        CGContextSetLineCap(context, CGLineCap.Round)
        
        CGContextMoveToPoint(context, angle.start.x, angle.start.y)
        CGContextAddLineToPoint(context, angle.mid.x, angle.mid.y)
        CGContextStrokePath(context)
        

        CGContextMoveToPoint(context, angle.mid.x, angle.mid.y)
        CGContextAddLineToPoint(context, angle.end.x, angle.end.y)
        CGContextStrokePath(context)
        
        
        let startAngle = (pointPairToBearingDegrees(angle.start,endingPoint: angle.mid) + 180.0) % 360.0
        let endAngle = pointPairToBearingDegrees(angle.mid,endingPoint: angle.end)
        
        
        let degToRadEnd = ((CGFloat(M_PI) * endAngle ) / 180.0)
        let degToRadStart = ((CGFloat(M_PI) * startAngle ) / 180.0)
        
        
        
        let clockwiseDraw = IsClockwise([angle.start,angle.mid,angle.end])
        
        let radiusForDrawingArc:CGFloat = drawingArcRadius
        
        let arcToDraw = UIBezierPath(arcCenter: angle.mid, radius: radiusForDrawingArc, startAngle: CGFloat(degToRadStart), endAngle: CGFloat(degToRadEnd), clockwise: clockwiseDraw)
        arcToDraw.stroke()
        
        
        let arcForPositionLabel = UIBezierPath(arcCenter: angle.mid, radius: radiusForDrawingArc * 1.5, startAngle: CGFloat(degToRadStart), endAngle: CGFloat(degToRadEnd), clockwise: clockwiseDraw)
        
        
        var _angle = angleOfPointsToFixedPoint(angle.start, p2: angle.end, fixed:angle.mid)
        
        if(_angle > 180.0)
        {
            _angle = (_angle - 360.0) * -1
        }
        //println("angle \(_angle)")
        
        
        let midPointPathFrame = CGPathGetPathBoundingBox(arcForPositionLabel.CGPath);
        let approximateMidPointCenter = CGPointMake(CGRectGetMidX(midPointPathFrame), CGRectGetMidY(midPointPathFrame));
            

        let label = UILabel(frame: CGRectMake(0,0,100,40))
        label.font = UIFont.systemFontOfSize(drawingTextPointSize)
        label.text = angle.text
        label.textAlignment = NSTextAlignment.Center
        label.textColor = getUIColor( drawColorEnum(rawValue: Int(angle.color))!)
        self.addSubview(label)

            label.center = approximateMidPointCenter

    }
    
    func drawMeasurement(context:CGContext,measurement:Drawingmeasure)
    {
        
        //var angleTest = (pointPairToBearingDegrees(measurement.start,endingPoint: measurement.end) + 180.0) % 360.0
        
        CGContextBeginPath(context)
        setStrokeColor(context,color: drawColorEnum(rawValue: Int(measurement.color))!)
        CGContextSetLineWidth(context, drawingLineWidth)
        CGContextSetLineCap(context, CGLineCap.Round)
        
        CGContextMoveToPoint(context, CGFloat(measurement.startX), CGFloat(measurement.startY))
        
        CGContextAddLineToPoint(context, CGFloat(measurement.endX), CGFloat(measurement.endY))
        
        CGContextStrokePath(context)
        let angle = angleOfPointsToFixedPoint(measurement.start, p2: measurement.end)
        
        drawDisclosureLine(context, x: measurement.start.x, y: measurement.start.y, angle:angle)
        
        drawDisclosureLine(context, x: measurement.end.x, y: measurement.end.y, angle:angle)
        /*
        var drawingFromLeftToRight = measurement.startX < measurement.endX
        drawDisclosureIndicator(context, x: CGFloat(measurement.startX), y: CGFloat(measurement.startY), pointRight: drawingFromLeftToRight ? false : true)
        drawDisclosureIndicator(context, x: CGFloat(measurement.endX), y: CGFloat(measurement.endY), pointRight: drawingFromLeftToRight ? true : false)
        */
        let label = UILabel(frame: CGRectMake(0,0,100,40))
        label.font = UIFont.systemFontOfSize(drawingTextPointSize)
        label.textAlignment = NSTextAlignment.Center
        label.text = measurement.text
        label.textColor = getUIColor( drawColorEnum(rawValue: Int(measurement.color))!)
        label.center = getPointBetweenPoints(CGPointMake(CGFloat(measurement.startX),CGFloat(measurement.startY)), p2: CGPointMake(CGFloat(measurement.endX),CGFloat(measurement.endY)), offset: CGPointMake(10, -10))
        self.addSubview(label)
        label.transform = CGAffineTransformIdentity
        label.transform = CGAffineTransformMakeRotation(angle * CGFloat(M_PI) / 180.0)
        
    }
    
    
    
    
    
}