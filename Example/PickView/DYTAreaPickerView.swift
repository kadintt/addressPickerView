//
//  DYTAreaPickerView.swift
//  DaoyitongCode
//
//  Created by 曲超 on 2020/4/22.
//  Copyright © 2020 爱康国宾. All rights reserved.
//

import UIKit

public struct RegionInfo {
    var provinceText:String = ""
    var provinceCode:String = ""
    var cityCode:String = ""
    var cityText:String = ""
    var countyCode:String = ""
    var countyText:String = ""
    ///几级地址 默认进入都为空地址
    var levelAddress = "0"

    
}

enum TableShowDataType: Int {
    case TableShowDataTypeProvince = 4220952
    case TableShowDataTypeCities
    case TableShowDataTypeArea

}
typealias CommonBlock = (_ param: Any?) -> Void
typealias ChooseOverBlock = (_ info:RegionInfo)-> Void

class DYTAreaPickerView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, ShowAreaViewDelegate {
    
    var chooseOver:ChooseOverBlock?
    
    var lineTopMargin:CGFloat = 87
    
    var currentType:TableShowDataType?
    
    /// 负责接收 区域数据
    private var dataList:[AddressAreaModel]?
    /// 经过处理 后的展示数据
    private var tableData:[AddressAreaModel]?
        
    private lazy var regionInfo:RegionInfo = {
         let r = RegionInfo()
         return r
     }()
    
    var provinceArr: [AddressAreaModel] = [AddressAreaModel]()
    var citiesArr: [AddressAreaModel] = [AddressAreaModel]()
    var areaArr: [AddressAreaModel] = [AddressAreaModel]()
    
    let KScreen_Height = UIScreen.main.bounds.height
    let KScreen_Width = UIScreen.main.bounds.width
    
    
    lazy var tableView:UITableView = {
        let t = UITableView.init(frame:CGRect(x: 0, y: KScreen_Height, width: KScreen_Width, height: KScreen_Height), style:.plain)
        t.keyboardDismissMode = .onDrag;
        t.separatorStyle = .none;
        t.delegate = self;
        t.dataSource = self;
        t.backgroundColor = UIColor.dyt_background;
        t.showsVerticalScrollIndicator = false;
        return t
    }()
    
    private lazy var contentView: UIView = {
        let x = UIView()
        x.backgroundColor = .white
        x.frame = CGRect(x: 0, y: KScreen_Height, width: KScreen_Width, height: KScreen_Height)
        return x
    }()

    private lazy var cancleBtn = UIButton.quickButton(image: UIImage(named: "search_close_img"), selectImage: UIImage(named: "search_close_img"),tag: 422234, target: self, action: #selector(closeBtnClick))
        
    private lazy var title = UILabel.quickLabel("请选择")
    
    lazy var showView:ShowAreaView = {
        let v = ShowAreaView(frame: CGRect(x: 0, y: 0, width: KScreen_Width, height: 87))
        return v
    }()
    
    required  init(_ dataSource:[AddressAreaModel],_ region:RegionInfo) {
        super.init(frame: CGRect(x: 0, y: 0, width: KScreen_Width, height: KScreen_Height))
        dataList = dataSource
        provinceArr = dataSource
        regionInfo = region
        currentType = .TableShowDataTypeProvince
        setUpUI()
        showView.delegate = self
        showView.setRegionData(info: region)
        sortingData()
        addTap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func closeBtnClick() {
        hide()
    }
    
    // MARK: - 解决手势冲突
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        return !((touch.view?.isMember(of: NSClassFromString("UITableViewCellContentView")!))!)
    }
    
}

// MARK: - ShowAreaViewDelegate

extension DYTAreaPickerView {
    func updateShowAreaViewLayout(showView: ShowAreaView, height: CGFloat) {
        print(height)
        showView.frame = CGRect(x: 0, y: 38, width: KScreen_Width, height: height)
        tableView.frame = CGRect(x: 0, y: 38 + height, width: KScreen_Width, height: 398 - height - 38)
        showView.line.frame = CGRect(x: 32, y:height - 1, width: KScreen_Width - 64, height: 0.5)
        contentView.layoutSubviews()
        showView.layoutSubviews()

    }
    
