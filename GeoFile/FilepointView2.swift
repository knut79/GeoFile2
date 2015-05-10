//
//  FilepointView2.swift
//  GeoFile
//
//  Created by knut on 08/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class FilepointView2:UIView
{
    var filepoint:Filepoint?
    
    
    init(filepoint:Filepoint)
    {
        self.filepoint = filepoint
        var image = UIImage(data: filepoint.file!)
        super.init(frame: CGRectMake(0, 0, image!.size.width, image!.size.height))
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func drawRect(rect: CGRect)
    {
        
        var context = UIGraphicsGetCurrentContext()
        //CGContextDrawImage(context, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height), originalImage.CGImage)
        //originalImage.drawInRect(CGRectMake(0, 0, originalImage.size.width, originalImage.size.height))
        var image = UIImage(data: filepoint!.file!)
        image?.drawInRect(self.bounds)
        CGContextSetLineCap(context, kCGLineCapRound)
        if let fp = filepoint
        {

            
            for item in fp.measures
            {
                var measure = item as Drawingmeasure
                drawMeasurement(context,measurement: measure)
            }
            
            for item in fp.angles
            {
                var angle = item as Drawingangle
                drawAngle(context,angle: angle)
            }
            
            for item in fp.lines
            {
                var line = item as Drawingline
                setStrokeColor(context,color: drawColorEnum(rawValue: Int(line.color))! )
                CGContextSetLineWidth(context, drawingLineWidth);
                CGContextMoveToPoint(context, CGFloat(line.startX), CGFloat(line.startY))
                CGContextAddLineToPoint(context, CGFloat(line.endX), CGFloat(line.endY))
                
                CGContextStrokePath(context)
            }
            
            for item in fp.texts
            {
                var text = item as Drawingtext
                drawText(text)
            }
        }
    }
    
    func drawText(text:Drawingtext)
    {
        var label = UILabel(frame: CGRectMake(0,0,100,40))
        label.font = UIFont.systemFontOfSize(drawingTextPointSize)
        label.text = text.text
        label.textAlignment = NSTextAlignment.Center
        label.textColor = getUIColor( drawColorEnum(rawValue: Int(text.color))!)
        self.addSubview(label)
        label.center = text.center
    }
    
    func drawAngle(context:CGContext,angle:Drawingangle)
    {
        
        CGContextBeginPath(context)
        setStrokeColor(context,color: drawColorEnum(rawValue: Int(angle.color))!)
        CGContextSetLineWidth(context, drawingLineWidth)
        CGContextSetLineCap(context, kCGLineCapRound)
        
        CGContextMoveToPoint(context, angle.start.x, angle.start.y)
        CGContextAddLineToPoint(context, angle.mid.x, angle.mid.y)
        CGContextStrokePath(context)
        

        CGContextMoveToPoint(context, angle.mid.x, angle.mid.y)
        CGContextAddLineToPoint(context, angle.end.x, angle.end.y)
        CGContextStrokePath(context)
        
        
        var startAngle = (pointPairToBearingDegrees(angle.start,endingPoint: angle.mid) + 180.0) % 360.0
        var endAngle = pointPairToBearingDegrees(angle.mid,endingPoint: angle.end)
        
        
        var degToRadEnd = ((CGFloat(M_PI) * endAngle ) / 180.0)
        var degToRadStart = ((CGFloat(M_PI) * startAngle ) / 180.0)
        
        
        
        var clockwiseDraw = IsClockwise([angle.start,angle.mid,angle.end])
        
        var radiusForDrawingArc:CGFloat = drawingArcRadius
        
        var arcToDraw = UIBezierPath(arcCenter: angle.mid, radius: radiusForDrawingArc, startAngle: CGFloat(degToRadStart), endAngle: CGFloat(degToRadEnd), clockwise: clockwiseDraw)
        arcToDraw.stroke()
        
        
        var arcForPositionLabel = UIBezierPath(arcCenter: angle.mid, radius: radiusForDrawingArc * 1.5, startAngle: CGFloat(degToRadStart), endAngle: CGFloat(degToRadEnd), clockwise: clockwiseDraw)
        
        
        var _angle = angleOfPointsToFixedPoint(angle.start, p2: angle.end, fixed:angle.mid)
        
        if(_angle > 180.0)
        {
            _angle = (_angle - 360.0) * -1
        }
        println("angle \(_angle)")
        
        
        var midPointPathFrame = CGPathGetPathBoundingBox(arcForPositionLabel.CGPath);
        var approximateMidPointCenter = CGPointMake(CGRectGetMidX(midPointPathFrame), CGRectGetMidY(midPointPathFrame));
            

        var label = UILabel(frame: CGRectMake(0,0,100,40))
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
        CGContextSetLineCap(context, kCGLineCapRound)
        
        CGContextMoveToPoint(context, CGFloat(measurement.startX), CGFloat(measurement.startY))
        
        CGContextAddLineToPoint(context, CGFloat(measurement.endX), CGFloat(measurement.endY))
        
        CGContextStrokePath(context)
        var angle = angleOfPointsToFixedPoint(measurement.start, p2: measurement.end)
        
        drawDisclosureLine(context, x: measurement.start.x, y: measurement.start.y, angle:angle)
        
        drawDisclosureLine(context, x: measurement.end.x, y: measurement.end.y, angle:angle)
        /*
        var drawingFromLeftToRight = measurement.startX < measurement.endX
        drawDisclosureIndicator(context, x: CGFloat(measurement.startX), y: CGFloat(measurement.startY), pointRight: drawingFromLeftToRight ? false : true)
        drawDisclosureIndicator(context, x: CGFloat(measurement.endX), y: CGFloat(measurement.endY), pointRight: drawingFromLeftToRight ? true : false)
        */
        var label = UILabel(frame: CGRectMake(0,0,100,40))
        label.font = UIFont.systemFontOfSize(drawingTextPointSize)
        label.text = measurement.text
        label.textColor = getUIColor( drawColorEnum(rawValue: Int(measurement.color))!)
        label.center = getPointBetweenPoints(CGPointMake(CGFloat(measurement.startX),CGFloat(measurement.startY)), p2: CGPointMake(CGFloat(measurement.endX),CGFloat(measurement.endY)), offset: CGPointMake(10, -10))
        self.addSubview(label)
        label.transform = CGAffineTransformIdentity
        label.transform = CGAffineTransformMakeRotation(angle * CGFloat(M_PI) / 180.0)
        
    }
    
    func drawDisclosureLine(ctxt:CGContextRef, x:CGFloat, y:CGFloat , angle:CGFloat)
    {
        let R:CGFloat = 4.5 // "radius" of the arrow head
        
        CGContextSaveGState(ctxt)
        
        var newPoint = CGPointMake(x, y)
        let pi:CGFloat =  CGFloat(M_PI)
        var distance:CGFloat = 15
        var angleInRadians:CGFloat = pi / CGFloat(180.0) * ((360 - angle) % 360)
        var point1 = CGPointMake(newPoint.x + CGFloat(distance) * CGFloat(sinf(Float(angleInRadians))), newPoint.y + CGFloat(distance) * CGFloat(cosf(Float(angleInRadians))));
        angleInRadians = pi / CGFloat(180.0) * ((180 - angle) % 360)
        var point2 = CGPointMake(newPoint.x + CGFloat(distance) * CGFloat(sinf(Float(angleInRadians))), newPoint.y + CGFloat(distance) * CGFloat(cosf(Float(angleInRadians))));

        CGContextMoveToPoint(ctxt, point1.x, point1.y)
        CGContextAddLineToPoint(ctxt, x, y)
        CGContextAddLineToPoint(ctxt, point2.x, point2.y)
        
        
        CGContextSetLineCap(ctxt, kCGLineCapSquare)
        CGContextSetLineJoin(ctxt, kCGLineJoinMiter)
        CGContextSetLineWidth(ctxt, 4)
        
        CGContextStrokePath(ctxt)
        CGContextRestoreGState(ctxt)
    }
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func setStrokeColor(context: CGContext,color:drawColorEnum)
    {
        switch(color)
        {
        case .black:
            CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
        case .white:
            CGContextSetRGBStrokeColor(context, 1, 1, 1, 1)
        case .red:
            CGContextSetRGBStrokeColor(context, 1, 0, 0, 1)
        case .blue:
            CGContextSetRGBStrokeColor(context, 0, 0, 1, 1)
        default:
            CGContextSetRGBStrokeColor(context, 1, 1, 1, 1)
        }
    }
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func IsClockwise(vertices:[CGPoint]) -> Bool
    {
        
        var area:CGFloat = 0
        for (var i = 0; i < (vertices.count); i++)
        {
            var j = (i + 1) % vertices.count;
            area += vertices[i].x * vertices[j].y;
            area -= vertices[j].x * vertices[i].y;
            
        }
        return (area < 0);
    }
    

    
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func drawDisclosureIndicator(ctxt:CGContextRef, x:CGFloat, y:CGFloat , pointRight:Bool = true)
    {
        let R:CGFloat = 4.5 // "radius" of the arrow head

        CGContextSaveGState(ctxt)
        
        //
        
        if(pointRight)
        {
            CGContextMoveToPoint(ctxt, x-R, y-R)
            CGContextAddLineToPoint(ctxt, x, y)
            CGContextAddLineToPoint(ctxt, x-R, y+R)
            
        }
        else
        {
            CGContextMoveToPoint(ctxt, x+R, y-R)
            CGContextAddLineToPoint(ctxt, x, y)
            CGContextAddLineToPoint(ctxt, x+R, y+R)
        }
        CGContextSetLineCap(ctxt, kCGLineCapSquare)
        CGContextSetLineJoin(ctxt, kCGLineJoinMiter)
        CGContextSetLineWidth(ctxt, 4)
        
        //CGContextRotateCTM(ctxt,45.0)
        
        CGContextStrokePath(ctxt)
        
        
        
        CGContextRestoreGState(ctxt)
    }
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func getFixedPoint(p1:CGPoint, p2:CGPoint) -> (point:CGPoint,shouldTurn180:Bool)
    {
        
        if(p1.x < p2.x && p1.y > p2.y)
        {
            //upright
            return (CGPointMake(min(p1.x,p2.x), max(p1.y,p2.y)),false)
        }
        else if(p1.x > p2.x && p1.y < p2.y)
        {
            //downleft
            return (CGPointMake(max(p1.x,p2.x), min(p1.y,p2.y)),true)
        }
        else if(p1.x > p2.x && p1.y > p2.y)
        {
            //upleft
            return (CGPointMake(max(p1.x,p2.x), max(p1.y,p2.y)),true)
        }
        else //if(p1.x > p2.x && p1.y > p2.y)
        {
            return (CGPointMake(min(p1.x,p2.x), min(p1.y,p2.y)),false)
        }
    }
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func angleOfPointsToFixedPoint(p1:CGPoint, p2:CGPoint,  fixed:CGPoint? = nil) -> CGFloat
    {
        var fixedPoint = getFixedPoint(p1,p2: p2)
        if( fixed != nil)
        {
            fixedPoint = (fixed!,shouldTurn180:false)
        }
        
        
        let v1 = CGVector(dx: p1.x - fixedPoint.point.x, dy: p1.y - fixedPoint.point.y)
        let v2 = CGVector(dx: p2.x - fixedPoint.point.x, dy: p2.y - fixedPoint.point.y)
        
        let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
        
        var deg = angle * CGFloat(180.0 / M_PI)
        
        if deg < 0 { deg += 360.0 }
        
        
        return (deg + (fixedPoint.shouldTurn180 ? 180.0:0.0))
    }
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func getPointBetweenPoints(p1:CGPoint, p2:CGPoint, offset: CGPoint) -> CGPoint
    {
        
        var point1 = CGPointMake(p1.x + offset.x, p1.y + offset.y)
        var point2 = CGPointMake(p2.x + offset.x, p2.y + offset.y)
        
        //upright or
        if((p1.x < p2.x && p1.y > p2.y) || (p1.x > p2.x && p1.y < p2.y))
        {
            point1 = CGPointMake(p1.x - offset.x, p1.y + offset.y)
            point2 = CGPointMake(p2.x - offset.x, p2.y + offset.y)
        }
        
        var xVal = (point1.x + point2.x ) / 2
        var yVal = (point1.y + point2.y) / 2
        
        return CGPointMake(xVal, yVal)
        
    }
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func pointPairToBearingDegrees(startingPoint:CGPoint, endingPoint:CGPoint) -> CGFloat
    {
        var originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
        var bearingRadians = atan2f(Float(originPoint.y), Float(originPoint.x)); // get bearing in radians
        var bearingDegrees = bearingRadians * (180.0 / Float(M_PI)); // convert to degrees
        bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
        return CGFloat(bearingDegrees);
    }
    
    
}