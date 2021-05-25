//
//  AssetCollectionViewController.swift
//  MyAlbum
//
//  Created by 장주명 on 2021/01/22.
//

import UIKit
import Photos

class AssetCollectionViewController: UIViewController {
    
    
    
    @IBOutlet weak var AssetCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewSortedStatus: UIBarButtonItem!
    @IBOutlet weak var selectStatus: UIBarButtonItem!
    @IBOutlet weak var activityViewStatus: UIBarButtonItem!
    @IBOutlet weak var deleteStatus: UIBarButtonItem!
    @IBOutlet weak var fetchOptionStatus: UIBarButtonItem!
    
    var album : PHAssetCollection?
    var fetchReuslt : PHFetchResult<PHAsset>?
    var dictionarySelectedIndexPath : [IndexPath : Bool] = [:]
    var selectedAssetCellIndexPath : [IndexPath] = []
    let imgManger : PHCachingImageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBarButtonItem()
        AssetCollectionView.dataSource = self
        AssetCollectionView.delegate = self
        
        navigationItem.title = "\(album?.localizedTitle ?? "UnKnown")"
        self.navigationItem.largeTitleDisplayMode = .never
        
        PHPhotoLibrary.shared().register(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AssetViewController" {
            let vc = segue.destination as! AssetViewController
            if let index = sender as? Int {
                if let asset : PHAsset = fetchReuslt?.object(at: index) {
                    vc.asset = asset
                }
                
            }
        }
    }
    
    func sortedAlbum(_ status: Bool) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: status)]
        if let sortedAblum = album {
            self.fetchReuslt = PHAsset.fetchAssets(in: sortedAblum, options: fetchOptions)
        }
    }
    
    
    @IBAction func collectionVeiwSorted(_ sender: UIBarButtonItem) {
        
        if collectionViewSortedStatus.title == "최신 순서" {
            collectionViewSortedStatus.title = "과거 순서"
            sortedAlbum(false)
            AssetCollectionView.reloadData()
        } else {
            collectionViewSortedStatus.title = "최신 순서"
            sortedAlbum(true)
            AssetCollectionView.reloadData()
        }
    }
    @IBAction func selectModeAction(_ sender: Any) {
        
        if selectStatus.title == "Select"{
            navigationItem.setHidesBackButton(true, animated: false)
            navigationItem.title = "Select Photos"
            selectStatus.title = "Cancel"
            AssetCollectionView.allowsMultipleSelection = true
        } else {
            for (key, value) in dictionarySelectedIndexPath {
                if value {
                    AssetCollectionView.deselectItem(at: key, animated: true)
                }
            }
            dictionarySelectedIndexPath.removeAll()
            navigationItem.setHidesBackButton(false, animated: false)
            navigationItem.title = "\(album?.localizedTitle ?? "UnKnown")"
            selectStatus.title = "Select"
            AssetCollectionView.allowsMultipleSelection = false
        }
    }
    @IBAction func deleteBtnAction(_ sender: Any) {
        for (key, value) in dictionarySelectedIndexPath {
            if value {
                selectedAssetCellIndexPath.append(key)
            }
        }
        
        let assetArray : NSMutableArray = NSMutableArray()
        
        for i in selectedAssetCellIndexPath.sorted(by: { $0.item > $1.item}) {
            guard let asset : PHAsset = self.fetchReuslt?.object(at: i.item) else { return }
            assetArray.addObjects(from: [asset])
            }
    
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets(assetArray)}, completionHandler: nil)
        AssetCollectionView.deleteItems(at: selectedAssetCellIndexPath)
        
        dictionarySelectedIndexPath.removeAll()
    }
    
    @IBAction func activityViewBtnAction(_ sender: Any) {
        for (key, value) in dictionarySelectedIndexPath {
            if value {
                selectedAssetCellIndexPath.append(key)
            }
        }
        var imgArray : [UIImage?] = []
        for i in selectedAssetCellIndexPath.sorted(by: { $0.item > $1.item}) {
            guard let asset : PHAsset = self.fetchReuslt?.object(at: i.item) else { return }
            imgManger.requestImage(for: asset, targetSize: CGSize(width: 30, height: 30), contentMode: .aspectFill, options: nil,
                                   resultHandler: { img, _ in
                                    imgArray.append(img)
                                   })
            }
        
        let activityVC = UIActivityViewController(activityItems: imgArray as [Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        selectedAssetCellIndexPath.removeAll()
    }
    
    
    
    func setupBarButtonItem() {
        deleteStatus.isEnabled = false
        activityViewStatus.isEnabled = false
    }
    
    
}

extension AssetCollectionViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchReuslt?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionCell", for: indexPath) as? AssetCollectionCell else { return UICollectionViewCell()}
        
        if let asset : PHAsset = fetchReuslt?.object(at: indexPath.item) {
            let width = collectionView.frame.width / 3 - 5
            let height = width
            
            imgManger.requestImage(for: asset, targetSize: CGSize(width: width, height: height), contentMode: .aspectFill, options: nil,
                                   resultHandler: { img, _ in
                                    cell.assetCollecionImg.image = img
                                   })
        }
        cell.isSelectView.isHidden = true
        return cell
    }
    
    
}

extension AssetCollectionViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectStatus.title == "Cancel"{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionCell", for: indexPath) as? AssetCollectionCell {
                if cell.isSelected == true {
                    deleteStatus.isEnabled = true
                    activityViewStatus.isEnabled = true
                    dictionarySelectedIndexPath[indexPath] = true
                    if dictionarySelectedIndexPath.count == 1 {
                        navigationItem.title = "Select \(dictionarySelectedIndexPath.count) Photo"
                    } else if dictionarySelectedIndexPath.count > 1 {
                        navigationItem.title = "Select \(dictionarySelectedIndexPath.count) Photos"
                    }
                }
            }
        } else {
            AssetCollectionView.deselectItem(at: indexPath, animated: true)
            performSegue(withIdentifier: "AssetViewController", sender: indexPath.item)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectStatus.title == "Cancel"{
            if dictionarySelectedIndexPath[indexPath] == true {
                dictionarySelectedIndexPath[indexPath] = nil
                if dictionarySelectedIndexPath.count == 0 {
                    deleteStatus.isEnabled = false
                    activityViewStatus.isEnabled = false
                    navigationItem.title = "Select Photos"
                }
                if dictionarySelectedIndexPath.count == 1 {
                    navigationItem.title = "Select \(dictionarySelectedIndexPath.count) Photo"
                } else if dictionarySelectedIndexPath.count > 1 {
                    navigationItem.title = "Select \(dictionarySelectedIndexPath.count) Photos"
                }
            }
            print(dictionarySelectedIndexPath)
            print(dictionarySelectedIndexPath.count)
        }
    }
    

}



extension AssetCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 3 - 5
        let height = width
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension AssetCollectionViewController : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fethchReusltObserve = fetchReuslt else { return }
        guard let changes = changeInstance.changeDetails(for: fethchReusltObserve) else { return }
        
        fetchReuslt = changes.fetchResultAfterChanges
        OperationQueue.main.addOperation {
            self.AssetCollectionView.reloadSections(IndexSet(0...0))
        }
        
        
    }
    
    
}

class AssetCollectionCell : UICollectionViewCell {
    @IBOutlet weak var assetCollecionImg: UIImageView!
    @IBOutlet weak var isSelectView: UIView!
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                isSelectView.isHidden = false
                isSelectView.layer.borderWidth = 5
                isSelectView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            else {
                isSelectView.isHidden = true
                
            }
        }
    }
    
    
}
