//
//  RockCollectionViewController.swift
//  JamesFrancophile
//
//  Created by Katherine Owens on 11/15/17.
//  Copyright © 2017 Katherine Owens. All rights reserved.
//

import UIKit
import Foundation

class RockCollectionViewController: UICollectionViewController {
    fileprivate let reuseIdentifier = "RockCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var rockPhotos: [UIImage?] = []
    var selectedRock: UIImage? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rockPhotos = [UIImage(named: "rock1"), UIImage(named: "rock2")]
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rockPhotos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RockCollectionViewCell
        let rockImage = rockPhotos[indexPath.row]
        cell.imageView.image = rockImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var rockDictionary: [AnyHashable: Any] = [:]
        guard let selectedRock = rockPhotos[indexPath.row] else { return }
        rockDictionary = ["newRock": selectedRock]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rockNotification"), object: nil, userInfo: rockDictionary)
        self.navigationController?.popToRootViewController(animated: true)
    }
}
