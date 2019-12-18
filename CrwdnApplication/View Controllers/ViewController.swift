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


class Crwds{
    
    
    var lattitude:  Double
    var longitude:Double
    var nameOfPlace:String = ""
    var distanceFromCurrentLocation : String = ""
    var imageID:String = ""
    var urlString = ""
    
    init(lattitude :Double, longitude : Double) {
        
        self.lattitude = lattitude
        self.longitude = longitude
    }
    
    
    func setCoordinate(){
        CLLocationCoordinate2DMake(self.lattitude, self.longitude)
        
    }
    
    func GetCoordinate() -> CLLocationCoordinate2D{
        
        return CLLocationCoordinate2DMake(self.lattitude, self.longitude)
    }
    
    
    func SetNameOfPlace(name : String)  {
        self.nameOfPlace = name
    }
    
    
    func getNameofPlace() -> String{
        return self.nameOfPlace
    }
    
    func setImageID(imageid:String){
        self.imageID = imageid
    }
    
    
    func getImageID() -> String{
        return self.imageID
    }
    
    
    func getURL() -> String {
        return self.urlString
    }
    
    func setURL(URL : String){
        self.urlString = URL
    }
    
    
    
}









import UIKit
import MapKit
import CoreLocation
import Parse
import AVFoundation
import RadarSDK

class ViewController: UIViewController , UIGestureRecognizerDelegate {
    
    
    
    
    enum cardState{
        case expanded
        case collapsed
    }
    
    
    //variables
    var tableView = UITableView()
    var selectedPin: MKPlacemark?
    var resultSearchController : UISearchController!
    var chnagingImage:UIImage? = nil
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    let viewAnnotaionInMeters:Double = 675
    let  cellIdentifier = "realCell"
    var crowdList : [Crwds] = []
    let displayLimit = 20
    let cardTransformHeightWhenCollapsed  = -160
    let cardTransformHeightWhenExpanded = 30
    var cardViewController : CardViewController!
    var visualEffectView : UIVisualEffectView!
    let cardHeight :CGFloat = 285
    let cardhandleAreaHeight :CGFloat = 60
    var cardVisible = false
    var userLattidude : Double =  0
    var userLongitude :Double = 0
    var firstUpdate  = false
    var nextState :cardState{
        return cardVisible ? .collapsed : .expanded
    }
    let cornerRadius : CGFloat = 10
    let timeInterval = 0.9
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    // end of varibels and etc
    
    
    @IBOutlet weak var animatedLabel: UIButton!
    
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var animatedStack: UIStackView!
    @IBOutlet weak var topCrowds: UILabel!
    @IBOutlet weak var viewAdd: UIView!
    
    
    @IBOutlet weak var gestureView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var searchAndStatusView: UIView!
    
    @IBOutlet weak var positionOutlet: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var exampleImageView: UIImageView!
    
    @IBAction func centrePosition(_ sender: UIButton) {
        centerViewOnUserLocation()
        
    }
    
    
    //MARK:- handling views
    
