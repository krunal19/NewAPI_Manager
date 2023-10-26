//
//  NextVC.swift
//  WebServiceDemo
//
//  Created by Krunal on 27/10/23.
//

import UIKit

class NextVC: UIViewController {
    
    @IBOutlet weak var cvData: UICollectionView!{
        didSet{
            cvData.register(CellData.nib, forCellWithReuseIdentifier: CellData.identifier)
            
            //            cvData.register(CellDigiFotoHeaderDummy.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellDigiFotoHeaderDummy.identifier)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
//MARK: - UICollectionViewDelegate && DataSource
extension NextVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellData.identifier, for: indexPath) as! CellData
        cell.lblName.text = "krunal \(indexPath.item)"
        //            if let obj = realmGroupedDigiFotos[exist:indexPath.section]?.fotos?[exist: indexPath.row]{
        //                cell.configCell(obj: obj)
        //            }
        return cell
    }
    
    //    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    //
    //        switch kind {
    //        case UICollectionView.elementKindSectionHeader:
    //                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellDigiFotoHeader.identifier, for: indexPath) as! CellDigiFotoHeader
    //
    //                reusableview.lblTitle.text = getFormaredDate(str: "\(realmGroupedDigiFotos[exist: indexPath.section]?.date ?? "")", To: "MMMM dd, yyyy", From: "yyyy-MM-dd")//"\(arrDigiFotoByDate[indexPath.section].date ?? "")"
    //                if (reusableview.lblTitle.text == Date.getCurrentDate()){
    //                    reusableview.lblTitle.text = "Today"
    //                }
    //
    //                return reusableview
    //
    //        default:  fatalError("Unexpected element kind")
    //        }
    //    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tapped")
    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    //        return CGSize(width: collectionView.frame.width , height: 40)
    //    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (cvData.frame.width - 10)/1, height: 150)//(cvData.frame.width - 10)/2)
        
    }
    func Delete_image(title: String)
    {
        print("delete image successfully")
    }
}
