/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import SwiftUI

class Coordinator: NSObject { //This class acts as a transition bridge between the data inside SwiftUI and the external framework. This coordinator connect the delegate and data source for the UITableView. You could also use it to deal with user events.
  var flightData: [FlightInformation]

  init(flights: [FlightInformation]) {
    self.flightData = flights
  }
}


struct FlightTimeline: UIViewControllerRepresentable {
  var flights: [FlightInformation]
  
  func makeUIViewController(context: Context) -> UITableViewController { //Here you generate a UIView
    UITableViewController()
  }
  
  func updateUIViewController(_ viewController: UITableViewController, context: Context) { //Similar to ViewDidLoad()
    viewController.tableView.dataSource = context.coordinator
    let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
    viewController.tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
  }
  
  func makeCoordinator() -> Coordinator { //This functions will create a coordinator inside the SwiftUI framwork and pass it where necessary.
    Coordinator(flights: flights)
  }
}

extension Coordinator: UITableViewDataSource { //The code that you use here works as it does in UIKit
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      flightData.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let timeFormatter = DateFormatter()
      timeFormatter.timeStyle = .short
      timeFormatter.dateStyle = .none

      let flight = self.flightData[indexPath.row]
      let scheduledString =
        timeFormatter.string(from: flight.scheduledTime)
      let currentString =
        timeFormatter.string(from: flight.currentTime ??
                                   flight.scheduledTime)

      let cell = tableView.dequeueReusableCell(
        withIdentifier: "TimelineTableViewCell",
        for: indexPath) as! TimelineTableViewCell

      var flightInfo = "\(flight.airline) \(flight.number) "
      flightInfo = flightInfo +
        "\(flight.direction == .departure ? "to" : "from")"
      flightInfo = flightInfo + " \(flight.otherAirport)"
      flightInfo = flightInfo + " - \(flight.flightStatus)"
      cell.descriptionLabel.text = flightInfo

      if flight.status == .cancelled {
        cell.titleLabel.text = "Cancelled"
      } else if flight.timeDifference != 0 {
        if flight.status == .cancelled {
          cell.titleLabel.text = "Cancelled"
        } else if flight.timeDifference != 0 {
          var title = "\(scheduledString)"
          title = title + " Now: \(currentString)"
          cell.titleLabel.text = title
        } else {
          cell.titleLabel.text =
            "On Time for \(scheduledString)"
        }      } else {
        cell.titleLabel.text =
          "On Time for \(scheduledString)"
      }

      cell.titleLabel.textColor = UIColor.black
      cell.bubbleColor = flight.timelineColor
      return cell
  }
}