    override func viewDidLoad() {
        
        print("user has been deleted")
        firstUpdate = true 
        super.viewDidLoad()
        searchTextField.delegate = self
        setupGesture()
        setUpCard()
        checkLocationServices()
        
        
        
        
        self.collectionView.register(UINib(nibName:"CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
      
        
    }
    
    
   
    
    
    
    
    
    func setUpRader(){
        
        let trackingOptions = RadarTrackingOptions()
        trackingOptions.priority = .responsiveness // use .efficiency instead to reduce location update frequency
        trackingOptions.offline = .replayStopped // use .replayOff instead to disable offline replay
        trackingOptions.sync = .possibleStateChanges // use .all instead to sync all location updates
        Radar.startTracking(trackingOptions: trackingOptions)
        
    }
    
    
    func setupAllAnotaions()
    {
        
        for coordinate in crowdList{
            let newCoordinate = coordinate.GetCoordinate()
            let anotation = MKPointAnnotation()
            anotation.coordinate = newCoordinate
            mapView.addAnnotation(anotation)
            
        }
        
        
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
    
    
    
    func setupViewLook(){
        
        viewAdd.layer.cornerRadius = 20
        viewAdd.layer.shadowOffset = CGSize(width: 0, height: -3)
        viewAdd.layer.shadowOpacity = 0.1
        viewAdd.layer.shadowRadius = 1
        gestureView.layer.cornerRadius = 20
        gestureView.layer.shadowRadius = 1
        
        
        
        
    }
    
    
    func setupCollectionVew(){
        self.collectionView.register(UINib(nibName:"CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
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
    
    
    // parse services
    
    func populate(currentlattitude : Double , currentLongitude : Double){
        
        let parseGeoPoint = PFGeoPoint(latitude: currentlattitude, longitude: currentLongitude)
        let query = PFQuery(className: Constants.CParse.Crwds)
        query.whereKey("location", nearGeoPoint: parseGeoPoint)
        query.limit = displayLimit
        query.findObjectsInBackground { (objects, error) in
            if objects != nil{
                // self.crowdList.removeAll()
                if error == nil  {
                    print("obects retrieved with grace")
                    
                    if objects!.count > 0 {
                        
                        for object in objects!{
                            let objectLocation = object.object(forKey: "location") as! PFGeoPoint
                            let objectLattiude = objectLocation.latitude
                            let objectLongitude = objectLocation.longitude
                            let objectLoctaionInCllocation = CLLocation(latitude: objectLattiude, longitude: objectLongitude)
                            
                            let userLocation = self.locationManager.location
                            
                            let distanceFromCurrentLocationInMiles = (userLocation?.distance(from: objectLoctaionInCllocation))! / 1609.344
                            
                            let objectNameOfPlace = object.object(forKey: "RadarName") as! String
                            let imageid = object.object(forKey: "PlaceID") as! String ?? ""
                            // string will be changed later
                            let singleItem = Crwds(lattitude: objectLattiude, longitude: objectLongitude)
                            singleItem.SetNameOfPlace(name: objectNameOfPlace)
                            singleItem.distanceFromCurrentLocation = "\(Int(distanceFromCurrentLocationInMiles)) m"
                            singleItem.setImageID(imageid: imageid)
                            // query image id here
                            
                            
                            
                            
                            
                            
                            // append item should be the last thing you do
                            self.crowdList.append(singleItem)
                            self.collectionView.reloadData()
                        }
                        self.setupAllAnotaions()
                    }
                    
                    
                    
                }
                    
                else{
                    print("the query failed")
                }
                
                
                
                
            }
            
            
        }
        
        
        
    }
    
    
    
    func queryImages(placeID :String , url: String) -> UIImage? {
        let finalImage: UIImage? = nil
        // do image query for one object here
        
        let query = PFQuery(className: "Images")
        query.whereKey("location", equalTo: placeID)
        // check image for pace id only
        query.findObjectsInBackground { (objects, error) in
            if let error = error{
                // Log details of the failure
                print(error.localizedDescription)
            }
            
            if let objects = objects{
                for object in objects{
                    if object.object(forKey: "location") as! String == placeID{
                        //check if image is a video or picture
                        
                        // get screenshot if its a video or get low quality picture
                        
                        //  this funtion is incomplete
                    }
                    
                }
            }
            
            
        }
        
        
        
        
        //check if image is a video or picture
        
        // get screenshot if its a video or get low quality picture
        
        
        
        return finalImage
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
                        self.chnagingImage = finalImage
                        
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
                finalUrl = (localURL as! String)
                
                
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

extension ViewController : UITextFieldDelegate {
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


extension ViewController: HandleMapSearch {
    
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

extension ViewController : UITableViewDelegate , UITableViewDataSource {
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



























