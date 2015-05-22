//
//  CameraView.swift
//  GeoFile
//
//  Created by knut on 18/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit

import Foundation
import AVFoundation
import MobileCoreServices

protocol CameraProtocol {
    
    func savePictureFromCamera(imageData:NSData?,saveAsNewInstance:Bool,worktype:workType)
    func chooseImageFromPhotoLibrary(saveAsNewInstance:Bool,worktype:workType)
    func cancelImageFromCamera()
    func initPickerView()
}

class CameraView: UIView, UIPickerViewDelegate, UIPickerViewDataSource
{
    var delegate: CameraProtocol?
    
    var imageView:UIImageView!
    var selectedType:workType = workType.info
    var chooseFromCameraButton:CustomButton!
    var chooseFromLibraryButton:CustomButton!
    var cancelButton:CustomButton!
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var stillImageOutput = AVCaptureStillImageOutput()
    var imageData: NSData!
    
    var retakeImageButton:CustomButton!
    var confirmImageButton:CustomButton!
    
    var pictureOverlayTemplate:UIImageView!
    
    
    var setImageTypeView:UIView!
    var setTypeHeadingLabel:UILabel!
    var setTypeButton:CustomButton!
    var setTypePickerView:UIPickerView!
    var typeSelectedLabel:UILabel?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    init(frame: CGRect, image:UIImage?,showtypes:Bool = false) {
        super.init(frame: frame)
        
        chooseFromLibraryButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight, UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        chooseFromLibraryButton.setTitle("Camera roll", forState: .Normal)
        chooseFromLibraryButton.addTarget(self, action: "chooseImageFromPhotoLibrary", forControlEvents: .TouchUpInside)
        self.addSubview(chooseFromLibraryButton)
        
        chooseFromCameraButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2), UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        chooseFromCameraButton.setTitle("Take picture", forState: .Normal)
        chooseFromCameraButton.addTarget(self, action: "takeImageFromCamera", forControlEvents: .TouchUpInside)
        self.addSubview(chooseFromCameraButton)
        
        retakeImageButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - buttonBarHeight, UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        retakeImageButton.setTitle("Retake image", forState: .Normal)
        retakeImageButton.addTarget(self, action: "retakeImageFromCamera", forControlEvents: .TouchUpInside)
        self.addSubview(retakeImageButton)
        retakeImageButton.hidden = true
        
        confirmImageButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*2), UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        confirmImageButton.setTitle("Use image", forState: .Normal)
        confirmImageButton.addTarget(self, action: "confirmImageFromCamera", forControlEvents: .TouchUpInside)
        self.addSubview(confirmImageButton)
        confirmImageButton.hidden = true
        
        
        cancelButton = CustomButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight*3), UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: "cancelImageFromCamera", forControlEvents: .TouchUpInside)
        self.addSubview(cancelButton)
        
        imageView = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight * 3)))
        self.addSubview(imageView)
        
        pictureOverlayTemplate = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - (buttonBarHeight * 3)))
        pictureOverlayTemplate.backgroundColor = UIColor.redColor()
        pictureOverlayTemplate.alpha = 0.5
        self.addSubview(pictureOverlayTemplate)
        
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginSession()
                    }
                }
            }
        }
        
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        //if image is provided it should be saved as a paralell picture instance , not on a new point
        if image != nil
        {
            setImageTypeView = UIView(frame: self.bounds)
            setImageTypeView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            
            setTypeHeadingLabel = UILabel(frame: CGRectMake(0, 0, self.bounds.width, buttonBarHeight))
            setTypeHeadingLabel.textAlignment = NSTextAlignment.Center
            setTypeHeadingLabel.center = CGPointMake(self.frame.width / 2,  self.frame.height * 0.1)
            setTypeHeadingLabel.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
            setTypeHeadingLabel.text = "Choose type"
            
            setTypePickerView = UIPickerView(frame: CGRectMake(0, 0, self.frame.width * 0.9, buttonBarHeight))
            setTypePickerView.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
            setTypePickerView.center = CGPointMake(self.frame.width / 2 , self.frame.height / 2)
            setTypePickerView.delegate = self
            setTypePickerView.dataSource = self
            
            setTypeHeadingLabel = UILabel(frame: CGRectMake(setTypePickerView.frame.minX, setTypePickerView.frame.minY - buttonBarHeight, self.frame.width * 0.9, buttonBarHeight))
            setTypeHeadingLabel.textAlignment = NSTextAlignment.Center
            setTypeHeadingLabel.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
            setTypeHeadingLabel.text = "Choose type"
            
            setTypeButton = CustomButton(frame: CGRectMake(setTypePickerView.frame.minX, setTypePickerView.frame.maxY, self.frame.width * 0.9, buttonBarHeight))
            setTypeButton.setTitle("OK", forState: UIControlState.Normal)
            setTypeButton.addTarget(self, action: "setType", forControlEvents: .TouchUpInside)

            
            setImageTypeView.addSubview(setTypePickerView)
            setImageTypeView.addSubview(setTypeButton)
            setImageTypeView.addSubview(setTypeHeadingLabel)
            
            typeSelectedLabel = UILabel(frame: CGRectMake(self.frame.width - buttonIconSide, 0, buttonIconSide, buttonIconSide))
            typeSelectedLabel!.textAlignment = NSTextAlignment.Center
            typeSelectedLabel?.hidden = true
            
            
            pictureOverlayTemplate.image = image
            pictureOverlayTemplate.hidden = false
            self.bringSubviewToFront(pictureOverlayTemplate)
            self.addSubview(typeSelectedLabel!)
            
            
            self.addSubview(setImageTypeView)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workType.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return "\(workType(rawValue: row)!.icon) \(workType(rawValue: row)!.description)" //"\(workType(rawValue: row)?.description) \(workType(rawValue: row)?.icon)"
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = workType(rawValue: row)!
    }
    
    func setType()
    {
        typeSelectedLabel!.text = selectedType.icon
        typeSelectedLabel?.hidden = false
        setImageTypeView.removeFromSuperview()
    }
    
    var videoConnection:AVCaptureConnection!
    func takeImageFromCamera(){
        
        println("running AV chooseImageFromCamera")
        pictureOverlayTemplate.hidden = true
        typeSelectedLabel?.hidden = true
        if videoConnection != nil {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(stillImageOutput.connectionWithMediaType(AVMediaTypeVideo))
                { (imageDataSampleBuffer, error) -> Void in
                    
                    self.imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    //self.delegate?.savePictureFromCamera(self.imageData)
                    self.imageView.image = UIImage(data: self.imageData)
                    self.imageView.hidden = false
                    self.bringSubviewToFront(self.imageView)
                    self.hiddenBaseButtons(true)
                    self.hiddenConfirmPreviewButtons(false)
            }}

    }
    
    func confirmImageFromCamera()
    {
        self.imageView.hidden = true
        self.hiddenBaseButtons(false)
        self.hiddenConfirmPreviewButtons(true)
        
        self.delegate?.savePictureFromCamera(self.imageData,saveAsNewInstance: (pictureOverlayTemplate.image != nil),worktype:selectedType)
    }
    
    func retakeImageFromCamera()
    {
        self.imageView.hidden = true
        pictureOverlayTemplate.hidden = false
        typeSelectedLabel?.hidden = false
        self.hiddenBaseButtons(false)
        self.hiddenConfirmPreviewButtons(true)
        captureSession.stopRunning()
        captureSession.startRunning()
    }
    
    func hiddenBaseButtons(hidden: Bool)
    {
        //cancelButton.hidden = hidden
        chooseFromCameraButton.hidden = hidden
        chooseFromLibraryButton.hidden = hidden
    }
    

    func hiddenConfirmPreviewButtons(hidden: Bool)
    {
        confirmImageButton.hidden = hidden
        retakeImageButton.hidden = hidden
    }
    
    func updateDeviceSettings(focusValue : Float, isoValue : Float) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                device.unlockForConfiguration()
            }
        }
    }
    
    func beginSession() {
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.layer.addSublayer(previewLayer)
        //self.view.layer.addSublayer(previewLayer)
        //imagePickerView.bringSubviewToFront(chooseFromCameraButton)
        self.bringSubviewToFront(chooseFromCameraButton)
        self.bringSubviewToFront(chooseFromLibraryButton)
        self.bringSubviewToFront(cancelButton)
        self.bringSubviewToFront(retakeImageButton)
        self.bringSubviewToFront(confirmImageButton)
        previewLayer?.frame = self.layer.frame
        captureSession.startRunning()
    }
    
    func cancelImageFromCamera()
    {
        delegate?.cancelImageFromCamera()
    }
    
    func chooseImageFromPhotoLibrary()
    {
        delegate?.chooseImageFromPhotoLibrary((pictureOverlayTemplate.image != nil),worktype:selectedType)
    }
   
}
