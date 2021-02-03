//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

fileprivate let logger = Cornucopia.Core.Logger(subsystem: "networking", category: "HTTP")

extension Cornucopia.Core {

    public class HTTPNetworking {

        var urlSession: URLSession

        public init(with configuration: URLSessionConfiguration? = nil) {
            guard let configuration = configuration else {
                urlSession = URLSession.shared
                return
            }
            urlSession = URLSession(configuration: configuration)
        }

        @discardableResult
        public func GET(with url: URL, to destinationURL: URL, then:@escaping((HTTPResponse<URL>) -> Void)) -> URLSessionDownloadTask {
            let request = URLRequest(url: url)
            return self.GET(with: request, to: destinationURL, then:then)
        }

        @discardableResult
        public func GET(with request: URLRequest, to destinationURL: URL, then:@escaping((HTTPResponse<URL>) -> Void)) -> URLSessionDownloadTask {
            assert( destinationURL.isFileURL, "The destinationURL needs to be a fileURL" );
            logger.debug( "\(request.httpMethod!) \(request), downloading a file…" )
            let time = Date().timeIntervalSince1970

            let task = urlSession.downloadTask(with: request) { url, urlResponse, error in

                guard let url = url, error == nil else { // an error occured
                    guard let urlError = error as? URLError, urlError.code == .cancelled else { // the task has not just been cancelled

                        logger.notice( "\(request.httpMethod!) \(request) => FAIL '\(error!.localizedDescription)'" )
                        let response = HTTPResponse<URL>.failure(error: error!)
                        then(response)
                        return
                    }
                    logger.debug( "\(request.httpMethod!) \(request) => CANCELLED" )
                    let response = HTTPResponse<URL>.cancellation
                    then(response)
                    return
                }

                let timeProcessed = String(format: "%.02f", (Date().timeIntervalSince1970 - time))
                let attributes = try? url.resourceValues(forKeys: Set([.fileSizeKey]))
                let fileSize = attributes?.fileSize ?? -1

                var httpStatusCode = HTTPStatusCode.OK
                var contentType = urlResponse?.mimeType ?? "unknown/unknown"
                var contentLength = urlResponse?.expectedContentLength ?? 0

                if let httpResponse = urlResponse as? HTTPURLResponse {
                    httpStatusCode = httpResponse.CC_statusCode
                    contentType = httpResponse.CC_contentType
                    contentLength = Int64(httpResponse.CC_contentLength)
                }
                logger.notice( "\(request.httpMethod!) \(request) => \(httpStatusCode.rawValue), '\(contentType)', \(contentLength) bytes announced, \(fileSize) bytes received in \(timeProcessed) s" )
                guard httpStatusCode.responseType == .Success else {
                    let response = HTTPResponse<URL>.empty(status: httpStatusCode)
                    then(response)
                    return
                }
                logger.debug("↑ Moving \(url) => \(destinationURL)")

                do {
                    try? FileManager.default.removeItem(at: destinationURL) // might fail, if not existing, we don't care
                    try FileManager.default.moveItem(at: url, to: destinationURL)
                    let response = HTTPResponse<URL>.success(status: httpStatusCode, payload: destinationURL)
                    then(response)
                } catch {
                    let response = HTTPResponse<URL>.failure(error: error)
                    then(response)
                    return
                }
            }

            task.resume()
            return task
        }

        @discardableResult
        public func GET(with request: URLRequest, then: @escaping((HTTPResponse<Data>) -> Void)) -> URLSessionDataTask {
            logger.debug( "\(request.httpMethod!) \(request), downloading the bytes…" )
            let handler = self.createDataTaskHandler(request: request, then: then)
            let task = urlSession.dataTask(with: request, completionHandler: handler)
            task.resume()
            return task
        }

        @discardableResult
        public func GET<T: Decodable>(with request: URLRequest, then: @escaping((HTTPResponse<T>) -> Void)) -> URLSessionDataTask {
            logger.debug( "\(request.httpMethod!) \(request) with type \(T.self)" )
            let handler = self.createDataTaskHandler(request: request, then: then)
            let task = urlSession.dataTask(with: request, completionHandler: handler)
            task.resume()
            return task
        }