    func clickShowLabel(show: ShowAreaView, sender: UIButton) {
        
        switch sender.tag {
            case TableShowDataType.TableShowDataTypeProvince.rawValue:
                //点击省 时 要把 currentType 状态改变 并且 当前按钮要变颜色
                currentType = .TableShowDataTypeProvince
                tableData = provinceArr
                reloadAreaData(regionInfo.provinceCode)
                show.provinceLab.textColor = UIColor.text_cyan
                show.citiesLab.textColor = regionInfo.cityText.isEmpty ? UIColor.text_cyan : UIColor.dyt_text
                show.areaLab.textColor = regionInfo.countyText.isEmpty ? UIColor.text_cyan : UIColor.dyt_text
                print("点击了省的按钮\(provinceArr)")
                break
            case TableShowDataType.TableShowDataTypeCities.rawValue:
                //当市  区县 无值的时候 btn 不能被点击
                if regionInfo.cityText.isEmpty {return}
                currentType = .TableShowDataTypeCities
                tableData = citiesArr
                reloadAreaData(regionInfo.cityCode)
                show.provinceLab.textColor = UIColor.dyt_text
                show.citiesLab.textColor = UIColor.text_cyan
                show.areaLab.textColor = regionInfo.countyText.isEmpty ? UIColor.text_cyan : UIColor.dyt_text
                print("点击了市的按钮\(citiesArr)")
                
                break
            case TableShowDataType.TableShowDataTypeArea.rawValue:
                
                if regionInfo.countyText.isEmpty {return}
                currentType = .TableShowDataTypeArea
                tableData = areaArr
                reloadAreaData(regionInfo.countyCode)
                show.provinceLab.textColor = UIColor.dyt_text
                show.citiesLab.textColor = UIColor.dyt_text
                show.areaLab.textColor = UIColor.text_cyan
                print("点击了区县的按钮\(areaArr)")
                break
            default:
                break
        }
    }
}
// MARK: - UITableViewDelegate && UITableViewDataSource

extension DYTAreaPickerView {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData?.count ?? 0
}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell_id", for: indexPath) as! AreaCell
        
        if indexPath.row < tableData!.count {

            cell.model = tableData![indexPath.row]
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        guard let data = tableData else { return  }
        let model = data[indexPath.row]
        print(model.areaName)

        switch currentType {
            case .TableShowDataTypeProvince:
                tableData = model.subAreas
                //点击到省 以后 要把 省下面的市 列表赋值给当前 citiesArr
                citiesArr = model.subAreas
                currentType = .TableShowDataTypeCities
                regionInfo.provinceCode = model.areaId
                regionInfo.provinceText = model.areaName
                
                //如果是 在以选择完  省市区县 的时候 重新选择了省 那么要将 region 里面的 市 区县信息 清空 防止数据展示错乱
                regionInfo.cityCode = ""
                regionInfo.cityText = ""
                regionInfo.countyCode = ""
                regionInfo.countyText = ""
                
                showView.setRegionData(info: regionInfo)
                fliter()
                tableView.reloadData()
                if tableData?.count != 0 {
                                 tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: false)
                }
                break
            case .TableShowDataTypeCities:
                tableData = model.subAreas
                //点击到市 以后 要把 省下面的区县列表赋值给当前 areaArr
                areaArr = model.subAreas
                currentType = .TableShowDataTypeArea
                regionInfo.cityCode = model.areaId
                regionInfo.cityText = model.areaName
                //同上
                regionInfo.countyCode = ""
                regionInfo.countyText = ""
                regionInfo.levelAddress = tableData?.count == 0 ? "2" : "3"
                showView.setRegionData(info: regionInfo)
                fliter()
                tableView.reloadData()
                if tableData?.count != 0 {
                             tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: false)
                            }
                break
            case .TableShowDataTypeArea:
                regionInfo.countyCode = model.areaId
                regionInfo.countyText = model.areaName
                showView.setRegionData(info: regionInfo)
                chooseOver?(regionInfo)
                hide()
                break
            case .none:
                break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 38
    }
    
}
// MARK: - 逻辑处理
extension DYTAreaPickerView {
    ///刷新数据
    private func reloadAreaData(_ code:String) {
        
        if tableData?.count == 0 { return }
        
        let row = getDataIndex(code)
        
        if row != 0 {
            tableView.scrollToRow(at: IndexPath(row: getDataIndex(code), section: 0), at: .middle, animated: false)

        }
    }
    ///获取当前元素index
    private func getDataIndex(_ code: String) ->Int {
        fliter()
        if code.isEmpty {
            return 0
        }else {
            var index = 0
            var temp = 0
            for item in tableData! {
                if item.areaId.elementsEqual(code) {
                    
                    item.hasChoose = true
                    temp = index
                }else {
                    item.hasChoose = false
                }
                
                index += 1
             }
            tableView.reloadData()
            return (temp >= tableData!.count) ? 0 : temp
        }
    }
    
