//
//  CameraViewController.swift
//  ParseChat
//
//  Created by Kay Lab on 5/8/19.
//  Copyright © 2019 Darrel Muonekwu. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var submitImageButton: UIButton!
    @IBOutlet weak var toCameraButton: UIButton!
    @IBOutlet weak var toPhotoLibrary: UIButton!
    @IBOutlet var imageOptions: [UIButton]!
    
    var buttonAreHidden = true
    override func viewDidLoad() {
        super.viewDidLoad()
        submitImageButton.layer.cornerRadius = 15
        toCameraButton.layer.cornerRadius = 15
        toPhotoLibrary.layer.cornerRadius = 15
        
    }
    
    @IBAction func onCameraButton(_ sender: UITapGestureRecognizer) {
        if buttonAreHidden {
            imageOptions.forEach { (button: UIButton) in
                UIView.animate(withDuration: 0.3, animations: {
                    button.isHidden = false
                    self.buttonAreHidden = false
                    self.view.layoutIfNeeded()
                })

            }
        } else {
            imageOptions.forEach { (button: UIButton) in
                UIView.animate(withDuration: 0.3, animations: {
                    button.isHidden = true
                    self.buttonAreHidden = true
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // returns a HUGE image -> like 10mb
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        photoView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmitButton(_ sender: UIButton) {
        let post = PFObject(className: "Posts")
        
        post["author"] = PFUser.current()!
        post["caption"] = commentField.text!
        
        let imageData = photoView.image!.pngData()
        let file = PFFileObject(data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground { (success: Bool, error: Error?) in
            if success {
                print("Image saved")
                self.dismiss(animated: true , completion: nil)
            } else {
                print("Could not save image to Parse")
            }
        }
    }
    @IBAction func toCamera(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            // open up the camera
        picker.sourceType = .camera
        
        present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func toPhotoLibrary(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        // open photo library
        picker.sourceType = .photoLibrary

        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func returnToFeed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true , completion: nil)
    }
    // NEXT TWO FUNCTIONS DISMISS THE KEY BOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentField.resignFirstResponder()
        return true
    }
}
