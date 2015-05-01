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
    
    func savePictureFromCamera(imageData:NSData?)
    func chooseImageFromPhotoLibrary()
    func cancelImageFromCamera()
    func initForCameraAndPickerView()
}

class CameraView: UIView
{
    var delegate: CameraProtocol?
    
    var imageView:UIImageView!

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
    
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    /*
    convenience init(frame: CGRect, delegate:CameraProtocol) {
        
        self.init(frame: frame)
        self.delegate = delegate
        self.delegate?.initForCameraAndPickerView()
    }
*/

    
    override init(frame: CGRect) {
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
        
    }
    
    func takeImageFromCamera(){
        
        println("running AV chooseImageFromCamera")
        
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        var videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
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
        
        self.delegate?.savePictureFromCamera(self.imageData)
    }
    
    func retakeImageFromCamera()
    {
        self.imageView.hidden = true
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
        delegate?.chooseImageFromPhotoLibrary()
    }
   
}