    /// 初始化展示数据
    func sortingData() {
        
        if regionInfo.countyText.isEmpty{
        
            
        }else {
            
            let p = dataList?.filter({ (model) -> Bool in
                return model.areaId.elementsEqual(regionInfo.provinceCode)
            })
            
            let pm = p?.first
            
            citiesArr = pm?.subAreas ?? []
            
            let c  = pm?.subAreas.filter({ (model) -> Bool in
                   let m = model
                return m.areaId.elementsEqual(regionInfo.cityCode)
            })
            
            let cm = c?.first
            
            areaArr = cm!.subAreas
            
            tableData = cm?.subAreas

            reloadAreaData(regionInfo.countyCode)
            
            currentType = .TableShowDataTypeArea
            
            return
        }
        

        
        //如果二级城市 为空的那 那么 基本上为 港澳台 地区  正常展示就好
        if regionInfo.cityText.isEmpty {
            
            tableData = dataList
            currentType = .TableShowDataTypeProvince
            reloadAreaData(regionInfo.provinceCode)
            
        }else {
            //走到这儿 说明 该市 下面没有区县了
            let p = dataList?.filter({ (model) -> Bool in
                           return model.areaId.elementsEqual(regionInfo.provinceCode)
                       })
                       
            let pm = p?.first
                       
            citiesArr = pm?.subAreas ?? []
            tableData = citiesArr
            currentType = .TableShowDataTypeCities
            reloadAreaData(regionInfo.cityCode)
        }
    }
    // MARK: - 筛选数据
    func fliter() {
        
        if tableData?.count == 0 {
            chooseOver?(regionInfo)
            hide()
            return
        }
        //通过首字母 排序
        tableData?.sort(by: { (model1, model2) -> Bool in
            
            return DYTAreaPickerView.transToPinYin(str: model1.areaName) < DYTAreaPickerView.transToPinYin(str: model2.areaName)
        })
        //相同首字母 只展示第一个
        var temp:AddressAreaModel?
        for item in tableData! {
            
            if ((temp?.areaName) == nil) {
                temp = item
                item.showLetter = true
                continue
            }else {
                
                let t = DYTAreaPickerView.transToPinYin(str: temp!.areaName)
                
                let i = DYTAreaPickerView.transToPinYin(str: item.areaName)
                
                if t.elementsEqual(i) {
                    item.showLetter = false
                }else {
                    item.showLetter = true
                    temp = item
                }
            }
        }

    }
    
    // MARK: - 字符串转拼音首字母 进行比较
    static func transToPinYin(str:String)->String{

           //转化为可变字符串

           let mString = NSMutableString(string: str)

           //转化为带声调的拼音

           CFStringTransform(mString, nil, kCFStringTransformToLatin, false)

           //转化为不带声调

           CFStringTransform(mString, nil, kCFStringTransformStripDiacritics, false)

           //转化为不可变字符串
            let string = NSString(string: mString)

            //截取拼音首字母 转大写返回
            return string.substring(to: 1).capitalized
    }

}


// MARK: - API
extension DYTAreaPickerView {
    
    /// 动画
    private func animate(_ isShow: Bool, finish: CommonBlock? = nil) {
        if isShow {
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                self.contentView.frame.size.height = self.bounds.height
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.contentView.frame.origin.y = self.bounds.height
            }) { _ in
                finish?(nil)
            }
        }
    }

    /// 添加手势
    private func addTap() {
            
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        self.addGestureRecognizer(tap)
        self.gestureRecognizers?.first?.delegate = self
    }
    
    
    
    @objc func show() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(self)
        reset()
    }

    @objc func hide() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.contentView.frame.origin.y = self.bounds.height
        }) { _ in
            self.removeFromSuperview()
        }
    }
}


