import SotoS3
import Foundation
import TitechOCWKit
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

Task {
    let titechOcw = TitechOCW()
    let bucket = "titechapp-data"

    let client = AWSClient(
        httpClientProvider: .createNew
    )
    let s3 = S3(client: client, region: .apnortheast1)
    
    var succeedCount = 0
    var failedCount = 0
    
    let encoder = JSONEncoder()
    
    for i in (202200001...202240000).shuffled() {
        do {
            let course = try await titechOcw.fetchOCWCourse(courseId: "\(i)")
            let bodyData = try encoder.encode(course)

            let putObjectRequest = S3.PutObjectRequest(
                            acl: .publicRead,
                            body: .data(bodyData),
                            bucket: bucket,
                            key: "/courseinfo/courses/\(i).json"
                        )
            _ = try await s3.putObject(putObjectRequest)
            
            succeedCount += 1
        } catch {
            failedCount += 1
        }
    }
    
    print("Task Finished. succeedCount: \(succeedCount) failedCount: \(failedCount)")

    exit(0)
}

dispatchMain()
