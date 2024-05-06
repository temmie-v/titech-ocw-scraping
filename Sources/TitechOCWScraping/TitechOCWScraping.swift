import Foundation
import TitechOCWKit
import ArgumentParser
import NIOPosix
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@main
struct TitechOCWScraping: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "Start OCW Course Id.")
    var start: Int

    @Option(name: .shortAndLong, help: "End OCW Course Id.")
    var end: Int
    
    var directory = "/users/tem/Desktop/c/"

    mutating func run() async throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let titechOcw = TitechOCW(eventLoopGroup: eventLoopGroup)

        var succeedCount = 0
        var failedCount = 0

        let encoder = JSONEncoder()

        for i in (start...end).shuffled() {
            do {
                print("Start \(i)")
                let course = try await titechOcw.fetchOCWCourse(courseId: "\(i)")
                let bodyData = try encoder.encode(course)

                let filePath = "\(directory)/\(i).json"
                try bodyData.write(to: URL(fileURLWithPath: filePath))
                print("Success \(i)")

                succeedCount += 1
            } catch TitechOCWError.invalidOCWCourseHtml {
                // 量が多すぎるので表示しない
                // print("TitechOCWError.invalidOCWCourseHtml")
            } catch {
                print("Error: \(error)")
                failedCount += 1
            }
        }
        
        try await titechOcw.shutdown()

        print("Task Finished. succeedCount: \(succeedCount) failedCount: \(failedCount)")
    }
}
