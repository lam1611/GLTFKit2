
import Cocoa
import GLTFKit2

class GLTFDocument: NSDocument {
    
    var asset: GLTFAsset? {
        didSet {
            if let asset = asset {
                if let contentViewController = self.windowControllers.first?.contentViewController as? ViewController {
                    contentViewController.asset = asset
                }
            }
        }
    }
    
    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("GLTFWindowController"))
        self.addWindowController(windowController as! NSWindowController)
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        let cacheURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.appendingPathComponent("cacheAnimation.plist")
        
        GLTFAsset.load(with: url,
                       cacheAnimations: cacheURL,
                       overrideCache: false,
                       options: [:]) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async {
                if status == .complete {
                    self.asset = maybeAsset
                } else if let error = maybeError {
                    NSAlert(error: error).runModal()
                }
            }
        }
    }
}
