
import Cocoa
import SceneKit
import GLTFKit2

class ViewController: NSViewController, SettingsDelegate {
    var source: GLTFSCNSceneSource?
    var asset: GLTFAsset? {
        didSet {
            if let asset = asset {
                let source = GLTFSCNSceneSource(asset: asset)
                self.source = source
                sceneView.scene = source.defaultScene
                animations = source.animations
                animations.first?.play()
//                sceneView.scene?.lightingEnvironment.contents = "studio.hdr"
//                sceneView.scene?.lightingEnvironment.intensity = 1.0

                let sunLight = SCNLight()
                sunLight.type = .directional
                sunLight.intensity = 800
                sunLight.color = NSColor.white
                sunLight.castsShadow = true
                let sun = SCNNode()
                sun.light = sunLight
                sceneView.scene?.rootNode.addChildNode(sun)
                sun.look(at: SCNVector3(-1, -1, -1))

                let moonLight = SCNLight()
                moonLight.type = .directional
                moonLight.intensity = 200
                moonLight.color = NSColor.white
                let moon = SCNNode()
                moon.light = moonLight
                sceneView.scene?.rootNode.addChildNode(moon)
                moon.look(at: SCNVector3(1, -1, -1))

                let cameraLight = SCNLight()
                cameraLight.type = .directional
                cameraLight.intensity = 500
                cameraLight.color = NSColor.white
                sceneView.pointOfView?.light = cameraLight
                
                sceneView.showsStatistics = true

                if asset.animations.count > 0 {
                    if animationController == nil {
                        showAnimationUI()
                        animationController.sceneView = sceneView
                    }
                    animationController.animations = source.animations
                }
                
                if let wc = storyboard?.instantiateController(withIdentifier: "SettingsWindow") as? NSWindowController,
                   let w = wc.window,
                   let vc = wc.contentViewController as? SettingsViewController {
                    vc.delegate = self
                    
                    var datas: [String: [String: String]] = [:]
                    
                    for bsrKey in GLTFBlendShapeRootKey.allCases {
                        guard let blendShapeRootNode = self.source?.nodes[bsrKey.name] else { continue }
                        guard let weightPaths = blendShapeRootNode.value(forKey: "weightPaths") as? [String: String]  else {
                            continue
                        }
                        
                        datas[bsrKey.name] = weightPaths
                    }
                    
//                    guard let blendShapeRootNode = self.source.nodes[blendShapeRootKey.name] else { return }
//                    guard let weightPaths = blendShapeRootNode.value(forKey: "weightPaths") as? [String: String]  else {
//                        return
//                    }
                    vc.setup(datas: datas)
                    view.window?.addChildWindow(w, ordered: .above)
                }
            }
        }
    }

    private var sceneView: SCNView {
        return view as! SCNView
    }

    private var animationController: AnimationPlaybackViewController!

    private var animations = [GLTFSCNAnimation]()

    @IBOutlet weak var focusOnSceneMenuItem: NSMenuItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = NSColor(named: "BackgroundColor") ?? NSColor.white
    }

    @IBAction func focusOnScene(_ sender: Any) {
        if let (sceneCenter, sceneRadius) = sceneView.scene?.rootNode.boundingSphere,
            let pointOfView = sceneView.pointOfView
        {
            pointOfView.simdPosition = sceneRadius * simd_normalize(SIMD3(1, 0.5, 1))
            pointOfView.look(at: sceneCenter, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
            if let camera = pointOfView.camera {
                camera.automaticallyAdjustsZRange = true
                camera.fieldOfView = 60.0
            }
        }
    }

    private func showAnimationUI() {
        animationController = AnimationPlaybackViewController(nibName: "AnimationPlaybackView", bundle: nil)
        animationController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationController.view)
        let views = [ "controller" : animationController.view ]
        NSLayoutConstraint(item: animationController.view, attribute:.width, relatedBy:.equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier:0, constant:480).isActive = true
        NSLayoutConstraint(item: animationController.view, attribute:.height, relatedBy:.equal,
                           toItem: nil, attribute:.notAnAttribute, multiplier:0, constant:100).isActive = true
        NSLayoutConstraint(item:animationController.view, attribute:.centerX, relatedBy:.equal,
                           toItem: view, attribute: .centerX, multiplier:1, constant:0).isActive = true
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[controller]-(12)-|",
                                                           options: [],
                                                           metrics:nil,
                                                           views:views))
    }
    
    func blendShapeChange(value: CGFloat, key: GLTFBlendShapeKey, of blendShapeRootKey: GLTFBlendShapeRootKey) {
        source?.setBlendShape(value: value, for: key, of: blendShapeRootKey)
    }
}

