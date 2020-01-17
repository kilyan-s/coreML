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


}

