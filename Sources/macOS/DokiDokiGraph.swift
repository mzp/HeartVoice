import Cocoa
import Ikemen
import NorthLayout

final class DokiDokiGraph: NSView {
    var activity: DokiDokiActivity? {
        didSet {reloadActivity()}
    }
    var timeOffset: TimeInterval = 0 {
        didSet {reloadTimeOffset()}
    }

    let titleLabel = AutolayoutLabel() ※ {
        $0.isBordered = false
        $0.drawsBackground = false
    }

    let timeBar = NSView() ※ {
        $0.wantsLayer = true
        $0.layer?.backgroundColor = .white
    }

    init() {
        super.init(frame: .zero)
        let autolayout = northLayoutFormat([:], [
            "title": titleLabel,
            "time": timeBar])
        autolayout("H:|-[title]-|")
        autolayout("H:[time(==2)]")
        autolayout("V:|-[title]-[time]|")

        reloadActivity()
        reloadTimeOffset()
    }
    required init?(coder decoder: NSCoder) {fatalError()}

    func reloadActivity() {
        titleLabel.stringValue = activity?.title ?? ""
        timeBar.isHidden = (activity == nil)
        needsDisplay = true
    }

    func reloadTimeOffset() {
        guard let activity = self.activity,
            let last = activity.heartbeats.last else { return }
        let duration = last.time.timeIntervalSince(activity.start)
        timeBar.frame.origin.x = CGFloat(timeOffset / duration) * bounds.width
    }

    override func draw(_ dirtyRect: NSRect) {
        dirtyRect.fill(using: .clear)
        guard let activity = self.activity,
            let last = activity.heartbeats.last else { return }
        let duration = last.time.timeIntervalSince(activity.start)
        let max: CGFloat = 215

        NSColor.gray.setFill()
        activity.heartbeats.forEach { beat in
            let offset = beat.time.timeIntervalSince(activity.start)
            let x = CGFloat(offset / duration) * bounds.width // swiftlint:disable:this identifier_name
            let height = (CGFloat(beat.heartrate) / max) * timeBar.frame.height
            NSRect(x: x, y: timeBar.frame.minY, width: 1, height: height).fill(using: .sourceOver)
        }
    }
}
