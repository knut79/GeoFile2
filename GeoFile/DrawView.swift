//
//  DrawView.swift
//  GeoFile
//
//  Created by knut on 11/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

protocol DrawViewProtocol {
    
    func setMeasurementText(label:UILabel)
    func setAngleText(label:UILabel)
    func setDrawntextText(label:UILabel)
    func cancelDraw()
    func saveDraw()
    
}

class DrawView: DrawingBase{
    var delegate:DrawViewProtocol?
    
    var lines:[Line] = []
    var measures:[Measure] = []
    var drawnTexts:[Drawntext] = []
    var currentMeasure:Measure!
    var tempMeasureLabelSize:CGRect!
    var tempMeasureLabel:UILabel!
    var tempTextLabelSize:CGRect!
    var tempTextLabel:UILabel!
    
    var angles:[Angle] = []
    var currentAngle:Angle!
    var tempAngleLabelSize:CGRect!
    var tempAngleLabel:UILabel!
    
    var lastPoint: CGPoint!
    var middlePoint: CGPoint!
    var buttonSize:CGRect!
    var originalImage:UIImage!
    
    var freeButton:CustomButton!
    var measureButton:CustomButton!
    var angleButton:CustomButton!
    var textButton:CustomButton!
    var undoButton:CustomButton!
    var blackButton:CustomButton!
    var whiteButton:CustomButton!
    var redButton:CustomButton!
    var blueButton:CustomButton!
    var chooseColorButton:CustomButton!
    var choosenColorLabel:UILabel!
    var undoArtifactList:[drawTypeEnum] = []
    var saveDrawButton:CustomButton!
    var cancelDrawButton:CustomButton!

    var drawType:drawTypeEnum = .free
    var colorPicked:drawColorEnum = .white
    
    var zoomscale:CGFloat = 1

