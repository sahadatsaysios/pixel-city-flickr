//
//  ViewController.swift
//  Pixel-city-two
//
//  Created by Sahadat  Hossain on 28/11/18.
//  Copyright © 2018 Sahadat  Hossain. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AlamofireImage
import Alamofire

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHightConstent: NSLayoutConstraint!
    
    var coreLocationManager = CLLocationManager()
    let authoriztionStatus  = CLLocationManager.authorizationStatus()
    
    let regionRadious : Double = 500
    
    var spinner : UIActivityIndicatorView?
    var progressLbl : UILabel!
    let screenSize = UIScreen.main.bounds
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?
    
    var imagesUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        coreLocationManager.delegate = self
        
        // config to user location
        getUserLocation()
        
        // add drop pin
        addDoubleTap()
        
        // center on map user location
        centerMapOnUserLocation()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCellCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        pullUpView.addSubview(collectionView!)
        
        
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp () {
        pullUpViewHightConstent.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown () {
        // cancel all session if swipe down
        self.cancelAllSession()
        
        pullUpViewHightConstent.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner () {
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner?.startAnimating()
        
        collectionView!.addSubview(spinner!)
    }
    
    func removeSpinner () {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProcessLbl () {
        progressLbl = UILabel()
        
        progressLbl.frame = CGRect(x: (screenSize.width / 2) - 100, y: 175, width: 200, height: 40)
        progressLbl.font = UIFont(name: "Avenir Next", size: 15)
        progressLbl.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        progressLbl.textAlignment = .center
//        progressLbl.text = "5/2 PHOTOS LOADED."
        collectionView!.addSubview(progressLbl)
        
    }
    
    func removeProgressLbl () {
        if progressLbl != nil {
            progressLbl.removeFromSuperview()
        }
    }

    @IBAction func centerOnUserLocation(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    func addDoubleTap () {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func retriveUrl(forAnnotation annotation : DropablePin, handler : @escaping (_ status : Bool) -> ()) {
        imagesUrlArray = []
        Alamofire.request(flickrUrl(apiKeyfor: API_KEY, withAnnotation: annotation, addPhotoNumber: 10)).responseJSON { (response) in
            
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imagesUrlArray.append(postUrl)
            }
            
            handler(true)
        }
    }
    
    func retriveImages (handler: @escaping (_ status : Bool) -> ()) {
        self.imageArray = []
        
        for url in imagesUrlArray {
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLbl.text = "\(self.imageArray.count)/10 IMAGES DOWNLOADED..."
                
                if self.imageArray.count == self.imagesUrlArray.count {
                    handler(true)
                }
            }
        }
    }
    
    func cancelAllSession () {
        
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            uploadData.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
    
}

extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
        }
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "dropablePin")
        
        pin.pinTintColor = #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1)
        pin.animatesDrop = true
        
        return pin
    }
    
    func centerMapOnUserLocation () {
        guard let coordinate = coreLocationManager.location?.coordinate else { return }
        //print(coordinate)
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRadious * 2.0, longitudinalMeters: regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    @objc func dropPin (sender : UIGestureRecognizer) {
        
        removePin()
        removeSpinner()
        removeProgressLbl()
        self.cancelAllSession()
        
        self.imagesUrlArray = []
        self.imageArray = []
        self.collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProcessLbl()
        
        
       let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DropablePin(coordinate: touchCoordinate, identifier: "dropablePin")
        mapView.addAnnotation(annotation)
                
        let coordinateRegion = MKCoordinateRegion.init(center: touchCoordinate, latitudinalMeters: regionRadious * 2.0, longitudinalMeters: regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retriveUrl(forAnnotation: annotation) { (finished) in
            if finished {
                self.retriveImages(handler: { (finished) in
                    if finished {
                        // remove spinner
                        self.removeSpinner()
                        // remove progressLbl
                        self.removeProgressLbl()
                        // Reload collecationView
                        self.collectionView?.reloadData()
                    }
                })
            }
            
        }
    }
    
    func removePin () {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}

extension ViewController : CLLocationManagerDelegate {
    
    func getUserLocation () {
        if authoriztionStatus == .notDetermined {
            coreLocationManager.requestAlwaysAuthorization()
        } else { return }
    }
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCellCollectionViewCell
        
        let imageFromIndex = self.imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
        
    }
    
    
}
