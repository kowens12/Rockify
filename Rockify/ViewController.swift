//
//  ViewController.swift
//  JamesFrancophile
//
//  Created by Katherine Owens on 11/15/17.
//  Copyright © 2017 Katherine Owens. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let viewModel = RockViewModel()
    let rockView = RockView()
    var rockImages = [UIImage]()
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
        
        setGestureRecognizers()
    }

    @objc func setRocks(notification: Notification) {
        if let rockDictionary = notification.userInfo {
            guard let newRockImage = rockDictionary["newRock"] as? UIImage else { return }
            let newRockImageView = UIImageView(image: newRockImage)

            newRockImageView.isUserInteractionEnabled = true
            newRockImageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handlePan(recognizer:))))
            newRockImageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handlePinch(recognizer:))))
            
            canvas?.addSubview(newRockImageView)
            rockImages.append(newRockImage)
        }
    }

//        - (void)setFranco:(NSNotification *)notification {
//        [self.unFrancoButton setEnabled:YES];
//        });
//        }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x,
                                  y: view.center.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        var transform = recognizer.view?.transform
        recognizer.scale = 1.0
    }
    
    func setGestureRecognizers() {
        userImageView?.isUserInteractionEnabled = true
        rockImageView?.isUserInteractionEnabled = true
        userImageView?.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(viewDidLoad)))
        userImageView?.addGestureRecognizer(UIPinchGestureRecognizer.init(target: self, action: #selector(viewDidLoad)))
    }
    
    // MARK: image rendering
    func renderImage() -> UIImage {
        var contextRect: CGRect
        var contextSize: CGSize
        
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
        }
    
        guard let rockedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        
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
    
    //MARK: Delegate methods
   @IBAction func addPhoto(sender: UIButton) {
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


    
    


