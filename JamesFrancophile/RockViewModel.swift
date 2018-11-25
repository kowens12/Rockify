//
//  RockViewModel.swift
//  JamesFrancophile
//
//  Created by Katherine Owens on 11/8/18.
//  Copyright © 2018 Katherine Owens. All rights reserved.
//

import Foundation
import UIKit

class RockViewModel {
   
    var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    var isLibraryAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    var isCameraAndLibraryAvailable: Bool {
       return isLibraryAvailable && isCameraAvailable
    }
}
