//
//  Created by Volodymyr Andriienko on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController {
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var brickIconImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoButton: UIButton!
    
    enum State {
        case open
        case close
    }
    var state: State = .close
    let locationManager = CLLocationManager()
    var weatherData = WeatherData()
    let labelOpenInfo = UILabel()
    let darkLabelInfo = UILabel()
    let layer0 = CAGradientLayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        startLocationManager()
        infoView()
        cityLabel.font = UIFont(name: "SF Pro Display Light", size: 17)
        tempLabel.font = UIFont(name: "SF Pro Display Semibold", size: 100)
        weatherDescriptionLabel.font = UIFont(name: "SF Pro Display Light", size: 36)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(animationPanGesture(_:latitude:longitude:)))
        brickIconImage.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeInfoView))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    func updateView() {
        weatherDescriptionLabel.text = DataSource.weatherIDs[weatherData.weather[0].id]
        tempLabel.text = Int(weatherData.main.temp).description + "°C"
        switch weatherData.weather[0].id {
        case 0...200 :
            brickIconImage.image = UIImage(named: "hot")
        case 200...599 :
            brickIconImage.image = UIImage(named: "rain")
        case 600...699 :
            brickIconImage.image = UIImage(named: "snow")
        case 700...762 :
            brickIconImage.image = UIImage(named: "sunny")
            animationFog()
        case 763...799 :
            brickIconImage.image = UIImage(named: "sunny")
            animationWind()
        case 800...900 :
            brickIconImage.image = UIImage(named: "sunny")
        default:
            brickIconImage.image = UIImage(named: "sunny")
        }
    }
    
    func updateWeatherInfo (latitude: Double, longitude: Double) {
        let session = URLSession.shared
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longitude.description)&appid=8002dd31a0b795746ce7447aa1d18331&lang=ru&units=metric")!
        let task = session.dataTask(with: url) { (data, responce, error) in
            guard error == nil else {
                print("DataTask error \(String(describing: error?.localizedDescription))")
                DispatchQueue.main.async {
                    self.brickIconImage.isHidden = false
                    self.activityIndicator.isHidden = true
                    self.brickIconImage.image = UIImage(named: "rope")
                }
                return
            }
            
            do {
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                DispatchQueue.main.async {
                    self.updateView()
                    self.getAddressFromLatLon(pdblLatitude: latitude, withLongitude: longitude)
                    self.weatherDescriptionLabel.isHidden = false
                    self.tempLabel.isHidden = false
                    self.brickIconImage.isHidden = false
                    self.activityIndicator.isHidden = true
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func startLocationManager () {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        }
    }
    
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double) {
        let ceo: CLGeocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude:pdblLatitude, longitude: pdblLongitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        if (error != nil)
                                        {
                                            print("reverse geodcode fail: \(error!.localizedDescription)")
                                        }
                                        let pm = placemarks! as [CLPlacemark]
                                        if pm.count > 0 {
                                            let pm = placemarks![0]
                                            var addressString: String = " "
                                            if pm.country != nil && pm.locality != nil {
                                                addressString = addressString + pm.country! + ", " + pm.locality! + " "
                                            }
                                            self.cityLabel.attributedText = self.atributedLabel(str: addressString, firstImg: UIImage(named: "icon_location")!, secondImg: UIImage(named: "icon_search")!)
                                            self.cityLabel.isHidden = false
                                        }
                                    })
    }
    
    func atributedLabel(str: String, firstImg: UIImage, secondImg: UIImage)->NSMutableAttributedString {
        let iconsSize = CGRect(x: 0, y: 0, width: 10, height: 10)
        let attributedString = NSMutableAttributedString()
        let firstAttachment = NSTextAttachment()
        let secondAttachment = NSTextAttachment()
        firstAttachment.image = firstImg
        secondAttachment.image = secondImg
        firstAttachment.bounds = iconsSize
        secondAttachment.bounds = iconsSize
        attributedString.append(NSAttributedString(attachment: firstAttachment))
        attributedString.append(NSAttributedString(string: str))
        attributedString.append(NSAttributedString(attachment: secondAttachment))
        return attributedString
    }
    
    func animationWind () {
        UIView.animateKeyframes(withDuration: 3, delay: 0.5, options: [.repeat, .autoreverse], animations: {
            self.brickIconImage.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            self.brickIconImage.transform = CGAffineTransform(rotationAngle: 0.1)
        }, completion: nil)
    }
    
    @objc
    func animationPanGesture (_ panGesture: UIPanGestureRecognizer, latitude: Double, longitude: Double) {
        let oldPosition = panGesture.translation(in: self.view)
        let newPosition =  panGesture.translation(in: self.view)
        let currentX = brickIconImage.center.x
        let currentY = brickIconImage.center.y
        switch panGesture.state{
        case .began:
            brickIconImage.center = CGPoint(x: currentX, y: currentY + newPosition.y)
        case .changed:
            if (currentY + newPosition.y) <= 260 {
                brickIconImage.center = CGPoint(x: currentX, y: currentY + newPosition.y)
            }
        case .ended:
            updateWeatherInfo(latitude: locationManager.location?.coordinate.latitude ?? latitude, longitude: locationManager.location?.coordinate.longitude ?? longitude)
            UIView.animate(withDuration: 1, animations: {
                self.brickIconImage.center = CGPoint(x: currentX, y: oldPosition.y + (self.brickIconImage.bounds.maxY / 2))
            })
        default: break
        }
        panGesture.setTranslation(.zero, in: self.view)
    }
    
    func animationFog () {
        UIView.animateKeyframes(withDuration: 2, delay: 0, options: [.calculationModeLinear], animations: {
            self.brickIconImage.alpha = 0.4
        }, completion: nil)
    }
    
    func infoView() {
        switch state {
        case .close:
            closeInfoView()
        case .open:
            openInfoView ()
        }
    }
    
    func openInfoView () {
        brickIconImage.isHidden = true
        tempLabel.isHidden = true
        cityLabel.isHidden = true
        weatherDescriptionLabel.isHidden = true
        infoButton.isHidden = true
        labelOpenInfo.isHidden = false
        darkLabelInfo.isHidden = false
        layer0.removeFromSuperlayer()
        darkLabelInfo.frame = CGRect(x: 0, y: 0, width: 277, height: 372)
        darkLabelInfo.layer.backgroundColor = UIColor(red: 0.984, green: 0.373, blue: 0.161, alpha: 1).cgColor
        darkLabelInfo.layer.cornerRadius = 15
        let parent = self.view!
        parent.addSubview(darkLabelInfo)
        darkLabelInfo.translatesAutoresizingMaskIntoConstraints = false
        darkLabelInfo.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.75).isActive = true
        darkLabelInfo.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.45).isActive = true
        darkLabelInfo.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 49).isActive = true
        darkLabelInfo.topAnchor.constraint(equalTo: parent.topAnchor, constant: 220).isActive = true
        labelOpenInfo.layer.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0.375, alpha: 1).cgColor
        labelOpenInfo.layer.cornerRadius = 15
        parent.addSubview(labelOpenInfo)
        labelOpenInfo.translatesAutoresizingMaskIntoConstraints = false
        labelOpenInfo.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.73).isActive = true
        labelOpenInfo.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.45).isActive = true
        labelOpenInfo.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 49).isActive = true
        labelOpenInfo.topAnchor.constraint(equalTo: parent.topAnchor, constant: 220).isActive = true
        labelOpenInfo.numberOfLines = 0
        labelOpenInfo.textAlignment = .center
        let boldText  = "INFO:\n\n"
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        labelOpenInfo.font = UIFont(name: "SF Pro Display Light", size: 15)
        let normalText = """
        Brick is wet - raining\n
        Brick is dry - sunny \n
        Brick is hard to see - fog\n
        Brick with cracks - very hot \n
        Brick with snow - snow\n
        Brick is swinging- windy\n
        Brick is gone - no Internet
        """
        let normalString = NSMutableAttributedString(string:normalText)
        attributedString.append(normalString)
        labelOpenInfo.attributedText = attributedString
        state = .close
    }
    
    @objc
    func closeInfoView () {
        brickIconImage.isHidden = false
        tempLabel.isHidden = false
        cityLabel.isHidden = false
        weatherDescriptionLabel.isHidden = false
        infoButton.isHidden = false
        labelOpenInfo.isHidden = true
        darkLabelInfo.isHidden = true
        layer0.colors = [
            UIColor(red: 1, green: 0.6, blue: 0.375, alpha: 1).cgColor,
            UIColor(red: 0.977, green: 0.315, blue: 0.106, alpha: 1).cgColor
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 0.87, c: -0.87, d: 0, tx: 0.94, ty: 0))
        layer0.bounds = infoButton.bounds.insetBy(dx: 0.25*infoButton.bounds.size.width, dy: -0.95*infoButton.bounds.size.height)
        layer0.position = infoButton.center
        layer0.cornerRadius = 10
        infoButton.superview?.layer.addSublayer(layer0)
        let parent = self.view!
        parent.addSubview(infoButton)
        state = .open
    }
    
    @IBAction func tapInfoButton(_ sender: UIButton) {
        infoView()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func  locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            updateWeatherInfo(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        }
    }
}
