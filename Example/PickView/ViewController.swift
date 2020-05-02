//
//  ViewController.swift
//  PickView
//
//  Created by kadintt on 04/28/2020.
//  Copyright (c) 2020 kadintt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var regionList:[AddressAreaModel] = [AddressAreaModel]()
    
    @IBOutlet weak var addressLab: UILabel!
    
    var regionInfo: RegionInfo? {
        didSet {
            guard let info = regionInfo else { return }
            
            let p = info.provinceText
            let ci = info.cityText
            let c = info.countyText
            let region = p + ci + c
            self.addressLab.text = region
            
            
        }
    }
    
    @IBOutlet weak var btnClick: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let r = RegionInfo(provinceText: "",
                              provinceCode: "",
                              cityCode: "",
                              cityText: "",
                              countyCode:"",
                              countyText:"",
                              levelAddress: "0")
      
        regionInfo = r
        
        
        let plistPath = Bundle.main.path(forResource: "region", ofType: "plist")
        
        let arr = NSArray(contentsOfFile: plistPath ?? "")
        
//        print(arr)
        
        for item in arr ?? [] {
            
            let i = item as! [String : Any]
        
            let m = AddressAreaModel()
            m.areaId =  NSString(format: "%@", i["areaId"] as! NSNumber) as String
            m.areaName = i["areaName"] as! String
            m.initial = i["initial"] as! String
            m.parentId = NSString(format: "%@", i["parentId"] as! NSNumber) as String
            
            let subAreas = i["subAreas"] as! [[String :Any]]
            var subAreasArr = [AddressAreaModel]()
            for sub in subAreas {
                let m = AddressAreaModel()
                m.areaId = NSString(format: "%@", sub["areaId"] as! NSNumber) as String
                m.areaName = sub["areaName"] as! String
                m.initial = sub["initial"] as! String
                m.parentId = NSString(format: "%@", sub["parentId"] as! NSNumber) as String
                m.subAreas = sub["subAreas"] as! [AddressAreaModel]
                
                let grandAreas = sub["subAreas"] as! [[String :Any]]
                var grandArr = [AddressAreaModel]()
                for grand in grandAreas {
                    let m = AddressAreaModel()
                    m.areaId = NSString(format: "%@", grand["areaId"] as! NSNumber) as String
                    m.areaName = grand["areaName"] as! String
                    m.initial =  grand["initial"] as! String
                    m.parentId = NSString(format: "%@", grand["parentId"] as! NSNumber) as String
                    m.subAreas = sub["subAreas"] as! [AddressAreaModel]
                    grandArr.append(m)
                }
                m.subAreas = grandArr
                subAreasArr.append(m)
            }
            
            m.subAreas = subAreasArr
            
            regionList.append(m)
        }
        
    }

    @IBAction func click(_ sender: Any) {
        
        let pickerView = DYTAreaPickerView(self.regionList, regionInfo!)
               
               pickerView.show()
               
        pickerView.chooseOver = {[weak self] info in
                        self?.regionInfo = info
            
            if self?.regionInfo?.cityText.isEmpty ?? false {
                self?.regionInfo?.levelAddress =  "1"
                         }else {
                if (self?.regionInfo?.countyText.isEmpty)! {
                    self?.regionInfo?.levelAddress = "2"
                             }else {
                    self?.regionInfo?.levelAddress =  "3"
                             }
                       }

              }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

