import Cocoa
import Ikemen
import NorthLayout

final class MainView: NSView {
    var activity: DokiDokiActivity? {
        get {return graphView.activity}
        set {
            graphView.activity = newValue
            replayTitleLabel.stringValue = newValue?.title ?? ""
        }
    }
    var timeOffset: TimeInterval {
        get {return graphView.timeOffset}
        set {
            graphView.timeOffset = newValue

            guard let activity = activity else { return }
            replayHeartRateView.heartrate = activity.heartbeats.min {
                abs($0.time.timeIntervalSince(activity.start) - newValue) < abs($1.time.timeIntervalSince(activity.start) - timeOffset)
            }?.heartrate
        }
    }

    let currentHeartRateView = HeartRateView()
    let replayHeartRateView = HeartRateView()
    let replayTitleLabel = AutolayoutLabel() ※ {
        $0.isBordered = false
        $0.drawsBackground = false
        $0.textColor = .white
    }
    let graphView = DokiDokiGraph()

    init() {
        super.init(frame: .zero)
        let autolayout = northLayoutFormat([:], [
            "currentHR": currentHeartRateView,
            "replayHR": replayHeartRateView,
            "replayTitle": replayTitleLabel,
            "graph": graphView])
        autolayout("H:|[currentHR]-(>=20)-[replayHR]|")
        autolayout("H:|[replayTitle]|")
        autolayout("H:|[graph]|")
        autolayout("V:|[currentHR]-[replayTitle]-[graph]|")
        autolayout("V:|[replayHR(==currentHR)]-[replayTitle]")
    }
    required init?(coder decoder: NSCoder) {fatalError()}
}