    //var testLabel:UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame:CGRect)
    {
        super.init(frame: frame)
        
        buttonSize = CGRectMake(0, 0, buttonIconSideSmall, buttonIconSideSmall)
        tempMeasureLabelSize = CGRectMake(0, 0, 100, 25)
        tempAngleLabelSize = CGRectMake(0, 0, 100, 25)
        tempTextLabelSize = CGRectMake(0, 0, 300, 25)
        
        
        
        saveDrawButton = CustomButton(frame: CGRectMake(0, self.bounds.size.height - buttonBarHeight, self.bounds.size.width * 0.5, buttonBarHeight))
        saveDrawButton.setTitle("Save", forState: .Normal)
        saveDrawButton.addTarget(self, action: "saveDraw", forControlEvents: .TouchUpInside)
        //saveDrawButton.hidden = true
        
        cancelDrawButton = CustomButton(frame: CGRectMake(saveDrawButton.frame.width, self.bounds.size.height - buttonBarHeight, self.bounds.size.width * 0.5, buttonBarHeight))
        cancelDrawButton.setTitle("Cancel", forState: .Normal)
        cancelDrawButton.addTarget(self, action: "cancelDraw", forControlEvents: .TouchUpInside)
        //cancelDrawButton.hidden = true
        
        
        freeButton = CustomButton(frame: buttonSize)
        freeButton.setTitle("✒", forState: .Normal)
        freeButton.addTarget(self, action: "freeDraw", forControlEvents: .TouchUpInside)
        
        
        measureButton = CustomButton(frame: buttonSize)
        measureButton.setTitle("📏", forState: .Normal)
        measureButton.addTarget(self, action: "measureDraw", forControlEvents: .TouchUpInside)
        
        angleButton = CustomButton(frame: buttonSize)
        angleButton.setTitle("📐", forState: .Normal)
        angleButton.addTarget(self, action: "angleDraw", forControlEvents: .TouchUpInside)
        
        textButton = CustomButton(frame: buttonSize)
        textButton.setTitle("📝", forState: .Normal)
        textButton.addTarget(self, action: "textDraw", forControlEvents: .TouchUpInside)
        
        undoButton = CustomButton(frame: buttonSize)
        undoButton.setTitle("↩️", forState: .Normal)
        undoButton.addTarget(self, action: "undoDraw", forControlEvents: .TouchUpInside)
        
        
        
        chooseColorButton = CustomButton(frame: buttonSize)
        chooseColorButton.setTitle("🎨", forState: .Normal)
        chooseColorButton.addTarget(self, action: "chooseColor", forControlEvents: .TouchUpInside)

        
        choosenColorLabel = UILabel(frame: buttonSize)
        choosenColorLabel.textAlignment = NSTextAlignment.Center
        
        blackButton = CustomButton(frame: buttonSize)
        blackButton.setTitle("⚫️", forState: .Normal)
        blackButton.addTarget(self, action: "blackColor", forControlEvents: .TouchUpInside)
        blackButton.alpha = 0
        
        whiteButton = CustomButton(frame: buttonSize)
        whiteButton.setTitle("⚪️", forState: .Normal)
        whiteButton.addTarget(self, action: "whiteColor", forControlEvents: .TouchUpInside)
        whiteButton.alpha = 0
        
        redButton = CustomButton(frame: buttonSize)
        redButton.setTitle("🔴", forState: .Normal)
        redButton.addTarget(self, action: "redColor", forControlEvents: .TouchUpInside)
        redButton.alpha = 0
        
        blueButton = CustomButton(frame: buttonSize)
        blueButton.setTitle("🔵", forState: .Normal)
        blueButton.addTarget(self, action: "blueColor", forControlEvents: .TouchUpInside)
        blueButton.alpha = 0
        
        //println("origin \(self.frame.origin.y)")
        
        freeButton.center = CGPointMake(buttonSize.width * 0.75  , saveDrawButton.frame.minY - (buttonSize.height * 0.75))
        measureButton.center = CGPointMake(freeButton.frame.maxX + buttonSize.width, saveDrawButton.frame.minY - (buttonSize.height * 0.75))
        angleButton.center = CGPointMake(measureButton.frame.maxX + buttonSize.width,saveDrawButton.frame.minY - (buttonSize.height * 0.75))
        textButton.center = CGPointMake(angleButton.frame.maxX + buttonSize.width, saveDrawButton.frame.minY - (buttonSize.height * 0.75))
        undoButton.center = CGPointMake(textButton.frame.maxX + buttonSize.width, saveDrawButton.frame.minY - (buttonSize.height * 0.75))
        
        chooseColorButton.center = CGPointMake(buttonSize.width * 0.75 , freeButton.frame.minY - buttonSize.height)
        choosenColorLabel.center = CGPointMake(buttonSize.width * 0.75, chooseColorButton.frame.minY)
        
        blackButton.center = CGPointMake(buttonSize.width * 0.75 , chooseColorButton.frame.minY - buttonSize.height)
        whiteButton.center = CGPointMake(buttonSize.width * 0.75 , blackButton.frame.minY - buttonSize.height)
        redButton.center = CGPointMake(buttonSize.width * 0.75 , whiteButton.frame.minY - buttonSize.height)
        blueButton.center = CGPointMake(buttonSize.width * 0.75 , redButton.frame.minY - buttonSize.height)
        
        self.addSubview(freeButton)
        self.addSubview(measureButton)
        self.addSubview(angleButton)
        self.addSubview(textButton)
        self.addSubview(undoButton)

        self.addSubview(blackButton)
        self.addSubview(whiteButton)
        self.addSubview(redButton)
        self.addSubview(blueButton)
        
        self.addSubview(choosenColorLabel)
        self.addSubview(chooseColorButton)
        
        self.addSubview(cancelDrawButton)
        self.addSubview(saveDrawButton)
        
        drawType = .free
        colorPicked = .white
        choosenColorLabel.text = "⚪️"
        markButtonOnColor()
        markButtonOnDrawtype()
        
        populateNewTempMeasuleLabel()
        populateNewTempAngleLabel()
        populateNewTempTextLabel()
    }
    

    func setZoomscale(zscale:CGFloat)
    {
        self.zoomscale = zscale
    }
    
