import SwiftUI

/// An observable wrapper for an array of data for use in any chart
public class LineChartViewModel: ObservableObject {
    @Published var data: ChartData

    var points: [Double] {
        data.values
    }

    var labels: [String] {
        data.labels
    }

    init(_ data: ChartData) {
        self.data = data
    }
    
    init() {
        self.data = ChartData(values: [Double](repeating: 0.0, count: 2), labels: [String](repeating: "", count: 2))
    }
}

/// Representation of a single data point in a chart that is being observed
class ChartValue: ObservableObject {
    @Published var currentValue: Double = 0
    @Published var currentLabel: String = ""
    @Published var interactionInProgress: Bool = false
}