protocol SettingsDelegate: AnyObject {
    func blendShapeChange(value: CGFloat, key: GLTFBlendShapeKey, of blendShapeRootKey: GLTFBlendShapeRootKey)
}

class RowEntity {
    let name: String
    let isGroup: Bool
    let groupName: String?
    var value: CGFloat
    
    init(name: String, isGroup: Bool, groupName: String? = nil, value: CGFloat) {
        self.name = name
        self.isGroup = isGroup
        self.groupName = groupName
        self.value = value
    }
}

class SettingsViewController: NSViewController {
    
    weak var delegate: SettingsDelegate?
    
    @IBOutlet weak var tableView: NSTableView!
    
    var rows: [RowEntity] = []
    
    func setup(datas: [String: [String: String]]) {
        var rows: [RowEntity] = []
        
        for sec in datas {
            rows.append(.init(name: sec.key, isGroup: true, value: 0))
            let values = sec.value
            let weights = Array(values.keys).sorted()
            for weightName in weights {
                rows.append(.init(name: weightName, isGroup: false, groupName: sec.key, value: 0))
            }
        }
        
        self.rows = rows
        tableView.reloadData()
    }
    
    @IBAction func sliderValueChange(_ sender: NSSlider) {
        let index = tableView.row(for: sender.superview!)
        let item = rows[index]
        item.value = CGFloat(sender.floatValue)
        
        guard let groupName = item.groupName,
              let rootKey = GLTFBlendShapeRootKey.fromName(groupName),
              let key = GLTFBlendShapeKey(rawValue: item.name)
        else { return }
        delegate?.blendShapeChange(value: item.value, key: key, of: rootKey)
    }
}

extension SettingsViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        rows.count
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        let item = rows[row]
        return item.isGroup
    }
    
//    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        let item = rows[row]
//        if let tableColumn = tableColumn, tableColumn.identifier == .init("valueColumn") {
//            return item.isGroup ? nil : item.value
//        }
//        return item.name
//    }
    
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        let item = rows[row]
//        if let tableColumn = tableColumn, tableColumn.identifier == .init("valueColumn") {
//            return item.isGroup ? nil : NSSlider(value: item.value, minValue: 0, maxValue: 1,
//                                                 target: self, action: #selector(sliderValueChange))
//        }
//
//        let label = NSTextField(labelWithString: item.name)
//        return label
//    }
    
//    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//        let item = rows[row]
//        if item.isGroup {
//            let cellView = tableView.makeView(withIdentifier: .init("HeaderCallView"), owner: self) as! NSTableCellView
//
//            return cellView
//        }
//    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let item = rows[row]
        if item.isGroup {
            return 40
        }
        
        return 30
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = rows[row]
        if item.isGroup {
            let cellView = tableView.makeView(withIdentifier: .init("HeaderCallView"), owner: self) as! NSTextField
            cellView.stringValue = item.name
            return cellView
        }
        
        let cellView = tableView.makeView(withIdentifier: .init("blendshapeView"), owner: self) as! NSTableCellView
        let nameTextField = cellView.viewWithTag(0) as! NSTextField
        nameTextField.stringValue = item.name
        
        let slider = cellView.viewWithTag(1) as! NSSlider
        slider.target = self
        slider.action = #selector(sliderValueChange)
        slider.floatValue = Float(item.value)
        return cellView
    }
}
