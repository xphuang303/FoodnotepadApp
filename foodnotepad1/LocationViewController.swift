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

let a = 6378245.0
let ee = 0.00669342162296594323
let x_pi = 3.14159265358979324 * 3000.0 / 180.0

class LocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    //创建一个位置服务管理器对象locationManager，无参数初始化
    var locationManager:CLLocationManager = CLLocationManager()
    var food_latitude:Double?
    var food_longitude:Double?
    var annotation:MKPointAnnotation?
    var newLocation=CLLocation()
    var foodLocation=CLLocation()
    let geocoder = CLGeocoder()
    //var foodAnnotation:MKPointAnnotation?
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        //判断位置服务是否可用（类方法）
        if CLLocationManager.locationServicesEnabled(){
            //位置服务可用
            //设置位置服务管理器对象locationManager的属性，如委托、更新位置信息的频度
            locationManager.delegate = self  //委托对象
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            // 位置更新发生的最大距离
            locationManager.distanceFilter = 100
            let status = CLLocationManager.authorizationStatus()     //获取状态
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
                    self.foodLocation = self.transform(location: CLLocation(latitude: food_latitude!, longitude: food_longitude!))!
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
    //更新位置信息时调用此方法，传进来的数据时一个数组，最后一个元素是最新的位置信息
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //
        self.newLocation = self.transform(location: locations.last! as CLLocation)!
        //self.latLabel.text = "\(newLocation.coordinate.latitude)"
        //self.longLabel.text = "\(newLocation.coordinate.longitude)"
        //更新位置标注
        self.putAnnotation(newLocation)
        drawRoute(sourceLocation: self.newLocation, destinationLocation: self.foodLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //
        let alerView = UIAlertView(title: "SCNU Campus", message: "您已进入华南师范大学校园", delegate: nil, cancelButtonTitle: "Close")
        alerView.show()
        
    }
    //请求用户同意定位服务时，用户做选择后会调用此方法
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //
        print("prompt for authorized:status=\(status.rawValue)")
        //此两种情况之一都可以
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
    
    func transform(location: CLLocation) -> CLLocation?
    {
        if outOfChina(loc:location){
            return location
        }
        let wgLon = location.coordinate.longitude
        let wgLat = location.coordinate.latitude
        var dLat = transformLat(wgLon - 105.0, wgLat - 35.0)
        var dLon = transformLon(wgLon - 105.0, wgLat - 35.0)
        let radLat = wgLat / 180.0 * Double.pi
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * Double.pi)
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * Double.pi)
        let mgLat = wgLat + dLat
        let mgLon = wgLon + dLon
        return CLLocation(latitude: mgLat, longitude: mgLon)
    }
    func transformLat(_ x:Double,_ y:Double) -> Double
    {
        
        var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
        ret += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
        ret += (20.0 * sin(y * Double.pi) + 40.0 * sin(y / 3.0 * Double.pi)) * 2.0 / 3.0
        ret += (160.0 * sin(y / 12.0 * Double.pi) + 320 * sin(y * Double.pi / 30.0)) * 2.0 / 3.0
        return ret
    }
    func transformLon(_ x:Double,_ y:Double) -> Double
    {
        var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
        ret += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
        ret += (20.0 * sin(x * Double.pi) + 40.0 * sin(x / 3.0 * Double.pi)) * 2.0 / 3.0
        ret += (150.0 * sin(x / 12.0 * Double.pi) + 300.0 * sin(x / 30.0 * Double.pi)) * 2.0 / 3.0
        return ret
    }
    // if the coordinate is located in China
    func outOfChina(loc:CLLocation) -> Bool
    {
        if loc.coordinate.longitude < 72.004 || loc.coordinate.longitude > 137.8347{
            return true
        }
        if loc.coordinate.latitude < 0.8293 || loc.coordinate.latitude > 55.8271{
            return true
        }
        return false
    }
    // convert GCJ02 coordinate system to BD09 coordinate system
    func GCJ02ToBD09(location: CLLocation) -> CLLocation
    {
        let x = location.coordinate.longitude
        let y = location.coordinate.latitude
        let z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi)
        let theta = atan2(y, x) + 0.000003 * cos(x * x_pi)
        let bd_lon = z * cos(theta) + 0.0065
        let bd_lat = z * sin(theta) + 0.006
        return CLLocation(latitude: bd_lat, longitude: bd_lon)
    }
    // convert BD09 coordinate system to GCJ02 coordinate system
    func BD09ToGCJ02(location: CLLocation) -> CLLocation
    {
        let x = location.coordinate.longitude - 0.0065
        let y = location.coordinate.latitude - 0.006
        let z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi)
        let theta = atan2(y, x) - 0.000003 * cos(x * x_pi)
        let gg_lon = z * cos(theta)
        let gg_lat = z * sin(theta)
        return CLLocation(latitude: gg_lat, longitude: gg_lon)
    }
    

    func drawRoute(sourceLocation: CLLocation,destinationLocation: CLLocation){
//        geocoder.reverseGeocodeLocation(sourceLocation, completionHandler: {
//            (placemarks:[AnyObject]?, error:NSError?) -> Void in
//            if placemarks?.count > 0 {
//                if let placemark: MKPlacemark = placemarks![0] as? MKPlacemark {
//                    self.newMapItem =  MKMapItem(placemark: placemark)
//                }
//            }
//        })
//        geocoder.reverseGeocodeLocation(destinationLocation, completionHandler: {
//            (placemarks:[AnyObject]?, error:NSError?) -> Void in
//            if placemarks?.count > 0 {
//                if let placemark: MKPlacemark = placemarks![0] as? MKPlacemark {
//                    self.foodMapItem =  MKMapItem(placemark: placemark)
//                }
//            }
//        })
        let newCoordinate = CLLocationCoordinate2D(latitude: self.newLocation.coordinate.latitude, longitude: self.newLocation.coordinate.longitude)
        
        let foodCoordinate = CLLocationCoordinate2D(latitude: self.foodLocation.coordinate.latitude, longitude: self.foodLocation.coordinate.longitude)
        
        let newPlaceMark = MKPlacemark(coordinate: newCoordinate, addressDictionary: nil)
        
        let foodPlaceMark = MKPlacemark(coordinate: foodCoordinate, addressDictionary: nil)
        
        let newItem = MKMapItem(placemark: newPlaceMark)
        
        let foodItem = MKMapItem(placemark: foodPlaceMark)
        
        
        let request:MKDirections.Request = MKDirections.Request()
        // source and destination are the relevant MKMapItems
        request.source = newItem
        request.destination = foodItem
        
        // Specify the transportation type
        request.transportType = MKDirectionsTransportType.automobile
        
        // If you're open to getting more than one route,
        // requestsAlternateRoutes = true; else requestsAlternateRoutes = false;
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
//        mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
//    func showRoute(response:MKDirections.Response) {
//
//
//
//        for route in response.routes {
//
//            mapView.addOverlay(route.polyline,level: MKOverlayLevel.aboveRoads)
//
//            let routeSeconds = route.expectedTravelTime
//
//            let routeDistance = route.distance
//
//            print("distance between two points is \(routeSeconds) and \(routeDistance)")
//
//        }
//
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
