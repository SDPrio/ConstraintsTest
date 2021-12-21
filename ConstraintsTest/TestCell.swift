import UIKit

class TestCell: CardCell {

    @IBOutlet weak var titleLabel: UILabel!
    var title: String? {
        get { return titleLabel?.text }
        set { titleLabel?.text = newValue }
    }

}
