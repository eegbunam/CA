//
//  ViewController.swift
//  CrwdnApplication
//
//  Created by Ebuka Egbunam on 8/22/19.
//  Copyright © 2019 Ebuka Egbunam. All rights reserved.
//

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

protocol ViewControllerDelegate {
    func didGetCurrentLocation (currentLocation : CLLocationCoordinate2D)
}





import UIKit
import MapKit
import CoreLocation
import Parse
import AVFoundation
import RadarSDK

class MapViewController: UIViewController , UIGestureRecognizerDelegate {
    
    
    enum SlideUpCardState{
        case closed
        case middle
        case fullyOpen
    }
    
    
    enum cardState{
        case expanded
        case collapsed
    }
    
    
    //variables
    var tableView = UITableView()
    var selectedPin: MKPlacemark?
    var resultSearchController : UISearchController!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    let viewAnnotaionInMeters:Double = 675
    let  cellIdentifier = "realCell"
    
    
    
    
    var slideUpViewController : SlideUpViewController!
    var delegate : ViewControllerDelegate?
   
    
    
    let SlideUpcardHeight :CGFloat = 277
    let SlideUpcardhandleAreaHeight :CGFloat = 120
    let slideUPfullScreenHeight : CGFloat = 600
    
    
    var userLattidude : Double =  0
    var userLongitude :Double = 0
    var firstUpdate  = false
   let cornerRadius : CGFloat = 10
    let timeInterval = 0.9
    
    
    var slideUprunningAnimations = [UIViewPropertyAnimator]()
    var slideUpViewVisible = false
    var slideUpnextState :SlideUpCardState = .closed
    
    
    
    var slideUpanimationProgressWhenInterrupted: CGFloat = 0
    
    // end of varibels and etc
    
    
   
    
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var animatedStack: UIStackView!
  
    

    
    @IBOutlet weak var searchAndStatusView: UIView!
    
    @IBOutlet weak var positionOutlet: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
 
    
    @IBAction func centrePosition(_ sender: UIButton) {
        centerViewOnUserLocation()
        
    }
    
    
    //MARK:- handling views
    
    override func viewDidLoad() {
        
        
        print("user has been deleted")
        firstUpdate = true 
        super.viewDidLoad()
        searchTextField.delegate = self
        checkLocationServices()
        setUpSlideUpView()
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    func setUpRader(){
        
        let trackingOptions = RadarTrackingOptions()
        trackingOptions.priority = .responsiveness // use .efficiency instead to reduce location update frequency
        trackingOptions.offline = .replayStopped // use .replayOff instead to disable offline replay
        trackingOptions.sync = .possibleStateChanges // use .all instead to sync all location updates
        Radar.startTracking(trackingOptions: trackingOptions)
        
    }
    
    
    
    
    
    @IBAction func GotoCamera(_ sender: Any) {
        
        if #available(iOS 13.0, *) {
            let cameraViewController = UIStoryboard(name: "CameraStoryboard", bundle: nil).instantiateViewController(identifier: "CameraViewController") as! CameraViewController
            cameraViewController.modalPresentationStyle = .fullScreen
            self.present(cameraViewController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    
    
    @IBAction func triggerDelegate(_ sender: UIButton) {
     
    }
    
    func  ZoomToLocation( coordinate : CLLocationCoordinate2D)
    {
        //        let anotation = MKPointAnnotation()
        //        anotation.coordinate = coordinate
        //        mapView.addAnnotation(anotation)
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: viewAnnotaionInMeters, longitudinalMeters: viewAnnotaionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func setupGesture(){
        let mygestureRecognizer = UIGestureRecognizer()
        mygestureRecognizer.delegate = self
        
        
    }
    
    
    
    
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // everything to do with location and map set up
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // navigationController?.setToolbarHidden(true, animated: true)
    }
    //MARK:- LOCATION SETTINGS
    
    
    
    
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            //print("yup")
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
    
   
    
   
    
    func showTableView(shouldShow : Bool){
        if shouldShow{
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame = CGRect(x: 20, y: 170, width: self.view.frame.width - 40 , height: self.view.frame.height - 170)
                
            }
        }else{
            
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame = CGRect(x: 20, y: 170, width: self.view.frame.width - 40 , height: self.view.frame.height - 170)
            }) { (finished) in
                for subview in self.view.subviews{
                    if subview.tag == 18 {
                        subview.removeFromSuperview()
                    }
                }
            }
            
            
        }
        
    }
    
