//
//  ViewController.swift
//  image-detection
//
//  Created by Kilyan SOCKALINGUM on 17/01/2020.
//  Copyright © 2020 Kilyan SOCKALINGUM. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var capturedImageView: RoundedShadowImageView!
    @IBOutlet weak var flashBtn: RoundedShadowButton!
    @IBOutlet weak var roundedLabelView: RoundedShadowView!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

