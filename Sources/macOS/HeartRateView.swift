import Cocoa
import NorthLayout
import Ikemen

final class HeartRateView: NSView {
    var heartrate: Int? {
        didSet {
            label.stringValue = heartrate.map {"♥\($0)"} ?? "--"
        }
    }
    let label = AutolayoutLabel() ※ {
        $0.isBordered = false
        $0.drawsBackground = false
        $0.textColor = .white
        $0.stringValue = "--"
        $0.font = .systemFont(ofSize: 42.0)
    }

    init() {
        super.init(frame: .zero)
        let autolayout = northLayoutFormat([:], ["label": label])
        autolayout("H:|[label]|")
        autolayout("V:|[label]|")
    }
    required init?(coder decoder: NSCoder) {fatalError()}
}