// MARK: - 页面布局
extension DYTAreaPickerView {
    
    private func setUpUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.0)
        addSubview(contentView)
        contentView.addSubview(cancleBtn)
        contentView.addSubview(title)
        contentView.addSubview(showView)
        contentView.addSubview(tableView)
        
        contentView.frame = CGRect(x: 0, y: KScreen_Height - 398, width: KScreen_Width, height: 398)
        title.frame = CGRect(x: (KScreen_Width - 50)/2, y: 16, width: 50, height: 22)
        cancleBtn.frame = CGRect(x: KScreen_Width - 24 - 7, y: 12, width: 24, height: 24)
        showView.frame = CGRect(x: 0, y: 38, width: KScreen_Width, height: 87)
        tableView.frame = CGRect(x: 0, y: showView.bounds.height, width: KScreen_Width, height: 398 - 87 - 38)
        tableView.register(AreaCell.self, forCellReuseIdentifier: "AreaCell_id")
        
        let maskPath = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = contentView.bounds
        maskLayer.path = maskPath.cgPath
        contentView.layer.mask = maskLayer

    }
    /// 初始化界面
    private func reset() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            self.animate(true)
        })
    }
}


// MARK: - 地址选择的cell
class AreaCell: UITableViewCell {
    
    lazy var letter = UILabel.quickLabel("B", font: UIFont(name: "Regular", size: 12) ?? UIFont.systemFont(ofSize: 12), textAlignment: .left, color: UIColor.dyt_description)
    lazy var areaLab = UILabel.quickLabel("北京", font: UIFont(name: "Regular", size: 12) ?? UIFont.systemFont(ofSize: 12), textAlignment: .left, color: UIColor.dyt_text)
    
    private lazy var chooseImg:UIImageView = {
        let i = UIImageView(image: UIImage(named: "address_area_choose"))
        return i
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setUpUI()
    }
    // MARK: - 赋值
    var model: AddressAreaModel? {
        didSet {
            letter.text = DYTAreaPickerView.transToPinYin(str: model?.areaName ?? "")
            areaLab.text = model?.areaName
            chooseImg.isHidden = !model!.hasChoose
            letter.isHidden = !model!.showLetter
        }
    }
    
    private func setUpUI() {
        
        contentView.addSubview(letter)
        contentView.addSubview(areaLab)
        contentView.addSubview(chooseImg)
        
        letter.frame = CGRect(x: 16, y: 11, width: 12, height: 17)
        areaLab.frame = CGRect(x: 32, y: 9, width: 200, height: 20)
        chooseImg.frame = CGRect(x: UIScreen.main.bounds.size.width - 20 - 16, y: 9, width: 20, height: 20)
        areaLab.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: - 代理

@objc protocol ShowAreaViewDelegate {
    
    func updateShowAreaViewLayout(showView:ShowAreaView, height:CGFloat)
    func clickShowLabel(show:ShowAreaView, sender:UIButton)
    
}

class ShowAreaView: UIView {
    
    let nomalHeight:CGFloat = 49
    let secondaryHeight:CGFloat = 101
    let ultimateHeight:CGFloat = 149
    let overseasList:[String] = ["810000","820000","710000"]
//    810000  香港🇭🇰
//    820000  澳门🇲🇴
//    710000  台湾省
    /// 代理
    weak var delegate: ShowAreaViewDelegate?

    lazy var provinceLab = UILabel.quickLabel("请选择省",color: UIColor.text_cyan)
    
    lazy var citiesLab = UILabel.quickLabel("请选择市",  color: UIColor.text_cyan)
    
    lazy var areaLab = UILabel.quickLabel("请选择市区县",color: UIColor.text_cyan)
        
    var provinceBtn:UIButton = UIButton.quickButton(backgroundColor:.clear,tag: TableShowDataType.TableShowDataTypeProvince.rawValue, target: self, action: #selector(btnClick))
    var citiesBtn:UIButton = UIButton.quickButton(backgroundColor:.clear,tag: TableShowDataType.TableShowDataTypeCities.rawValue, target: self, action: #selector(btnClick))
    var areaBtn:UIButton = UIButton.quickButton(backgroundColor:.clear,tag: TableShowDataType.TableShowDataTypeArea.rawValue, target: self, action: #selector(btnClick))

    lazy var provincePoint:UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        v.backgroundColor = UIColor.dyt_button_background
        v.layer.cornerRadius = 3
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.dyt_button_background.cgColor
        v.isHidden = true
        return v
    }()
    
    lazy var citiesPoint:UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        v.backgroundColor = UIColor.dyt_button_background
        v.layer.cornerRadius = 3
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.dyt_button_background.cgColor
        v.isHidden = true
        return v
    }()
    
    lazy var areaPoint:UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        v.backgroundColor = UIColor.dyt_button_background
        v.layer.cornerRadius = 3
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.dyt_button_background.cgColor
        v.layer.isHidden = true
        return v
    }()
    
    lazy var firstLine:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.dyt_placeholder
        v.isHidden = true
        return v
    }()
    
    lazy var secondLine:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.dyt_placeholder
        v.isHidden = true
        return v
    }()
    
