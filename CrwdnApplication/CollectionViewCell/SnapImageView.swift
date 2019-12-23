//
//  SnapView.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 12/17/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

import UIKit



class SnapImageView : UIImageView{
    
    private var circleBorder: CALayer!
    private var SecondcircleBorder: CALayer!
    
    
    private var newimageView : UIImageView!
    
    
    
    
    
    override func awakeFromNib() {
           setUpView()
        drawCircle(onImageView: self, withColor: UIColor.red.cgColor, andTagToRemove: 10, withlayer: self.layer)
        
       drawSecondCircle(onImageView: self, withColor: UIColor.white.cgColor, andTagToRemove: 0, withlayer: self.layer)
       }
       

    
    func setUpView(){
        
               self.layer.cornerRadius =  self.frame.width / 2
              self.clipsToBounds = true
              self.backgroundColor = .gray
              self.layer.borderWidth = 1
              self.layer.borderColor = UIColor.clear.cgColor
            
        
        
    }
    
    func SetUpImageView(){
        newimageView = UIImageView()
    }
    
    private func drawCircle(onImageView imageView: UIImageView , withColor color : CGColor , andTagToRemove _tag: Int, withlayer _layer : CALayer ) {

        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 3.0
        circleBorder.borderColor = color
        circleBorder.bounds = imageView.bounds
        circleBorder.position = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)
    

    }
    
    
    private func drawSecondCircle(onImageView imageView: UIImageView , withColor color : CGColor , andTagToRemove _tag: Int, withlayer _layer : CALayer ) {
      //this function is fragile and not stable
        
        SecondcircleBorder = CALayer()
        SecondcircleBorder.backgroundColor = UIColor.clear.cgColor
        SecondcircleBorder.borderWidth = 6.0
        SecondcircleBorder.borderColor = color
        SecondcircleBorder.bounds = layer.bounds
        SecondcircleBorder.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        SecondcircleBorder.cornerRadius = layer.frame.size.width / 2
        layer.insertSublayer(SecondcircleBorder, at: 0)
    

    }
    
    
    
    
    
    
    
    func clickToViewSnaps(withSnapsFromServer _snaps :[UIImage]){
        
    }
    
    func clickToViewVidoes(withVideosFromServer _snaps :[UIImage]){
        
    }
    
}
