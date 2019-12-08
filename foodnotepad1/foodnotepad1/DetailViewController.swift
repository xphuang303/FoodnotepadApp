//
//  DetailViewController.swift
//  foodnotepad1
//
//  Created by iOS on 2019/10/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {


    var foodItem:FoodItem?
    var latitude:Double?
    var longitude:Double?
    var locationViewController:LocationViewController?
    var locationManager:CLLocationManager = CLLocationManager()
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var telephoneField: UITextField!
    @IBOutlet weak var storeField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var foodphoto: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if foodItem?.name == nil {
            self.title = "添加食物"
        }
        else {
            self.title = foodItem?.name
        }
        configuenameField()
        configuetelephoneField()
        configuestoreField()
        configuecommentField()
        if foodItem?.image1 != nil {
            foodphoto.image = UIImage(data: (foodItem?.image1!)!)
        }
        else if foodItem?.image2 != nil {
            foodphoto.image = UIImage(data: (foodItem?.image2!)!)
        }
        else{
            foodphoto.image = UIImage(named: "Nophoto")
        }
        
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
                // 启动位置更新服务
                locationManager.startUpdatingLocation()
                //locationManager.allowsBackgroundLocationUpdates = true
            }
        }
        //给用户警告：位置服务不可用
        else{
            print("Location service unavailable")
        }
    }
    
    @IBAction func photoAction(_ sender: UIButton){
        let vc = UIImagePickerController()
        if sender.tag == 1 {
            vc.sourceType = .camera
            vc.mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera)!
        }
        else if sender.tag == 2 {
            vc.sourceType = .photoLibrary
        }
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker.sourceType == .camera {
            guard let image = info[.editedImage] as? UIImage else {
                print("No image found")
                return
            }
            foodphoto.image = image
            // Save the image to Photo library
            UIImageWriteToSavedPhotosAlbum(image, nil, nil , nil)
            //记录拍照地点的位置信息
            foodItem?.latitude = self.latitude!
            foodItem?.longitude = self.longitude!
            picker.dismiss(animated: true)
        }
        else if picker.sourceType == .photoLibrary {
            if let possibleImage = info[.editedImage] as? UIImage {
                foodphoto.image = possibleImage
            } else if let possibleImage = info[.originalImage] as? UIImage {
                foodphoto.image = possibleImage
            } else {
                return
            }
            dismiss(animated: true)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
//    //记录位置信息
//    func recordLocation() {
//        if CLLocationManager.locationServicesEnabled(){
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            // 位置更新发生的最大距离
//            locationManager.distanceFilter = 100
//            let status = CLLocationManager.authorizationStatus()
//            // if iOS 8.0+
//            if self.locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) && status == CLAuthorizationStatus.notDetermined{
//                print("ask for authorization")
//                locationManager.requestWhenInUseAuthorization()
//            }
//            else{
//                // 启动位置更新服务
//                locationManager.startUpdatingLocation()
//                //locationManager.allowsBackgroundLocationUpdates = true
//            }
//        }
//            // 给用户警告：位置服务不可用
//        else{
//            print("Location service unavailable")
//        }
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //更新位置信息时调用此方法，传进来的数据时一个数组，最后一个元素是最新的位置信息
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation:CLLocation = locations.last! as CLLocation
        self.latitude = newLocation.coordinate.latitude
        self.longitude = newLocation.coordinate.longitude
//        let geoCoder = CLGeocoder()
//        //        geoCoder.geocodeAddressString("广州市 华南师范大学") { (pMarks, error) in
//        //
//        //        }
//        geoCoder.reverseGeocodeLocation(locations.last!) { (placeMarks:[CLPlacemark]?, error:Error?) -> Void in
//            if let pMarks = placeMarks , pMarks.count>0{
//                let pMark = pMarks[0]
//                //                let addressDictionary = pMark.addressDictionary
//                self.addressLabel.text = pMark.name! + ", " + pMark.administrativeArea!
//
//                print("Name=\(String(describing: pMark.name)),area=\(String(describing: pMark.administrativeArea))")
//            }
//        }
    }
    //请求用户同意定位服务时，用户做选择后会调用此方法
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            
        }
        else if status == .denied{
            print("location service unavailable")
        }
    }
    // 如果用户拒绝本程序使用位置服务，下次运行可在此处理
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).code == CLError.denied.rawValue{
            print("用户拒绝了本应用的位置服务")
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    
    
    func configuenameField() {
        
        nameField.placeholder = NSLocalizedString("在此输入美食名称", comment: "")
        nameField.text = foodItem?.name
        nameField.autocorrectionType = .yes
        nameField.returnKeyType = .done
        nameField.clearButtonMode = .always
    }
    func configuetelephoneField() {
        
        telephoneField.placeholder = NSLocalizedString("在此输入电话号码", comment: "")
        telephoneField.text = foodItem?.telephone
        telephoneField.autocorrectionType = .yes
        telephoneField.returnKeyType = .done
        telephoneField.clearButtonMode = .always
    }
    func configuestoreField() {
        
        storeField.placeholder = NSLocalizedString("在此输入食府名称", comment: "")
        storeField.text = foodItem?.store
        storeField.autocorrectionType = .yes
        storeField.returnKeyType = .done
        storeField.clearButtonMode = .always
    }
    func configuecommentField() {
        
        commentField.placeholder = NSLocalizedString("在此输入美食评论", comment: "")
        commentField.text = foodItem?.comment
        commentField.autocorrectionType = .yes
        commentField.returnKeyType = .done
        commentField.clearButtonMode = .always
    }
    //点击return 收回键盘（没有成功）
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //点击其他地方 收回键盘
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameField.resignFirstResponder()
        telephoneField.resignFirstResponder()
        storeField.resignFirstResponder()
        commentField.resignFirstResponder()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        self.locationViewController = segue.destination as? LocationViewController
        locationViewController?.food_latitude = self.foodItem?.latitude
        locationViewController?.food_longitude = self.foodItem?.longitude
        locationViewController?.new_latitude = self.latitude
        locationViewController?.new_longitude = self.longitude
    }
}
