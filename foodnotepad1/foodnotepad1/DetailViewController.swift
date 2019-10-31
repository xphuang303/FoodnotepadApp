//
//  DetailViewController.swift
//  foodnotepad1
//
//  Created by iOS on 2019/10/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var telephoneField: UITextField!
    @IBOutlet weak var storeField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    
    @IBOutlet weak var foodphoto: UIImageView!
    var foodItem:FoodItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        if foodItem?.name == nil{
            self.title = "添加食物"
        }
        else{
            self.title = foodItem?.name
        }
        configuenameField()
        configuetelephoneField()
        configuestoreField()
        configuecommentField()
        if foodItem?.image1 != nil{
            foodphoto.image = UIImage(data: foodItem!.image1!)
        }
        else if foodItem?.image2 != nil{
            foodphoto.image = UIImage(data: foodItem!.image2!)
        }
        else {
            foodphoto.image = UIImage(named: "Nophoto")
        }
        
    }
    
    @IBAction func photoAction(_ sender: UIButton){
        let vc = UIImagePickerController()
        if sender.tag == 1{
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
    
    func configuenameField() {
        if foodItem?.name != nil{
            nameField.text = foodItem?.name
        }
        nameField.autocorrectionType = .yes
        nameField.returnKeyType = .done
        nameField.clearButtonMode = .never
    }
    func configuetelephoneField() {
        if foodItem?.telephone != nil{
            telephoneField.text = foodItem?.telephone
        }
        telephoneField.autocorrectionType = .yes
        telephoneField.returnKeyType = .done
        telephoneField.clearButtonMode = .never
    }
    func configuestoreField() {
        if foodItem?.store != nil{
            storeField.text = foodItem?.store
        }
        storeField.autocorrectionType = .yes
        storeField.returnKeyType = .done
        storeField.clearButtonMode = .never
    }
    func configuecommentField() {
        if foodItem?.comment != nil{
            commentField.text = foodItem?.comment
        }
        commentField.autocorrectionType = .yes
        commentField.returnKeyType = .done
        commentField.clearButtonMode = .never
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
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