    @objc func testSegue(){
        if #available(iOS 13.0, *) {
            let viewImageSnapViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewImageSnapViewController") as! ViewImageSnapViewController
            viewImageSnapViewController.modalPresentationStyle = .fullScreen
            self.present(viewImageSnapViewController, animated: true, completion: nil)
            
            
        } else {
            // Fallback on earlier versions
        }
        
        
        
    }
    
    
    
    func DownloadImage(imageURL : String){
        /* this functions takes the image url as a string,
         conversts it to a url ,
         and then downloads it and save it in an optional variable
         */
        var finalImage:UIImage? = nil
        let url = URL(string: imageURL)!
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: url){ (data,response,error)  in
            if let e = error {
                // error downloading
                print("Error downloading cat picture: \(e)")
            }
                
            else{
                // no errors
                DispatchQueue.main.async {
                    // running things back on the main thread
                    if let imageData = data{
                        finalImage = UIImage(data: imageData)
                        
                        
                    }else{
                        print("Couldn't get image: Image is nil")
                        
                    }
                    
                }
                
                
            }
            
        }
        downloadPicTask.resume()
 
    }
    
    
    
    func DownloadVideo(videoURL : String) -> String?{
        /* takes a url from server side ,
         downloads the data,
         stores data in an optional string that willn be returned
         */
        let url = URL(string:videoURL)!
        var  finalUrl :String? = nil
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL {
                //finalUrl = (localURL as! String)
                
                
            }
        }
        
        task.resume()
        return finalUrl
        
    }
    
    
    func takescreenshot(videoUrl : String?) -> UIImage?{
        /*
         takes video file storage url and creates a
         screenshot of the video
         */
        var finalImage : UIImage? = nil
        
        if let videoUrl = videoUrl {
            let videoUrl = URL(string: videoUrl)!
            let asset = AVAsset(url: videoUrl )
            let assetGenerator = AVAssetImageGenerator(asset: asset)
            do{
                let finalCgImage =  try assetGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
                finalImage = UIImage(cgImage: finalCgImage)
            }
            catch let err{
                print(err)
            }
            
        }
        
        
        
        return finalImage
        
        
    }
    
    
    func deleteFiles(fileUrl : URL){
        /*
         takes a file url
         deletes the file with url
         */
        let fileURL = fileUrl
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            
        } catch {
            fatalError("Couldn't remove file.")
        }
        
    }
    
}

extension MapViewController : UITextFieldDelegate {
    // comment this whole extention to silence the warning ; testing something here ; do not change the code here
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchTextField{
            tableView.frame = CGRect(x: 20, y: view.frame.height, width: view.frame.width - 40 , height: view.frame.height - 170)
            tableView.layer.cornerRadius = 5
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationcell")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tag = 18
            tableView.rowHeight = 60
            view.addSubview(tableView)
            showTableView(shouldShow: true)
            
        }
        
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    
}


extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}

extension MapViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
}






extension MapViewController {
    //MARK:- slide up view controllerSlideUpViewControllercontrols
    
    
    
    func setUpSlideUpView(){
        slideUpViewController = SlideUpViewController(nibName: "SlideUpViewController", bundle: nil)
        slideUpViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - SlideUpcardhandleAreaHeight, width: self.view.frame.width, height: self.view.frame.height)
        slideUpViewController.view.clipsToBounds = true
        slideUpViewController.delegate = self // do not remove
        self.delegate = slideUpViewController
        self.addChild(slideUpViewController) // do not remove
        
        
        self.view.addSubview(slideUpViewController.view)
        
