//
//  NetworkError.swift
//  cinema
//
//  Created by NSFuntik on 19.06.2023.
//

import Foundation

enum NetworkError: Error {
    /// An `URLSession` error.
    case urlError(URLError)

    /// `URLResponse` is not `HTTPURLResponse` or empty.
    case invalidResponse

    /// Status code is `≥ 400`.
    case httpError(HTTPURLResponse)
}

private let retryAfterHeaderKey = "Retry-After"

extension NetworkError {
    var canRetry: Bool { canRetryURLError || canRetryHTTPError }

    var canRetryURLError: Bool {
        if case let .urlError(urlError) = self {
            switch urlError.code {
            case .timedOut,
                 .cannotFindHost,
                 .cannotConnectToHost,
                 .networkConnectionLost,
                 .dnsLookupFailed,
                 .httpTooManyRedirects,
                 .resourceUnavailable,
                 .notConnectedToInternet,
                 .secureConnectionFailed,
                 .cannotLoadFromNetwork:
                return true
            default:
                break
            }
        }

        return false
    }

    var canRetryHTTPError: Bool {
        if case let .httpError(response) = self {
            let code = response.statusCode
            if /* Too Many Requests */ code == 429 ||
                /* Service Unavailable */ code == 503 ||
                /* Request Timeout */ code == 408 ||
                /* Gateway Timeout */ code == 504 {
                return true
            }

            if response.allHeaderFields[retryAfterHeaderKey] != nil {
                return true
            }
        }

        return false
    }

    var retryAfter: TimeInterval? {
        if case let .httpError(response) = self, let retryAfter = response.allHeaderFields[retryAfterHeaderKey] {
            if let retryAfterSeconds = (retryAfter as? NSNumber)?.doubleValue {
                return retryAfterSeconds
            }

            if let retryAfterString = retryAfter as? String {
                if let retryAfterSeconds = Double(retryAfterString), retryAfterSeconds > 0 {
                    return retryAfterSeconds
                }

                let date = NetworkError.httpDateFormatter.date(from: retryAfterString)
                let currentTime = CFAbsoluteTimeGetCurrent()
                if let retryAbsoluteTime = date?.timeIntervalSinceReferenceDate, currentTime < retryAbsoluteTime {
                    return retryAbsoluteTime - currentTime
                }
            }
        }
        return nil
    }

    private static var httpDateFormatter: DateFormatter = {
        // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After#Examples
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return dateFormatter
    }()
}
