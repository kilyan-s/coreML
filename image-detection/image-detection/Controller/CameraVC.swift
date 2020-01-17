//
//  ViewController.swift
//  image-detection
//
//  Created by Kilyan SOCKALINGUM on 17/01/2020.
//  Copyright © 2020 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var capturedImageView: RoundedShadowImageView!
    @IBOutlet weak var flashBtn: RoundedShadowButton!
    @IBOutlet weak var roundedLabelView: RoundedShadowView!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    
    //MARK: Var
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Tap gesture to take a photo
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tapGesture.numberOfTapsRequired = 1
        cameraView.addGestureRecognizer(tapGesture)
        
        //Instantiate session and select resolution
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        //Get the back camera
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            //try to create an input using the back camera
            let input = try AVCaptureDeviceInput(device: backCamera!)
            //Try to add input to captureSession
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            //Create output
            cameraOutput = AVCapturePhotoOutput()
            //Try to add output to captureSession
            if captureSession.canAddOutput(cameraOutput) {
                captureSession.addOutput(cameraOutput)
                
                //Create a video preview layer from the capture session
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                //Maintain aspect ratio & select orientation
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                //Add the previewLayer to the UIView
                cameraView.layer.addSublayer(previewLayer!)
                
                //Start capturing camera feed
                captureSession.startRunning()
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    @objc func didTapCameraView() {
    //Create a preview size of the image capture == easier to display in previewImageView
        let settings = AVCapturePhotoSettings()
        //.first is the default picture, not liveview or hdr version
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        
        settings.previewPhotoFormat = previewFormat
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
}


extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            //Save the file of the photo capture
            photoData = photo.fileDataRepresentation()
            //Create a UIImage from photoData
            let image = UIImage(data: photoData!)
            self.capturedImageView.image = image
        }
    }
}

