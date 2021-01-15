//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLSessionTask {

    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

}
