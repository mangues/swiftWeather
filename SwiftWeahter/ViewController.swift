//
//  ViewController.swift
//  SwiftWeahter
//
//  Created by TTS on 15/8/24.
//  Copyright (c) 2015年 TTS. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate{
    let locationManager:CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self;
        //精确度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if(ios8()){
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func ios8() -> Bool{
        //获取版本号
        var ban:String = UIDevice.currentDevice().systemVersion
        return ban == "8.4"
    }
    //位置改变
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count - 1] as! CLLocation
        if(location.horizontalAccuracy>0){   //表示正确值
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            updateWeatherInfo(location.coordinate.latitude, longitude:location.coordinate.longitude)
            locationManager.stopUpdatingLocation()   //停掉
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    func updateWeatherInfo(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params = ["lat":latitude,"lon":longitude,"cnt":0]
        manager.GET(url, parameters: params, success: { (AFHTTPRequestOperation, responseObject:AnyObject!) -> Void in
            println("JSON:"+responseObject.description!)
        }) { (AFHTTPRequestOperation, error) -> Void in
            println("error:"+error.localizedDescription)
        }
        
        
        
    }

}

