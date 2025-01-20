import SwiftUI
import UIKit

public struct TimeDurationPicker: UIViewRepresentable {
    @Binding var duration: TimeInterval
    let showHours: Bool
    private var hourLabel: UILabel = UILabel()
    
    private var hours: Int {
        get { showHours ? Int(duration / 3600) : 0 }
        set { updateDuration(hours: newValue) }
    }
    
    private var minutes: Int {
        get {
            if showHours {
                return Int((duration / 60)) % 60
            } else {
                return Int(duration / 60)
            }
        }
        set { updateDuration(minutes: newValue) }
    }
    
    private var seconds: Int {
        get { Int(duration) % 60 }
        set { updateDuration(seconds: newValue) }
    }
    
    private func updateDuration(hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil) {
        let h = hours ?? self.hours
        let m = minutes ?? self.minutes
        let s = seconds ?? self.seconds
        
        duration = TimeInterval(h * 3600 + m * 60 + s)
        
        if showHours {
            hourLabel.text = h == 1 ? "hour" : "hours"
        }
    }
    
    public init(duration: Binding<TimeInterval>, showHours: Bool = true) {
        self._duration = duration
        self.showHours = showHours
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        
        let labelConstraint: [CGFloat] = if showHours {
            [46, 150, 255]
        } else {
            [0, 46, 195]
        }
        
        if showHours {
            hourLabel.text = hours == 1 ? "hour" : "hours"
            hourLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            picker.addSubview(hourLabel)
            hourLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hourLabel.centerYAnchor.constraint(equalTo: picker.centerYAnchor),
                hourLabel.leadingAnchor.constraint(equalTo: picker.leadingAnchor, constant: labelConstraint[0]),
            ])
        }
        
        let mLabel = UILabel()
        mLabel.text = "min"
        mLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        picker.addSubview(mLabel)
        
        let sLabel = UILabel()
        sLabel.text = "sec"
        sLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        picker.addSubview(sLabel)
        
        mLabel.translatesAutoresizingMaskIntoConstraints = false
        sLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mLabel.centerYAnchor.constraint(equalTo: picker.centerYAnchor),
            mLabel.leadingAnchor.constraint(equalTo: picker.leadingAnchor, constant: labelConstraint[1]),
            
            sLabel.centerYAnchor.constraint(equalTo: picker.centerYAnchor),
            sLabel.leadingAnchor.constraint(equalTo: picker.leadingAnchor, constant: labelConstraint[2])
        ])
        return picker
    }
    
    public func updateUIView(_ picker: UIPickerView, context: Context) {
        var comp = 0
        if showHours {
            picker.selectRow(hours, inComponent: comp, animated: false)
            comp += 1
        }
        picker.selectRow(minutes, inComponent: comp, animated: false)
        comp += 1
        picker.selectRow(seconds, inComponent: comp, animated: false)
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIPickerView, context: Context) -> CGSize? {
        return CGSize(width: showHours ? 300 : 240, height: 180)
    }
    
    @MainActor
    public class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: TimeDurationPicker
        
        init(_ parent: TimeDurationPicker) {
            self.parent = parent
        }
        
        public func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return parent.showHours ? 3 : 2
        }
        
        public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0: return 100
            case 1, 2: return 60
            default: return 0
            }
        }
        
        public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let view = view ?? getNewRowView(forComponent: component)
            let label = view.subviews.first! as! UILabel
            label.text = "\(row)"
            label.textAlignment = .right
            label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .regular)
            return view
        }
        
        func getNewRowView(forComponent component: Int) -> UIView {
            let width: CGFloat = parent.showHours ? 100 : 120
            let rightMargin: CGFloat = if parent.showHours {
                58
            } else {
                switch component {
                case 0: 96
                case 1: 30
                default: 0
                }
            }
            let view = UIView(frame: .init(x: 0, y: 0, width: width, height: 32))
            let label = UILabel()
            view.addSubview(label)
            let layoutGuide = UILayoutGuide()
            view.addLayoutGuide(layoutGuide)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                layoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                label.trailingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                layoutGuide.widthAnchor.constraint(equalToConstant: rightMargin)
            ])
            return view
        }
        
        public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            return parent.showHours ? 100 : 80
        }
        
        public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 32
        }
        
        public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if parent.showHours {
                switch component {
                case 0: parent.hours = row
                case 1: parent.minutes = row
                case 2: parent.seconds = row
                default: break
                }
            } else {
                switch component {
                case 0: parent.minutes = row
                case 1: parent.seconds = row
                default: break
                }
            }
        }
    }
}

struct WorkoutDurationPicker_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var duration1: TimeInterval = 3746
        @State private var duration2: TimeInterval = 3746
        
        var body: some View {
            VStack {
                TimeDurationPicker(duration: $duration1, showHours: false)
                Text("Duration 1: \(Int(duration1))s")
                
                TimeDurationPicker(duration: $duration2)
                Text("Duration 2: \(Int(duration2))s")
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}

