//
//  ViewController.swift
//  ImageRecognitionDemo
//
//  Created by Pankaj on 21/01/19.
//  Copyright © 2019 Canarys Automations Pvt Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var recogLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detectImageContent()

    }
    
    
    func detectImageContent() {
        recogLabel.text = "Searching...."
        
        // 1. Try and load the model
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Failed to load model")
        }
        
        // 2. Create a vision request
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }
            
            // 3. Update the Main UI Thread with our result
            DispatchQueue.main.async { [weak self] in
                self?.recogLabel.text = "\(topResult.identifier) with \(Int(topResult.confidence * 100))% confidence"
            }
        }
        
        if let image = self.imgView.image{
            guard let ciImage = CIImage(image: image) else {
                fatalError("Cant create CIImage from UIImage")
            }
            // 4. Run the googlenetplaces classifier
            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global().async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
        }
        
    }
    
    @IBAction func takePhotoAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func pickImageAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgView.contentMode = .scaleToFill
            imgView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        
        detectImageContent()
    }
    
}

