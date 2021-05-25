//
//  AssetViewController.swift
//  MyAlbum
//
//  Created by 장주명 on 2021/01/22.
//

import UIKit
import Photos


class AssetViewController: UIViewController {
    
    
    var asset : PHAsset!
    let imgManger : PHCachingImageManager = PHCachingImageManager()
    
    @IBOutlet weak var assetView: UIView!
    @IBOutlet weak var assetImgView: UIImageView!
    @IBOutlet weak var faveriteBtnStatus: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingAssetImg()
        initTitle()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchAssetImgView))
        assetImgView.addGestureRecognizer(tapGesture)
        assetImgView.isUserInteractionEnabled = true
        if asset.isFavorite == true {
            faveriteBtnStatus.image = UIImage(systemName: "heart.fill")
        } else {
            faveriteBtnStatus.image = UIImage(systemName: "heart")
        }
        
    }
    
    
    @IBAction func favoriteBtn(_ sender: UIBarButtonItem) {
        
        let changeHandler: () -> Void = {
            let request = PHAssetChangeRequest(for: self.asset)
            request.isFavorite = !self.asset.isFavorite
        }
        
        PHPhotoLibrary.shared().performChanges(changeHandler, completionHandler: nil)
        
        guard let fillImg = UIImage(systemName: "heart.fill") else { return }
        guard let img = UIImage(systemName: "heart") else { return }
        
        if faveriteBtnStatus.image == fillImg {
            faveriteBtnStatus.image = img
        } else {
            faveriteBtnStatus.image = fillImg
        }
        
    }
    
    @IBAction func deleteBtnAction(_ sender: UIBarButtonItem) {
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets([self.asset] as NSFastEnumeration)}, completionHandler: {isDelete,_ in
            if isDelete == true {
                OperationQueue.main.addOperation {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    @IBAction func activityViewBtnAction(_ sender: Any) {
        var imgArray : [UIImage?] = []
        imgManger.requestImage(for: asset, targetSize: CGSize(width: assetImgView.frame.width, height: assetImgView.frame.height), contentMode: .aspectFill, options: nil, resultHandler: { img, _ in imgArray.append(img) })
        let activityVC = UIActivityViewController(activityItems: imgArray as [Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func touchAssetImgView() {
        if navigationController?.navigationBar.isHidden == true {
            navigationController?.navigationBar.isHidden = false
            navigationController?.toolbar.isHidden = false
        } else {
            navigationController?.navigationBar.isHidden = true
            navigationController?.toolbar.isHidden = true
        }
    }
    
    func initTitle() {
        let dateFormatter = DateFormatter()
        let seccondDateFormatter = DateFormatter()
        var creatDateString : String?
        var creatSeccondString : String?
        dateFormatter.dateFormat = "yyyy-MM-dd"
        seccondDateFormatter.dateFormat = "a HH:mm:ss"
        if let creatDate = asset?.creationDate, let creatSeccond = asset?.creationDate {
            creatDateString = dateFormatter.string(from: creatDate)
            creatSeccondString = seccondDateFormatter.string(from: creatSeccond)
            
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 36))
            
            let topTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 18))
            topTitle.numberOfLines = 1
            topTitle.textAlignment = .center
            topTitle.font = .systemFont(ofSize: 20)
            topTitle.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            topTitle.text = "\(creatDateString ?? "Unknown")"
            
            let bottomTitle = UILabel(frame: CGRect(x: 0, y: topTitle.frame.height, width:200, height: 18))
            bottomTitle.numberOfLines = 1
            bottomTitle.textAlignment = .center
            bottomTitle.font = .systemFont(ofSize: 15)
            bottomTitle.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
            bottomTitle.text = "\(creatSeccondString ?? "Unknown")"
            
            containerView.addSubview(topTitle)
            containerView.addSubview(bottomTitle)
            
            self.navigationItem.titleView = containerView
            
        }
        
    }
    
    func settingAssetImg(){
        if let collectionAsset = asset {
            imgManger.requestImage(for: collectionAsset, targetSize: CGSize(width: assetImgView.frame.width, height: assetImgView.frame.height), contentMode: .aspectFill, options: nil, resultHandler: { img, _ in self.assetImgView.image = img })
        }
    }
    
    
    
}

extension AssetViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return assetImgView
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        navigationController?.navigationBar.isHidden = true
        navigationController?.toolbar.isHidden = true
        
    }
}

extension AssetViewController : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fethchReusltObserve = asset else { return }
        guard let changes = changeInstance.changeDetails(for: fethchReusltObserve) else { return }
        
        asset = changes.objectBeforeChanges
        
    }
}


