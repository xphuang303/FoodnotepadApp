//
//  LocationViewController.swift
//  foodnotepad1
//
//  Created by iOS on 2019/11/3.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager:CLLocationManager = CLLocationManager()
    var food_latitude:Double?
    var food_longitude:Double?
    var annotation:MKPointAnnotation?
    //var foodAnnotation:MKPointAnnotation?
    override func viewDidLoad() {
        super.viewDidLoad()

        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            // 位置更新发生的最大距离
            locationManager.distanceFilter = 100
            let status = CLLocationManager.authorizationStatus()
            // if iOS 8.0+
            if self.locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) && status == CLAuthorizationStatus.notDetermined{
                print("ask for authorization")
                //请求用户同意使用定位服务
                //这是一个异步的方法
                locationManager.requestWhenInUseAuthorization()
            }
            else{
                if food_latitude != nil && food_longitude != nil {
                    //创建食府地址标注
                    let foodLocation = CLLocation(latitude: food_latitude!, longitude: food_longitude!)
                    let foodAnnotation = MKPointAnnotation()
                    foodAnnotation.title = "食府位于："
                    foodAnnotation.subtitle = "北纬：\(foodLocation.coordinate.latitude)，东经：\(foodLocation.coordinate.longitude)"
                    foodAnnotation.coordinate = foodLocation.coordinate
                    //把食府地址标注加上去
                    self.mapView.addAnnotation(foodAnnotation)
                    //显示以新标注为中心的1000米范围的地图
                    let viewRegion = MKCoordinateRegion(center: foodLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    let adjustedRegion = self.mapView.regionThatFits(viewRegion)
                    self.mapView.setRegion(adjustedRegion, animated: true)
                }
                else{
                    //弹出“未包含位置信息的提示”（待实现）
                    print("No Location of store")
                }
                // 启动位置更新服务
                locationManager.startUpdatingLocation()
                //locationManager.allowsBackgroundLocationUpdates = true
                
            }
        }
            // 给用户警告：位置服务不可用
        else{
            //弹出提示信息（待实现）
            print("Location service unavailable")
        }
    }
    //更新位置标注
    func putAnnotation(_ location:CLLocation){
        //删掉原标注
        if self.annotation != nil{
            self.mapView.removeAnnotation(self.annotation!)
            self.annotation = nil
        }
        //创建新的标注
        self.annotation = MKPointAnnotation()
        self.annotation?.title = "您位于："
        self.annotation?.subtitle = "北纬：\(location.coordinate.latitude)，东经：\(location.coordinate.longitude)"
        self.annotation?.coordinate = location.coordinate
        //把新标注加上去
        self.mapView.addAnnotation(self.annotation!)
//        //显示以新标注为中心的1000米范围的地图
//        let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
//        self.mapView.setRegion(adjustedRegion, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK CLLocationManagerDelegate
    //更新位置信息
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //
        let newLocation:CLLocation = locations.last! as CLLocation
        //self.latLabel.text = "\(newLocation.coordinate.latitude)"
        //self.longLabel.text = "\(newLocation.coordinate.longitude)"
        //更新位置标注
        self.putAnnotation(newLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //
        let alerView = UIAlertView(title: "SCNU Campus", message: "您已进入华南师范大学校园", delegate: nil, cancelButtonTitle: "Close")
        alerView.show()
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //
        print("prompt for authorized:status=\(status.rawValue)")
        if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
                print("Region monitoring unavailable")
                return
            }
            else{
                //self.statusLabel.text = "Region monitoring OK"
                let scnu:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:23.138383 , longitude: 113.351204)
                let scnuRegion:CLCircularRegion = CLCircularRegion(center: scnu, radius: 10000, identifier: "SCNU")
                self.locationManager.startMonitoring(for: scnuRegion)
                
            }
            
        }
        else if status == CLAuthorizationStatus.denied{
            print("location service not authorized")
        }
        else{
            print("location service status unkown")
        }
        
    }
    // 本方法若返回 nil，则使用缺省的 MKPinAnnotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
