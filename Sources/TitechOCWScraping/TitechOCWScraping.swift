import SotoS3
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

    @Option(name: .shortAndLong, help: "S3 bucket name used for upload.")
    var bucket: String

    mutating func run() async throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let titechOcw = TitechOCW(eventLoopGroup: eventLoopGroup)

        let bucket = bucket

        let client = AWSClient(httpClientProvider: .createNewWithEventLoopGroup(eventLoopGroup))
        let s3 = S3(client: client, region: .apnortheast1)

        var succeedCount = 0
        var failedCount = 0

        let encoder = JSONEncoder()

        for i in (start...end).shuffled() {
            do {
                print("Start \(i)")
                let course = try await titechOcw.fetchOCWCourse(courseId: "\(i)")
                let bodyData = try encoder.encode(course)

                let putObjectRequest = S3.PutObjectRequest(
                                acl: .publicRead,
                                body: .data(bodyData),
                                bucket: bucket,
                                key: "/courseinfo/courses/\(i).json"
                            )
                _ = try await s3.putObject(putObjectRequest)
                print("Success \(i)")

                succeedCount += 1
            } catch TitechOCWError.invalidOCWCourseHtml {
                /// 量が多すぎるので表示しない
                // print("TitechOCWError.invalidOCWCourseHtml")
            } catch {
                print("Error: \(error._domain):\(error._code) (\(error.localizedDescription)")
                failedCount += 1
            }
        }

        try await titechOcw.shutdown()
        try await client.shutdown()

        print("Task Finished. succeedCount: \(succeedCount) failedCount: \(failedCount)")
    }
}