    lazy var line:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.dyt_placeholder
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    // MARK: - 添加布局
    private func setUpUI() {
        addSubview(provinceLab)
        addSubview(provincePoint)
        addSubview(citiesLab)
        addSubview(citiesPoint)
        addSubview(areaLab)
        addSubview(areaPoint)
        addSubview(firstLine)
        addSubview(secondLine)
        addSubview(line)
        addSubview(provinceBtn)
        addSubview(citiesBtn)
        addSubview(areaBtn)
        
        
        let topMargin = 11
        let labHeight = 22
        let labMargin = 26
        let kScreen_width:CGFloat = UIScreen.main.bounds.size.width
        let btnHeight = 46
        
        
        provinceLab.frame = CGRect(x: 32, y: topMargin, width: 200, height: labHeight)
        provincePoint.frame = CGRect(x: 16, y: 19, width: 6, height: 6)
        firstLine.frame = CGRect(x: 18.5, y: 25, width: 1, height: 42)
        provinceBtn.frame = CGRect(x: 0, y: 0, width: Int(kScreen_width), height: btnHeight)

        
        citiesLab.frame = CGRect(x: 32, y: topMargin + labHeight + labMargin , width: 200, height: labHeight)
        citiesPoint.frame = CGRect(x: 16, y: citiesLab.frame.origin.y + 8, width: 6, height: 6)

        secondLine.frame = CGRect(x: 18.5, y: 73, width: 1, height: 42)
        citiesBtn.frame = CGRect(x: 0, y: btnHeight, width: Int(kScreen_width), height: btnHeight)
        
        
        areaLab.frame = CGRect(x: 32, y: topMargin + labHeight * 2 + labMargin * 2 , width: 200, height: labHeight)
        areaPoint.frame = CGRect(x: 16, y: areaLab.frame.origin.y + 8, width: 6, height: 6)

        areaBtn.frame = CGRect(x: 0, y: btnHeight * 2, width: Int(kScreen_width), height: btnHeight)
        
        line.frame = CGRect(x: 32, y:self.bounds.height - 1, width: kScreen_width - 64, height: 1)

        }
    
    @objc func btnClick(_ sender:UIButton) {
        
        self.delegate?.clickShowLabel(show: self, sender: sender)
        
    }
    // MARK: - 展示数据
    // 负责初识赋值  二种情况
    // 1.已经有值  则 根据 数据 时候为空 判断展示 几层 选择
    // 2.无值 默认展示 即可

