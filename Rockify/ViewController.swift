//
//  ViewController.swift
//  JamesFrancophile
//
//  Created by Katherine Owens on 11/15/17.
//  Copyright © 2017 Katherine Owens. All rights reserved.
//

import Foundation
import UIKit
import Social

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIToolbarDelegate {
    let viewModel = RockViewModel()
    var rockImages = [UIImageView]()
    var newRockImage = UIImage()
    
    @IBOutlet var userImageView: UIImageView?
    @IBOutlet var rockImageView: UIImageView?
    @IBOutlet var canvas: UIView?
    fileprivate var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setRocks(notification:)),
                                               name: NSNotification.Name(rawValue: "setRockNotification"), object: nil)
        
    }

    @objc func setRocks(notification: Notification) {
        if let rockDictionary = notification.userInfo {
            guard let newRockImage = rockDictionary["newRock"] as? UIImage else { return }
            let newRockImageView = UIImageView(image: newRockImage)
            newRockImageView.image = newRockImage
            newRockImageView.isUserInteractionEnabled = true
            newRockImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:))))
            newRockImageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(recognizer:))))
            canvas?.addSubview(newRockImageView)
            rockImages.append(newRockImageView)
            print("\(rockImages) ROCK IMAGES!!!!!!!!")
            print("\(newRockImageView) ROCK IMAGE VIEW!!!!!!!!")
            print("\(newRockImage) NEW ROCK IMAGE!!!!!!!!")
        }
    }
    
    @IBAction func undoRock(_ sender: Any) {
        self.rockImages.last?.removeFromSuperview()
        self.rockImages.removeLast()
    }
    
    @IBAction func removeAllRocks(_ sender: Any) {
        
    }

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handleRotation(recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    // MARK: image rendering
    
    func renderImage() -> UIImage {
        var contextRect: CGRect
        var contextSize: CGSize
        var rockedImage = UIImage()

        contextRect = userImageView?.image != nil ? CGRect(x: 0,
                                                               y: 0,
                                                               width: userImageView?.frame.size.width ?? 0.0,
                                                               height: userImageView?.frame.size.height ?? 0.0) : self.view.bounds
        contextSize = contextRect.size

        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        
        UIGraphicsGetCurrentContext()
        
        userImageView?.image?.draw(in: contextRect)
        
        if let rockImageView = rockImageView {
            for _ in rockImages {
                self.drawRockImageWithContextSize(contextSize: contextSize, rockImageView: rockImageView)
            }
            
//            for (UIImageView *francoImageView in self.francos) {
//                [self drawFrancoImageWithContextSize:contextSize2 francoImageView:francoImageView];
//            }
        }
    
        rockedImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()

        UIGraphicsEndImageContext()
        
        return rockedImage
    }
    
    func drawRockImageWithContextSize(contextSize: CGSize, rockImageView: UIImageView) {
        guard let rockImageFrameInView = userImageView?.convert(rockImageView.frame, from: rockImageView.superview) else { return }
        guard let userImageViewSize = userImageView?.frame.size else { return }
        let scaleFactor = contextSize.height / userImageViewSize.height
        let scaledRockRect = CGRect(x: rockImageFrameInView.origin.x,
                                    y: rockImageFrameInView.origin.y * scaleFactor,
                                    width: rockImageFrameInView.size.width,
                                    height: rockImageFrameInView.size.height * scaleFactor)
        
        rockImageView.image?.draw(in: scaledRockRect)
    }
    
    func createShareAlert() -> UIActivityViewController {
        let activityItems = renderImage()
        let shareVC = UIActivityViewController(activityItems: [activityItems], applicationActivities: nil)
        return shareVC
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let shareVC = self.createShareAlert()
       
        shareVC.popoverPresentationController?.sourceView = sender as? UIView
        self.present(shareVC, animated: true, completion: nil)
    }
    
    //MARK: Delegate methods
    @IBAction func addPhotosenderUIButton(_ sender: Any) {
        if viewModel.isCameraAndLibraryAvailable {
            createAlertForSourceType(sourceType: .camera)
            createAlertForSourceType(sourceType: .photoLibrary)
        } else if viewModel.isCameraAvailable {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else if viewModel.isLibraryAvailable {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            createErrorAlert()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        guard let width = chosenImage?.size.width else { return }
        guard let height = chosenImage?.size.height else { return }
        let aspectRatioConstraint = NSLayoutConstraint(item: userImageView as Any,
                                                       attribute: .width,
                                                       relatedBy: .equal,
                                                       toItem: userImageView,
                                                       attribute: .width,
                                                       multiplier: width / height,
                                                       constant: 0)
        
        userImageView?.image = chosenImage
        aspectRatioConstraint.isActive = true
        userImageView?.setNeedsLayout()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(title: String,
                   message: String,
                   preferredStyle: UIAlertControllerStyle) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: preferredStyle)
        return alert
    }
    
    func makeAction(title: String,
                    style: UIAlertActionStyle,
                    handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        let action = UIAlertAction(title: title,
                                   style: style,
                                   handler: handler)
        return action
    }

    
    func createAlertForSourceType(sourceType: UIImagePickerControllerSourceType) {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        
        let alert = makeAlert(title: "Add a Photo",
                              message: "Add a photo to Rockify",
                              preferredStyle: .actionSheet)
        switch imagePicker.sourceType {
        case .camera:
            alert.addAction(makeAction(title: "Take a Photo",
                                       style: .default,
                                       handler: { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
        case .photoLibrary:
            alert.addAction(makeAction(title: "Add from Library",
                                       style: .default,
                                       handler: { _ in
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
              //  self.present(self.imagePicker, animated: true, completion: nil)
            }))
        default:
            return
        }
        self.present(alert, animated: true, completion: nil)
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func createErrorAlert() {
        let alert = makeAlert(title: "Unable to Add Photo",
                  message: "Unable to access camera or photo library, check your privacy settings",
                  preferredStyle: .alert)
        alert.addAction(makeAction(title: "Ok", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

    
    


