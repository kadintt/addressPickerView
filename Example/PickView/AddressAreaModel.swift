//
//  AddressAreaModel.swift
//  PickView_Example
//
//  Created by 曲超 on 2020/4/29.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class AddressAreaModel: NSObject {
    /** 区域id */
      var areaId:String = ""
      /** 区域名 */
      var areaName:String = ""
      /** 区域首字母 */
      var initial:String = ""
      /** 区域父级id */
      var parentId:String = ""
      /** 区域子集id */
      var subAreas:[AddressAreaModel] = [AddressAreaModel]()
      /** 是否被选中 */
      var hasChoose:Bool = false
      /** 是否显示首字母 */
      var showLetter:Bool = false
    
}