    func setRegionData(info:RegionInfo) {
        var viewHeight:CGFloat = nomalHeight
                
        if info.provinceText.isEmpty {
            provinceLab.text = "请选择省"
            provinceLab.textColor = UIColor.text_cyan
        }else {
            provinceLab.text = info.provinceText
            provinceLab.textColor = UIColor.dyt_text
            provincePoint.isHidden = false
            provincePoint.backgroundColor = UIColor.dyt_button_background
        }
        
//        如果是港澳台 只显示 一行
        if overseasList.contains(info.provinceCode) || info.provinceText.isEmpty {
            citiesLab.text = ""
            updateSuperLayout(height: viewHeight)
            return
        } else {
            citiesPoint.isHidden = false
            citiesPoint.backgroundColor = UIColor.white
            firstLine.isHidden = false
            viewHeight = secondaryHeight
        }
        
        if info.cityText.isEmpty() {
            citiesLab.text = "请选择市"
            citiesLab.textColor = UIColor.text_cyan
            if firstLine.isHidden {
                firstLine.isHidden = false
            }
            secondLine.isHidden = true
            
        }else {
            citiesLab.text = info.cityText
            citiesLab.textColor = UIColor.dyt_text
            citiesPoint.backgroundColor = UIColor.dyt_button_background
            areaPoint.isHidden = false
            areaPoint.backgroundColor = UIColor.white
            secondLine.isHidden = false
            viewHeight = ultimateHeight
        }
        
        
        //当前展示的地址为二级地址 则不展示 区县
        if info.levelAddress.elementsEqual("2") {
            viewHeight = secondaryHeight
            secondLine.isHidden = true
            updateSuperLayout(height: viewHeight)
            return
        }
    
        if info.countyText.elementsEqual("") {
            areaLab.text = "请选择区县"
            areaLab.textColor = UIColor.text_cyan
       
        }else {
            areaLab.text = info.countyText
            areaLab.textColor = UIColor.dyt_text
            areaPoint.backgroundColor = .dyt_button_background
            secondLine.isHidden = false
        }
        updateSuperLayout(height: viewHeight)
    }
    
    //更新该view 在父控件中的 高度
    func updateSuperLayout(height: CGFloat) {
        self.delegate?.updateShowAreaViewLayout(showView: self, height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
      @objc static let text_cyan = UIColor(hexString: "11C3C3")
      /// 正文 494847
      @objc static let dyt_text = UIColor(hexString: "494847")
      /// 描述 83817F
      @objc static let dyt_description = UIColor(hexString: "83817F")
      /// placeholder E1E0DF
      @objc static let dyt_placeholder = UIColor(hexString: "E1E0DF")
    
    
      @objc static let dyt_background = UIColor(hexString: "FAFAFA")
    
    @objc static let dyt_button_background = UIColor(hexString: "2AD5D5")
     
}

extension String {
    
    func isEmpty() -> Bool {
        return self.elementsEqual("")
    }
}
extension UILabel {
    /// 快速创建lab
    ///
    /// - Parameters:
    ///   - text: text description
    ///   - font: font description
    ///   - textAlignment: textAlignment description
    ///   - color: color description
    ///   - backgroundColor: backgroundColor description
    ///   - circle: circle description
    /// - Returns: return value description
    @objc class func quickLabel(_ text: String? = nil,
                                font: UIFont = UIFont(name: "Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                textAlignment: NSTextAlignment = .left,
                                color: UIColor = UIColor.dyt_text,
                                backgroundColor: UIColor = UIColor.clear,
                                circle: CGFloat = 0
    ) -> UILabel {
        let x = UILabel()
        x.text = text
        x.font = font
        x.textAlignment = textAlignment
        x.backgroundColor = backgroundColor
        x.textColor = color
        if circle > 0 {
            x.layer.cornerRadius = circle
        }
        return x
    }
}

extension UIButton {
    /// 快速创建UIButton
    @objc class func quickButton(_ title: String? = nil,
                                 titleColor: UIColor = UIColor.dyt_text,
                                 image: UIImage? = nil,
                                 selectImage: UIImage? = nil,
                                 font: UIFont = UIFont(name: "Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                 backgroundColor: UIColor = UIColor.white,
                                 cornerRadius: CGFloat = 0,
                                 tag: NSInteger = 0,
                                 target: Any? = nil,
                                 action: Selector? = nil
    ) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = font
        button.backgroundColor = backgroundColor
        if target != nil {
            button.addTarget(target, action: action!, for: .touchUpInside)
        }
        if image != nil {
            button.setImage(image, for: .normal)
        }
        if selectImage != nil {
            button.setImage(selectImage, for: .selected)
        }
        if cornerRadius > 0 {
            button.layer.cornerRadius = cornerRadius
        }
        button.tag = tag

        return button
    }
}

extension UIView {
    var bottom: CGFloat {
        get {
          return self.frame.origin.y + self.frame.size.height
        }
       
    }
}
