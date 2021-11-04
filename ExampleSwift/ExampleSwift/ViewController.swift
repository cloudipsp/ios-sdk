import UIKit
import Cloudipsp

class ViewController: UIViewController, PSPayCallbackDelegate {
    @IBOutlet weak var textFieldMerchantID: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldDescription: UITextField!
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var textFieldCurrency: UITextField!
    @IBOutlet weak var cardInputLayout: PSCardInputLayout!
    var cloudipspWebView: PSCloudipspWKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudipspWebView = PSCloudipspWKWebView(frame: CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height))
        self.view.addSubview(cloudipspWebView)
    }

    @IBAction func onPayPressed(_ sender: Any) {
        let generatedOrderId = String(format: "Swift_%d", arc4random())
        let cloudipspApi = PSCloudipspApi(merchant: Int(textFieldMerchantID.text!) ?? 0, andCloudipspView: self.cloudipspWebView)
        let card = self.cardInputLayout.confirm()
        if (card == nil) {
            debugPrint("Empty card")
        } else {
            let order = PSOrder(order: Int(textFieldAmount.text!) ?? 0, aStringCurrency: textFieldCurrency.text!, aIdentifier: generatedOrderId, aAbout: textFieldDescription.text!)
            cloudipspApi?.pay(card, with: order, andDelegate: self)
        }
    }

    @IBAction func onTestCardPressed(_ sender: Any) {
        self.cardInputLayout.test()
    }

    func onPaidProcess(_ receipt: PSReceipt!) {
        debugPrint("onPaidProcess: %@", receipt.status)
    }
    
    func onPaidFailure(_ error: Error!) {
        debugPrint("onPaidFailure: %@", error.localizedDescription)
    }
    
    func onWaitConfirm() {
        debugPrint("onWaitConfirm")
    }
}

