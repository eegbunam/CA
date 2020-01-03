//
//  PhotoViewController.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 8/22/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

	override var prefersStatusBarHidden: Bool {
		return true
	}

    private var backgroundImage: UIImage? {
        didSet{
            self.view.backgroundColor = UIColor.gray
            let backgroundImageView = UIImageView(frame: view.frame)
            backgroundImageView.contentMode = UIView.ContentMode.scaleAspectFill
            backgroundImageView.image = backgroundImage
            view.addSubview(backgroundImageView)
            let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
            cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControl.State())
            cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            view.addSubview(cancelButton)
            
        }
    }
    
    
    
//	init(image: UIImage) {
//		self.backgroundImage = image
//		super.init(nibName: nil, bundle: nil)
//	}

//	required init?(coder aDecoder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}

	override func viewDidLoad() {
        
        
		super.viewDidLoad()
		
	}

	@objc func cancel() {
		dismiss(animated: true, completion: nil)
	}
}


extension PhotoViewController : CameraViewControllerDelegate {
    
    func didreceiveImage(image: UIImage) {
        self.backgroundImage = image
       
    }
}