        let slideUpPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SlidehandlePan(recognizer:)))
        let slideUpTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(slideUpTap(recognzier:)))
        slideUpViewController.handleAreaView.addGestureRecognizer(slideUpTapGestureRecognizer)
        slideUpViewController.handleAreaView.addGestureRecognizer(slideUpPanGestureRecognizer)
        
        
        
        
        
        
    }
    
    
    
    
    @objc func slideUpTap( recognzier : UITapGestureRecognizer){
        switch recognzier.state {
               case .ended:
                 print("in tapgetsure ")
                   slideupViewAnimator(state: slideUpnextState, duration: timeInterval)
               
            
               default:
                   break
               }
    }
    
    
    @objc
    func SlidehandlePan(recognizer : UIPanGestureRecognizer){
        switch recognizer.state {
        case .began:
            
            startSlideUpViewTrans(state: slideUpnextState, duration: timeInterval)
            break
            
        case .changed:
            let translation = recognizer.translation(in: self.slideUpViewController.handleAreaView)
         
            var fractionCompleted = translation.y  / SlideUpcardHeight
            fractionCompleted = slideUpViewVisible ? fractionCompleted : -fractionCompleted
            slideUpupdateTrans(fractionCompleted:fractionCompleted)
            break
            
            
        case .ended:
            //check translation and stop animation if needed
            slideUpcontinuetrans()
            break
            
        default:
            break
        }
        
    }
    
    
    
    func slideupViewAnimator(state : SlideUpCardState , duration : TimeInterval)
    {
        
     
        if slideUprunningAnimations.isEmpty{
            let viewAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {


                switch state{

            
                case .closed:
                    //OPENS TO MID SCREEN
                    self.slideUpViewController.view.frame.origin.y = self.view.frame.height - self.SlideUpcardHeight
                    self.slideUpnextState = .middle
                    self.slideUpViewVisible = true
                    break


                case .middle:
                    //OPENS TO FULL SCREEN
                     self.slideUpViewController.view.frame.origin.y = 50
                    self.slideUpnextState = .fullyOpen
                     self.slideUpViewVisible = true
                    break
                    
                case .fullyOpen:
                    //CLOSES FULL SCREEN
                     self.slideUpViewController.view.frame.origin.y = self.view.frame.height - self.SlideUpcardhandleAreaHeight
                     print("fully open")
                    self.slideUpnextState = .closed
                     self.slideUpViewVisible = false
                    
                    
                }
            }
            viewAnimator.addCompletion { (_) in
                
                self.slideUprunningAnimations.removeAll()
            }

            viewAnimator.startAnimation()

            slideUprunningAnimations.append(viewAnimator)
        }
        
        
    }
    
    func startSlideUpViewTrans(state : SlideUpCardState , duration : TimeInterval){
        if slideUprunningAnimations.isEmpty{
            slideupViewAnimator(state:state, duration: duration)
            
        }
        for animator in slideUprunningAnimations{
            animator.pauseAnimation()
            slideUpanimationProgressWhenInterrupted = animator.fractionComplete
        }
        
        
    }
    
    func slideUpupdateTrans(fractionCompleted : CGFloat){
        
        for animator in slideUprunningAnimations{
            animator.fractionComplete = fractionCompleted + slideUpanimationProgressWhenInterrupted
        }
        
    }
    
    func slideUpcontinuetrans(){
        
        for animator in slideUprunningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
        
    }
    
    
    
    
    
}

extension MapViewController : SlideUpViewControllerDelelegate {
    func willUpdateMapViewWithCoordinate(coordinate: CLLocationCoordinate2D) {
        /* update map view when user clicks on a collection view cell
        by moving the map view to that location
        */
    }
    
    func willAddAnnotationwithcrowdItem(CrowdItem: [Crowd]) {
        /*
         add annotaions to each crowd item in the the crwodlist passed
         */
    }
    
    
    
}

