    func resetDrawingValues()
    {
        lines = []
        measures = []
        tempMeasureLabel.hidden = true
        angles = []
        tempAngleLabel.hidden = true
        undoArtifactList = []
    }
    
    func hideButtons()
    {
        setButtonsHiddenAttr(true)
    }
    
    func showButtons()
    {
        setButtonsHiddenAttr(false)
    }
    
    func setButtonsHiddenAttr(isHidden:Bool)
    {
        freeButton.hidden = isHidden
        measureButton.hidden = isHidden
        angleButton.hidden = isHidden
        textButton.hidden = isHidden
        undoButton.hidden = isHidden
        blackButton.hidden = isHidden
        whiteButton.hidden = isHidden
        redButton.hidden = isHidden
        blueButton.hidden = isHidden
        chooseColorButton.hidden = isHidden
        choosenColorLabel.hidden = isHidden
    }
    
    func populateNewTempMeasuleLabel()
    {
        tempMeasureLabel = UILabel(frame: tempMeasureLabelSize)
        tempMeasureLabel.font = UIFont.systemFontOfSize(drawingTextPointSize * zoomscale)
        tempMeasureLabel.text = "?"
        tempMeasureLabel.textAlignment = NSTextAlignment.Center
        tempMeasureLabel.backgroundColor = UIColor.clearColor()
        tempMeasureLabel.hidden = true
        tempMeasureLabel.userInteractionEnabled = true
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "setMeasurementText:")
        tapRecognizer.numberOfTapsRequired = 1
        tempMeasureLabel.addGestureRecognizer(tapRecognizer)
        self.addSubview(tempMeasureLabel)
    }
    
    func populateNewTempAngleLabel()
    {
        tempAngleLabel = UILabel(frame: tempAngleLabelSize)
        tempAngleLabel.font = UIFont.systemFontOfSize(drawingTextPointSize * zoomscale)
        //println("fontsize \(tempAngleLabel.font.pointSize)")
        tempAngleLabel.text = "?"
        tempAngleLabel.textAlignment = NSTextAlignment.Center
        tempAngleLabel.backgroundColor = UIColor.clearColor()
        tempAngleLabel.hidden = true
        tempAngleLabel.userInteractionEnabled = true
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "setAngleText:")
        tapRecognizer.numberOfTapsRequired = 1
        tempAngleLabel.addGestureRecognizer(tapRecognizer)
        self.addSubview(tempAngleLabel)
    }
    
    
    func populateNewTempTextLabel()
    {
        tempTextLabel = UILabel(frame: tempTextLabelSize)
        tempTextLabel.text = "Enter text"
        //tempTextLabel.layer.borderColor = UIColor.blackColor().CGColor
        //tempTextLabel.layer.borderWidth = 2.0;
        tempTextLabel.textAlignment = NSTextAlignment.Center
        tempTextLabel.backgroundColor = UIColor.clearColor()
        tempTextLabel.hidden = true
        tempTextLabel.userInteractionEnabled = true
        tempTextLabel.font = UIFont.boldSystemFontOfSize(drawingTextPointSize * zoomscale)
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "setDrawntextText:")
        tapRecognizer.numberOfTapsRequired = 1
        tempTextLabel.addGestureRecognizer(tapRecognizer)
        self.addSubview(tempTextLabel)
    }
    
    
    func setImage(image:UIImage)
    {
        originalImage = image
        self.setNeedsDisplay()
    }

    var touchBegan = false
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        lastPoint = touches.anyObject()?.locationInView(self)
        hideColorButtons()
        touchBegan = true
        switch(drawType)
        {
        case .free:
            tempMeasureLabel.hidden = true
            tempAngleLabel.hidden = true
            tempTextLabel.hidden = true
        case .measure:
            tempMeasureLabel.textColor = getUIColor(colorPicked)
            break
        case .angle:
            tempAngleLabel.textColor = getUIColor(colorPicked)
            break
        case .text:
            tempTextLabel.textColor = getUIColor(colorPicked)
            if(drawnTexts.last?.label!.text != tempTextLabel.text)
            {
                tempTextLabel.hidden = false
                tempTextLabel.center = lastPoint
                //currentMeasure.setLabel(label: tempMeasureLabel)
                
                undoArtifactList.append(.text)
                drawnTexts.append(Drawntext(label: tempTextLabel, color: colorPicked))
                populateNewTempTextLabel()
            }
        default:
            break
            
        }
    }
    
    var angleMidpointSat = false
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var newPoint = touches.anyObject()?.locationInView(self)
        switch(drawType)
        {
        case .free:
            lines.append(Line(start: lastPoint, end: newPoint!, color:colorPicked, touchBegan:touchBegan))
            lastPoint = newPoint
        case .measure:
            tempMeasureLabel.hidden = false
            currentMeasure = Measure(start: lastPoint, end: newPoint!, color: colorPicked, text: "?")

            break
        case .angle:
            if(angleMidpointSat)
            {
                tempAngleLabel.hidden = false
                currentAngle = Angle(start: currentAngle.start ,mid: currentAngle.mid, end:newPoint!, color: colorPicked, text: "?" )
            }
            else
            {
                tempAngleLabel.hidden = true
                currentAngle = Angle(start: lastPoint,mid: newPoint!, end:nil, color: colorPicked, text: "?" )
            }
        default:
            break
            
        }
        
        touchBegan = false
        
        
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var newPoint = touches.anyObject()?.locationInView(self)
        switch(drawType)
        {
        case .measure:
            undoArtifactList.append(.measure)
            //measures.append(Measure(start: lastPoint, end: newPoint!, color: colorPicked, text: "?"))
            currentMeasure = Measure(start: lastPoint, end: newPoint!, color: colorPicked, text: "?")
            currentMeasure.setLabel(label: tempMeasureLabel)
            measures.append(currentMeasure)
            populateNewTempMeasuleLabel()
            break
        case .free:
            undoArtifactList.append(.free)
            break
        case .angle:
            if(angleMidpointSat)
            {
                undoArtifactList.append(.angle)
                angleMidpointSat = false
                currentAngle = Angle(start: currentAngle.start ,mid: currentAngle.mid, end:newPoint!, color: colorPicked, text: "?" )
                currentAngle.setLabel(label: tempAngleLabel)
                angles.append(currentAngle)
                populateNewTempAngleLabel()
            }
            else
            {
                angleMidpointSat = true
                currentAngle = Angle(start: lastPoint,mid: newPoint!, end:nil, color: colorPicked, text: "?" )
             }
        default:
            break
            
        }
    }
    
    func clear()
    {
        lines = []
        
        for item in measures
        {
            item.getLabel().removeFromSuperview()
        }
        for item in angles
        {
            item.getLabel().removeFromSuperview()
        }
        for item in drawnTexts
        {
            item.label?.removeFromSuperview()
        }
        currentAngle = nil
        currentMeasure = nil
        tempAngleLabel.hidden = true
        tempMeasureLabel.hidden = true
        tempTextLabel.hidden = true
        measures = []
        angles = []
        setNeedsDisplay()
        
        
    }
    
    override func drawRect(rect: CGRect) {
        
        if(originalImage == nil)
        {
            return
        }

        var context = UIGraphicsGetCurrentContext()
        //CGContextDrawImage(context, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height), originalImage.CGImage)
        originalImage.drawInRect(CGRectMake(0, 0, originalImage.size.width, originalImage.size.height))
        
        CGContextBeginPath(context)
        CGContextSetLineCap(context, kCGLineCapRound)
        var linewidth = drawingLineWidth * zoomscale
        println("linewidth \(linewidth) zoomscale \(zoomscale)")
        CGContextSetLineWidth(context, linewidth)
        for line in lines
        {
            setStrokeColor(context,color: line.color)
            CGContextMoveToPoint(context, line.start.x, line.start.y)
            CGContextAddLineToPoint(context, line.end.x, line.end.y)

            CGContextStrokePath(context)
        }
        for measurement in measures
        {
            drawMeasumrement(context,measurement: measurement,label: measurement.getLabel(), color: measurement.color)
        }
        for angle in angles
        {
            drawAngle(context, angle: angle, label: angle.getLabel(), color: angle.color)
        }
        for drawntext in drawnTexts
        {
            
        }
        
        
        //temp drawing of measure
        if(drawType == .measure)
        {
            if(currentMeasure != nil)
            {
                drawMeasumrement(context,measurement: currentMeasure,label: tempMeasureLabel, color: colorPicked)
            }
        }
        if(drawType == .angle)
        {
            if(currentAngle != nil)
            {
                drawAngle(context, angle: currentAngle, label: tempAngleLabel, color: colorPicked)
            }
        }
    }
    
    func drawAngle(context:CGContext,angle:Angle,label:UILabel,color:drawColorEnum)
    {
        
        CGContextBeginPath(context)
        setStrokeColor(context,color: color)
        CGContextSetLineCap(context, kCGLineCapRound)
        
        CGContextMoveToPoint(context, angle.start.x, angle.start.y)
        CGContextAddLineToPoint(context, angle.mid.x, angle.mid.y)
        CGContextStrokePath(context)
        
        if(angle.end != nil)
        {
            CGContextMoveToPoint(context, angle.mid.x, angle.mid.y)
            CGContextAddLineToPoint(context, angle.end!.x, angle.end!.y)
            CGContextStrokePath(context)
            
            
            var startAngle = (pointPairToBearingDegrees(angle.start,endingPoint: angle.mid) + 180.0) % 360.0
            var endAngle = pointPairToBearingDegrees(angle.mid,endingPoint: angle.end!)
            
            
            var degToRadEnd = ((CGFloat(M_PI) * endAngle ) / 180.0)
            var degToRadStart = ((CGFloat(M_PI) * startAngle ) / 180.0)
            
            
            
            var clockwiseDraw = IsClockwise([angle.start,angle.mid,angle.end!])
            
            var radiusForDrawingArc:CGFloat = drawingArcRadius * zoomscale
            
            var arcToDraw = UIBezierPath(arcCenter: angle.mid, radius: radiusForDrawingArc, startAngle: CGFloat(degToRadStart), endAngle: CGFloat(degToRadEnd), clockwise: clockwiseDraw)
            arcToDraw.stroke()
            
            
            var arcForPositionLabel = UIBezierPath(arcCenter: angle.mid, radius: radiusForDrawingArc * 1.5, startAngle: CGFloat(degToRadStart), endAngle: CGFloat(degToRadEnd), clockwise: clockwiseDraw)
            
            
            var _angle = angleOfPointsToFixedPoint(angle.start, p2: angle.end!, fixed:angle.mid)
            
            if(_angle > 180.0)
            {
                _angle = (_angle - 360.0) * -1
            }
            println("angle \(_angle)")
            
            
            var midPointPathFrame = CGPathGetPathBoundingBox(arcForPositionLabel.CGPath);
            var approximateMidPointCenter = CGPointMake(CGRectGetMidX(midPointPathFrame), CGRectGetMidY(midPointPathFrame));
            
            if(angle.hardSetText == false)
            {
                label.text =  "\(Int(_angle))°"
            }
            label.center = approximateMidPointCenter
        }
    }

    func drawMeasumrement(context:CGContext,measurement:Measure,label:UILabel, color:drawColorEnum)
    {
        CGContextBeginPath(context)
        setStrokeColor(context,color: color)
        CGContextSetLineCap(context, kCGLineCapRound)
        
        CGContextMoveToPoint(context, measurement.start.x, measurement.start.y)
        
        CGContextAddLineToPoint(context, measurement.end.x, measurement.end.y)
        
        CGContextStrokePath(context)
        var angle = angleOfPointsToFixedPoint(measurement.start, p2: measurement.end)
        //CGContextRotateCTM(context, angle)
        
        drawDisclosureLine(context, x: measurement.start.x, y: measurement.start.y, angle:angle)
        
        drawDisclosureLine(context, x: measurement.end.x, y: measurement.end.y, angle:angle)
        /*
        var drawingFromLeftToRight = measurement.start.x < measurement.end.x
        drawDisclosureIndicator(context, x: measurement.start.x, y: measurement.start.y, pointRight: drawingFromLeftToRight ? false : true)
        drawDisclosureIndicator(context, x: measurement.end.x, y: measurement.end.y, pointRight: drawingFromLeftToRight ? true : false)
        */
        label.center = getPointBetweenPoints(measurement.start, p2: measurement.end, offset: CGPointMake(10, -10))
        
        println("degrees \(angle)")
        label.transform = CGAffineTransformIdentity
        label.transform = CGAffineTransformMakeRotation(angle * CGFloat(M_PI) / 180.0)
  
    }


    
    //MARK: Actions

    func setMeasurementText(sender:UITapGestureRecognizer)->Void
    {
        delegate?.setMeasurementText(sender.view as UILabel)
    }
    
    func setAngleText(sender:UITapGestureRecognizer)->Void
    {
        for angle in angles
        {
            if(angle.getLabel() == (sender.view as UILabel))
            {
                angle.hardSetText = true
            }
        }
        //(sender.view as UILabel).text = "198 °"
        delegate?.setAngleText(sender.view as UILabel)
    }
    
    func setDrawntextText(sender:UITapGestureRecognizer)->Void
    {
        delegate?.setDrawntextText(sender.view as UILabel)
    }
    
    func freeDraw()
    {
        drawType = .free
        markButtonOnDrawtype()
    }
    
    func measureDraw()
    {
        drawType = .measure
        markButtonOnDrawtype()
    }
    
    func angleDraw()
    {
        drawType = .angle
        markButtonOnDrawtype()
    }
    
    func textDraw()
    {
        drawType = .text
        markButtonOnDrawtype()
    }
    
    func markButtonOnDrawtype()
    {
        let markValue:CGFloat = 0.65
        textButton.alpha = 1
        textButton.layer.borderWidth = 0
        angleButton.alpha = 1
        angleButton.layer.borderWidth = 0
        measureButton.alpha = 1
        measureButton.layer.borderWidth = 0
        freeButton.alpha = 1
        freeButton.layer.borderWidth = 0
        switch(drawType)
        {
        case .angle:
            angleButton.alpha = markValue
            angleButton.layer.borderColor = UIColor.blackColor().CGColor
            angleButton.layer.borderWidth = 2.0;
        case .free:
            freeButton.alpha = markValue
            freeButton.layer.borderColor = UIColor.blackColor().CGColor
            freeButton.layer.borderWidth = 2.0;
        case .measure:
            measureButton.alpha = markValue
            measureButton.layer.borderColor = UIColor.blackColor().CGColor
            measureButton.layer.borderWidth = 2.0;
        case .text:
            textButton.alpha = markValue
            textButton.layer.borderColor = UIColor.blackColor().CGColor
            textButton.layer.borderWidth = 2.0;
        default:
            break
        }
    }
    
    func markButtonOnColor()
    {
        let markValue:CGFloat = 0.65
        whiteButton.alpha = 1
        whiteButton.layer.borderWidth = 0
        blackButton.alpha = 1
        blackButton.layer.borderWidth = 0
        blueButton.alpha = 1
        blueButton.layer.borderWidth = 0
        redButton.alpha = 1
        redButton.layer.borderWidth = 0
        switch(colorPicked)
        {
        case .white:
            whiteButton.alpha = markValue
            whiteButton.layer.borderColor = UIColor.blackColor().CGColor
            whiteButton.layer.borderWidth = 2.0;
            choosenColorLabel.text = "⚪️"
        case .black:
            blackButton.alpha = markValue
            blackButton.layer.borderColor = UIColor.blackColor().CGColor
            blackButton.layer.borderWidth = 2.0;
            choosenColorLabel.text = "⚫️"
        case .blue:
            blueButton.alpha = markValue
            blueButton.layer.borderColor = UIColor.blackColor().CGColor
            blueButton.layer.borderWidth = 2.0;
            choosenColorLabel.text = "🔵"
        case .red:
            redButton.alpha = markValue
            redButton.layer.borderColor = UIColor.blackColor().CGColor
            redButton.layer.borderWidth = 2.0;
            choosenColorLabel.text = "🔴"
            
        }
        hideColorButtons()
    }
    
    func undoDraw()
    {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.undoButton.alpha = 0.5
            }, completion: { (value: Bool) in
                self.undoButton.alpha = 1

        })
        
        drawType = .undo
        //find last paused line
        if(undoArtifactList.count > 0)
        {
            switch(undoArtifactList.last!)
            {
            case .free:
                undoFreeDraw()
                break
            case .measure:
                undoMeasureDraw()
                break
            case .angle:
                undoAngleDraw()
                break
            case .text:
                undoDrawntextDraw()
            default:
                break
            }
            undoArtifactList.removeLast()
        }
    
        //reset all controll buttons
        markButtonOnDrawtype()
        
    }
    
    func undoMeasureDraw()
    {
        if(measures.count > 0)
        {
            measures.last?.getLabel().removeFromSuperview()
            measures.removeLast()
            setNeedsDisplay()
        }
    }
    
    func undoAngleDraw()
    {
        if(angles.count > 0)
        {
            angles.last?.getLabel().removeFromSuperview()
            angles.removeLast()
            setNeedsDisplay()
        }
    }
    
    func undoDrawntextDraw()
    {
        if(drawnTexts.count > 0)
        {
            drawnTexts.last?.label?.removeFromSuperview()
            drawnTexts.removeLast()
        }
    }
    
    func undoFreeDraw()
    {
        var index = 0
        for index = (lines.count - 1) ; index > 0; index--
        {
            if(lines[index].lastTouchBegan)
            {
                break
            }
        }
        if(index >= 0)
        {
            lines.removeRange(Range(start: index, end: lines.count))
        }
        setNeedsDisplay()
    }
    
    func blackColor()
    {
        colorPicked = .black
        markButtonOnColor()
    }
    
    func whiteColor()
    {
        colorPicked = .white
        markButtonOnColor()
    }
    
    func blueColor()
    {
        colorPicked = .blue
        markButtonOnColor()
    }
    
    func redColor()
    {
        colorPicked = .red
        markButtonOnColor()
    }
    
    func chooseColor()
    {
        showColorButtons()
    }
    
    func showColorButtons()
    {
        var whiteCenter = whiteButton.center
        var blackCenter = blackButton.center
        var blueCenter = blueButton.center
        var redCenter = redButton.center
        
        whiteButton.center = chooseColorButton.center
        blackButton.center = chooseColorButton.center
        blueButton.center = chooseColorButton.center
        redButton.center = chooseColorButton.center
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.whiteButton.center = whiteCenter
            self.blackButton.center = blackCenter
            self.blueButton.center = blueCenter
            self.redButton.center = redCenter
            self.whiteButton.alpha = 1
            self.blackButton.alpha = 1
            self.blueButton.alpha = 1
            self.redButton.alpha = 1
        })

    }
    
    func hideColorButtons()
    {

        var whiteCenter = whiteButton.center
        var blackCenter = blackButton.center
        var blueCenter = blueButton.center
        var redCenter = redButton.center

        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.whiteButton.center = self.chooseColorButton.center
            self.blackButton.center = self.chooseColorButton.center
            self.blueButton.center = self.chooseColorButton.center
            self.redButton.center = self.chooseColorButton.center
            self.whiteButton.alpha = 0
            self.blackButton.alpha = 0
            self.blueButton.alpha = 0
            self.redButton.alpha = 0
            }, completion: { (value: Bool) in
                self.whiteButton.center = whiteCenter
                self.blackButton.center = blackCenter
                self.blueButton.center = blueCenter
                self.redButton.center = redCenter
        })
        
        /*            completion: { (value: Bool) in{
        self.whiteButton.center = whiteCenter
        self.blackButton.center = blackCenter
        self.blueButton.center = blueCenter
        self.redButton.center = redCenter
        })
        */
    }
    
    func cancelDraw()
    {
        delegate?.cancelDraw()
    }
    
    func saveDraw()
    {
        delegate?.saveDraw()
    }
    
}