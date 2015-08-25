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

    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var weather: UILabel!
    
    @IBOutlet weak var updateImae: UIActivityIndicatorView!
    
    
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
        self.updateImae.startAnimating()  //启动加载动画
        
        var location:CLLocation = locations[locations.count - 1] as! CLLocation
        if(location.horizontalAccuracy>0){   //表示正确值
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            updateWeatherInfo(location.coordinate.latitude, longitude:location.coordinate.longitude)
            //locationManager.stopUpdatingLocation()   //停掉
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
            self.updateJsonInfo(responseObject as! NSDictionary)
        }) { (AFHTTPRequestOperation, error) -> Void in
            println("error:"+error.localizedDescription)
        }
    }
    
    func updateJsonInfo(jsonResult:NSDictionary!){
        if let tempResult = jsonResult["main"]?["temp"] as? Double{
            var temperature:Double
            if (jsonResult["sys"]?["country"] as? String == "US"){
                temperature = round(((tempResult - 273.15)*1.8) + 32)
            }else{
                temperature = round(tempResult - 273.15)
            }
            
            self.weather.text = "\(temperature)"
            var name:String = jsonResult["name"] as! String
            self.location.text = "\(name)"
            
            var condition = (jsonResult["weather"] as! NSArray)[0]["id"] as! Int
            var sunrise = jsonResult["sys"]?["sunrise"] as! Double
            var sunset = jsonResult["sys"]?["sunset"] as! Double
            
            //判读白天晚上
            var nightTime = false
            //当前时间
            var now = NSDate().timeIntervalSince1970
            if (now < sunrise || now > sunset){
                nightTime = true
            }
            self.updateweatherIcon(condition,nightTime:nightTime);
            
        }//如果任何一个为空 将进入else
        else{
            
        }
    }
    func updateweatherIcon(condition:Int,nightTime:Bool){
        // Thunderstorm
        if (condition < 300) {
            if nightTime {
                callback("tstorm1_night")
            } else {
                callback("tstorm1")
            }
        }
            // Drizzle
        else if (condition < 500) {
            callback("light_rain")
            
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            callback("shower3")
        }
            // Snow
        else if (condition < 700) {
            callback("snow4")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                callback("fog_night")
            } else {
                callback("fog")
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            callback("tstorm3")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                callback("sunny_night")
            }
            else {
                callback("sunny")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                callback("cloudy2_night")
            }
            else{
                callback("cloudy2")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            callback("overcast")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            callback("tstorm3")
        }
            // Cold
        else if (condition == 903) {
            callback("snow5")
        }
            // Hot
        else if (condition == 904) {
            callback("sunny")
        }
            // Weather condition is not available
        else {
            callback("dunno")
        }
    }
    
    func callback(name:String){
        //隐藏加载
        self.updateImae.hidden = true
        self.updateImae.stopAnimating()
       
        self.weatherImage.image = UIImage(named: name)
    }

}

