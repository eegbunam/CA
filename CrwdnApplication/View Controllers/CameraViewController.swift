//
//  CameraViewController.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 9/2/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController , AVCapturePhotoCaptureDelegate{
    

    @IBOutlet weak var cameraView: UIImageView!
    
    
    var captureSession :AVCaptureSession?
    var videoPreview :AVCaptureVideoPreviewLayer?
    var frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    var backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    var capturePhotoOutput: AVCapturePhotoOutput?
    var on = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        on = false
      
        if #available(iOS 10.2, *)
        {
            let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            startCameraWork( cameraDevice: cameraDevice!)
        }
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true
        captureSession?.addOutput(capturePhotoOutput!)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoData = photo.fileDataRepresentation() else {
            return
        }
//        guard let photoImage = UIImage(data: photoData) else {
//            return
//        }
        let capturedImage = UIImage.init(data: photoData , scale: 1.0)
                if let image = capturedImage{
                    // upload to server
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
    }
 
    
    
    
    
    
    
    
    
    
    
    func switchFront(){
        // switches camra to front
        
        if frontCamera?.isConnected == true{
            captureSession?.stopRunning()
            let cameraDevice = frontCamera
            startCameraWork( cameraDevice: cameraDevice!)
            
        }
        
        
    }
    
    func switchBack(){
        // switches camera to back
        
        if backCamera?.isConnected == true{
            captureSession?.stopRunning()
            let cameraDevice = backCamera
            startCameraWork( cameraDevice: cameraDevice!)
            
        }
        
    }
 
    @IBAction func ImageCapture(_ sender: UIButton) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        //let flashMode: AVCaptureDevice.FlashMode // .on, .off, .auto [default is .auto]
        
        
    }
    
    @IBAction func CameraOptions(_ sender: UIButton) {
        
        if sender.tag == 1{
            guard let currenCameraInput : AVCaptureInput = captureSession?.inputs.first else{
                return }
            
            if let input = currenCameraInput as? AVCaptureDeviceInput{
                
                if input.device.position == .back
                
                {
                    switchFront()
                }
                if input.device.position == .front
                    
                {
                    switchBack()
                }
                
                
            }
        
            
            
            
        }
        if sender.tag == 2{
            
//             let flashMode: AVCaptureDevice.FlashMode // .on, .off, .auto [default is .auto]
//            flashMode = .auto
            
        }
    }
    
    
    
    func startCameraWork (cameraDevice:AVCaptureDevice ) {
        // sets up camra to work on the phone with capture device variable needed
        
        
        do{
            let input = try AVCaptureDeviceInput(device: cameraDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            videoPreview = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreview?.frame = cameraView.bounds
            cameraView.layer.addSublayer(videoPreview!)
            captureSession?.startRunning()
            
            
            // set up for camera
        }
        catch{
            print("error")
            
        }
        
    }
    
    
}

//extension ViewController : AVCapturePhotoCaptureDelegate {
//    // what happpens when the photo is processed
////    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer : CMSampleBuffer?, resolvedSettings : AVCaptureResolvedPhotoSettings,bracketSettings:AVCaptureBracketedStillImageSettings , error: Error?) {
////        guard error == nil,
////            let photoSampleBuffer =  photoSampleBuffer else {
////                print("error")
////                return
////        }
////        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
////            else{
////                return
////        }
////
////
////
////        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
////        if let image = capturedImage{
////            // upload to server
////            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
////        }
////    }
//}
