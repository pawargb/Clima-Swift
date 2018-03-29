//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegte {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    var whetherDataModelObj = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWhetherData(url: String, parameters: [String:String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                //self.cityLabel.text = "Sucess"
                
                let whetherJSON: JSON = JSON(response.result.value!)
                
                self.udpateWhetherData(json: whetherJSON)
                
                //print(whetherJSON)
                
            }
            else{
                self.cityLabel.text = "Connection issue"
            }
        }
        
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func udpateWhetherData(json: JSON){
        
        if let tempResult = json["main"]["temp"].double{
        
            whetherDataModelObj.temperature = Int(tempResult - 273.15)
            
            whetherDataModelObj.city = json["name"].stringValue
            
            whetherDataModelObj.condition = json["whether"][0]["id"].intValue
            
            whetherDataModelObj.whetherIconName = whetherDataModelObj.updateWeatherIcon(condition: whetherDataModelObj.condition)
            
            updateUIWithWhetherData()
        }
        else{
            cityLabel.text = "Whether unavailable"
        }
    }

    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWhetherData(){
        cityLabel.text = whetherDataModelObj.city
        temperatureLabel.text = "\(whetherDataModelObj.temperature)"
        weatherIcon.image = UIImage(named : whetherDataModelObj.whetherIconName)
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    //this method gets activated once locationManager gets location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       // print("locationManager success Method called")
        
        cityLabel.text = "Location captured"
        
        let location = locations[locations.count - 1]
        
        //print("Count : ",locations.count)
        
        if location.horizontalAccuracy > 0{
        
            locationManager.stopUpdatingLocation()
            locationManager.delegate=nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            //print("Latitude : \(lat), Longitiude : \(long)")
            
            let params = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWhetherData(url: WEATHER_URL, parameters: params)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("locationManager error Method called")

        print(error)
        
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        
        let params: [String : String] = ["q" : city, "appid" : APP_ID]
        getWhetherData(url: WEATHER_URL, parameters: params)
        
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
        
    }
    
    
    
}


