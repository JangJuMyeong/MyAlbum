//
//  ViewController.swift
//  MyAlbum
//
//  Created by 장주명 on 2021/01/22.
//

import UIKit
import Photos

class CollectionListViewController: UIViewController {
    

    @IBOutlet weak var collectionListView: UICollectionView!
    
    var allPhotos = PHFetchResult<PHAssetCollection>()
    var userCollections = PHFetchResult<PHAssetCollection>()
    var fetchReuslt : PHFetchResult<PHAsset>!
    let imgManger : PHCachingImageManager = PHCachingImageManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.title = "album"
        collectionListView.dataSource = self
        collectionListView.delegate = self
        
            
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        
        switch photoAuthorizationStatus {
        case .authorized : // 권한을 부여받음
            print("접근 허가됨")
            OperationQueue.main.addOperation {
                self.collectionListView.reloadData()
            }
        case .denied : // 거부됨
            print("접근 불허")
        case .notDetermined : // 응답하지않음
            print("응답하지 않음")
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized :
                    print("접근 허가됨")
                    OperationQueue.main.addOperation {
                        self.collectionListView.reloadData()
                    }
                case .denied :
                    print("접근 불허")
                default :
                    break
                }
            })
            
        case .restricted : // 제한
            print("접근 제한")
        default : break
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.largeTitleDisplayMode = .always
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AssetCollectionViewController" {
            let vc = segue.destination as! AssetCollectionViewController
            if let index = sender as? Int {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                requestCollection()
                if index < allPhotos.count {
                    let collectionItem = allPhotos[index]
                    let fetchedAssets = PHAsset.fetchAssets(in: collectionItem, options: fetchOptions)
                    vc.fetchReuslt = fetchedAssets
                    vc.album = collectionItem
                    
                } else {
                    let collectionItem = userCollections[index - allPhotos.count]
                    let fetchedAssets = PHAsset.fetchAssets(in: collectionItem, options: fetchOptions)
                    vc.fetchReuslt = fetchedAssets
                    vc.album = collectionItem
                }
                
            }
        }
    }
    
    func requestCollection() {
        userCollections = PHAssetCollection.fetchAssetCollections( with: .album, subtype: .albumRegular , options: nil)
        allPhotos = PHAssetCollection.fetchAssetCollections( with: .smartAlbum, subtype: .smartAlbumUserLibrary , options: nil)
    }
    
}

extension CollectionListViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        requestCollection()
        let numOfItem = userCollections.count + allPhotos.count
        return numOfItem
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell()}
        
        
        var coverAsset: PHAsset?
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        requestCollection()
        
        if indexPath.item < allPhotos.count {
            let fetchedAssets = PHAsset.fetchAssets(in: allPhotos[indexPath.item], options: fetchOptions)
            coverAsset = fetchedAssets.firstObject
            if let asset = coverAsset {
                imgManger.requestImage(for: asset , targetSize: CGSize(width: cell.bounds.width , height: cell.bounds.height - 50), contentMode: .aspectFill, options: nil, resultHandler: { img, _ in
                    cell.collectionListCoverImg.image = img
                })
            }

            cell.update(title: allPhotos[indexPath.item].localizedTitle, count: fetchedAssets.count)
        } else {
            let fetchedAssets = PHAsset.fetchAssets(in: userCollections[indexPath.item - allPhotos.count], options: fetchOptions)
            coverAsset = fetchedAssets.firstObject
            if let asset = coverAsset {
                imgManger.requestImage(for: asset , targetSize: CGSize(width: cell.bounds.width , height: cell.bounds.height - 50), contentMode: .aspectFill, options: nil, resultHandler: { img, _ in
                    cell.collectionListCoverImg.image = img
                })
            }
            
            cell.update(title: userCollections[indexPath.item - allPhotos.count].localizedTitle, count: fetchedAssets.count)
        }
        
        
        
        return cell
    }
    
    
}

extension CollectionListViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AssetCollectionViewController", sender: indexPath.item)
    }
    
    
}

extension CollectionListViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let itemSpacing : CGFloat = 10 // 각 아이템끼리의 간격
        let margin : CGFloat = 10 // 각 좌우의 마진값
        let width = (collectionView.bounds.width - itemSpacing - margin * 2) / 2
        let height = width + 50
        
        return CGSize(width: width, height: height)
    }
}

class CollectionViewCell : UICollectionViewCell {
    
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var collectionListCoverImg: UIImageView!
    
    func update(title: String?, count: Int) {
        albumLabel.text = title
        countLabel.text = "\(count.description)"
    }
}

