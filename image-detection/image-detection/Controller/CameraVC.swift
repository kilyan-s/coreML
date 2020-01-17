//
//  ViewController.swift
//  image-detection
//
//  Created by Kilyan SOCKALINGUM on 17/01/2020.
//  Copyright © 2020 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
    case on
    case off
}

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
    var flashCtrlState: FlashState = .off
    
    var speechSynth = AVSpeechSynthesizer()
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer.frame = cameraView.bounds
        speechSynth.delegate = self
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
        
        //Set flash mode 
        if flashCtrlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func resultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        //loop through each classification found in the image
        for classification in results {
            print(classification)
            if classification.confidence < 0.5 {
                let unknownObjectMsg = "I am not sure what this is. Please try again."
                self.identificationLbl.text = unknownObjectMsg
                self.confidenceLbl.text = ""
                synthesizeSpeech(fromString: unknownObjectMsg)
                break
            } else {
                let identification = classification.identifier
                let confidence = Int(classification.confidence * 100)
                self.identificationLbl.text = identification
                self.confidenceLbl.text = "CONFIDENCE: \(confidence)%"
                
                let speakString = "This look like a \(identification). I am \(confidence)% sure."
                synthesizeSpeech(fromString: speakString)
                
                break
            }
        }
    }
    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynth.speak(speechUtterance)
    }
    
    //MARK: Actions
    
    @IBAction func flashBtnWasPressed(_ sender: Any) {
        switch flashCtrlState {
        case .on:
            flashBtn.setTitle("FLASH OFF", for: .normal)
            flashCtrlState = .off
        case .off:
            flashBtn.setTitle("FLASH ON", for: .normal)
            flashCtrlState = .on
        }
    }
}


extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            //Save the file of the photo capture
            photoData = photo.fileDataRepresentation()
            
            do {
                //Create a vision model using SqueezeNet model
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                //Create a request from the model
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                //create a handler for data: image data
                let handler = VNImageRequestHandler(data: photoData!)
                
                //Perform the request
                try handler.perform([request])
                
            } catch {
                debugPrint(error)
            }
            
            //Create a UIImage from photoData
            let image = UIImage(data: photoData!)
            self.capturedImageView.image = image
        }
    }
}

extension CameraVC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
    }
}