        @discardableResult
        public func POST<UP: Encodable, DOWN: Decodable>(item: UP, with request: URLRequest, then: @escaping((HTTPResponse<DOWN>) -> Void)) -> URLSessionDataTask? {
            var request = request
            request.httpMethod = HTTPMethod.POST.rawValue
            request.setValue(HTTPContentType.applicationJSON.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
            do {
                request.httpBody = try Cornucopia.Core.JSONEncoder().encode(item)
            } catch {
                logger.error("Can't encode \(item): \(error.localizedDescription)")
                let response = Cornucopia.Core.HTTPResponse<DOWN>.failure(error: error)
                then(response)
                return nil
            }
            logger.debug( "\(request.httpMethod!) \(request) with a \(UP.self), expecting to receive a \(DOWN.self)" )

            #if DEBUG
            let string = String(data: request.httpBody!, encoding: .utf8) ?? "<invalid charset>"
            logger.debug("↑ Sent \(string)")
            #endif

            let handler = self.createDataTaskHandler(request: request, then: then)
            let task = urlSession.dataTask(with: request, completionHandler: handler)
            task.resume()
            return task
        }

        @discardableResult
        public func POST<T: Codable>(item: T, with request: URLRequest, then: @escaping((HTTPResponse<T>) -> Void)) -> URLSessionDataTask? {
            var request = request
            request.httpMethod = HTTPMethod.POST.rawValue
            request.setValue(HTTPContentType.applicationJSON.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
            do {
                request.httpBody = try Cornucopia.Core.JSONEncoder().encode(item)
            } catch {
                logger.error("Can't encode \(item): \(error.localizedDescription)")
                let response = Cornucopia.Core.HTTPResponse<T>.failure(error: error)
                then(response)
                return nil
            }
            logger.debug( "\(request.httpMethod!) \(request) with type \(T.self)" )

            #if DEBUG
            let string = String(data: request.httpBody!, encoding: .utf8) ?? "<invalid charset>"
            logger.debug("↑ Sent \(string)")
            #endif

            let handler = self.createDataTaskHandler(request: request, then: then)
            let task = urlSession.dataTask(with: request, completionHandler: handler)
            task.resume()
            return task
        }
    }

} // extension Cornucopia.Core

private extension Cornucopia.Core.HTTPNetworking {

    func createDataTaskHandler<T>(request: URLRequest, then: @escaping((Cornucopia.Core.HTTPResponse<T>) -> Void)) -> URLSessionTask.CompletionHandler {

        let time = Date().timeIntervalSince1970

        let handler: (Data?, URLResponse?, Error?) -> Void = { data, urlResponse, error in

            guard let data = data, error == nil else { // an error occured
                guard let urlError = error as? URLError, urlError.code == .cancelled else { // the task has not just been cancelled

                    logger.notice( "\(request.httpMethod!) \(request) => FAIL '\(error!.localizedDescription)'" )
                    let response = Cornucopia.Core.HTTPResponse<T>.failure(error: error!)
                    then(response)
                    return
                }
                logger.debug( "\(request.httpMethod!) \(request) => CANCELLED" )
                let response = Cornucopia.Core.HTTPResponse<T>.cancellation
                then(response)
                return
            }

            let httpResponse = urlResponse as! HTTPURLResponse
            let httpStatusCode = httpResponse.CC_statusCode
            let contentType = httpResponse.CC_contentType
            let contentLength = httpResponse.CC_contentLength
            let timeProcessed = String(format: "%.02f", (Date().timeIntervalSince1970 - time))

            logger.notice( "\(request.httpMethod!) \(request) => \(httpResponse.statusCode), '\(contentType)', \(contentLength) bytes announced, \(data.count) bytes received in \(timeProcessed) s." )
            guard httpStatusCode.responseType == .Success else {
                if data.count > 0 {
                    let string = String(data: data, encoding: .utf8) ?? "<invalid charset>"
                    logger.notice("\(request.httpMethod!) request failed with the following response: \(string)")
                }
                let response = Cornucopia.Core.HTTPResponse<T>.empty(status: httpStatusCode)
                then(response)
                return
            }
            if T.self == Data.self {
                // requested target type is Data, no need to process further
                let response = Cornucopia.Core.HTTPResponse<T>.success(status: httpStatusCode, payload: data as! T)
                then(response)
                return
            }

            #if DEBUG
            let string = String(data: data, encoding: .utf8) ?? "<invalid charset>"
            logger.debug("↓ Received \(string)")
            #endif

            switch contentType {
                case "application/json":
                    do {
                        let decoder = Cornucopia.Core.JSONDecoder() // configured for relaxed parsing of ISO8601 dates
                        let object = try decoder.decode(T.self, from: data)
                        let response = Cornucopia.Core.HTTPResponse<T>.success(status: httpStatusCode, payload: object)
                        then(response)

                    } catch let error {
                        logger.notice("Could not decode as \(T.self): \(error.localizedDescription) \(error)")
                        let response = Cornucopia.Core.HTTPResponse<T>.empty(status: httpStatusCode)
                        then(response)
                    }
                case _ where contentType.hasPrefix("text/"):
                    guard T.self == String.self else {
                        logger.notice("Don't know how to unpack content-type \(contentType) to a \(T.self)")
                        let response = Cornucopia.Core.HTTPResponse<T>.empty(status: httpStatusCode)
                        then(response)
                        return
                    }
                    //TODO: We're forcing UTF8 here without actually inspecting a possible charset specification in the content-type such as 'text/plain;charset=UTF-8'. Should be rewritten to not hardcode .utf8 and rather parse the charset specification.
                    let response = Cornucopia.Core.HTTPResponse<T>.success(status: httpStatusCode, payload: String(data: data, encoding: .utf8) as! T)
                    then(response)

                default:
                    logger.notice("Don't know how to unpack content-type \(contentType) to a \(T.self)")
                    let response = Cornucopia.Core.HTTPResponse<T>.empty(status: httpStatusCode)
                    then(response)
            }
        }
        return handler
    }
}

