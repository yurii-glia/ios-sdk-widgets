import UIKit
import GliaWidgets

extension ViewController {

    @IBAction private func presentVisitorCodeAsAlertTapped() {
        showVisitorCode(presentation: .alert(self))
    }

    @IBAction private func embedVisitorCodeViewTapped() {
        showVisitorCode(presentation: .embedded(visitorCodeView))
    }
    
    func showVisitorCode(presentation: CallVisualizer.Presentation) {
        showRemoteConfigAlert { [weak self] fileName in
            let config = self?.retrieveRemoteConfiguration(fileName)
            Glia.sharedInstance.callVisualizer.showVisitorCodeViewController(
                by: presentation,
                uiConfig: config
            )
        }
    }
}