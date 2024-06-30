import Alamofire
import Foundation

fileprivate let authService = AuthService.live
fileprivate let authCache = AuthCache.live

class DefaultInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        print("URL: \(urlRequest.url?.absoluteString ?? "")")
        var modifiedRequest = urlRequest
        modifiedRequest.setValue("Bearer " + authCache.getToken(of: .accessToken), forHTTPHeaderField: "Authorization")
        
        completion(.success(modifiedRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        debugPrint(request)
        guard let url = request.request?.url else {
            completion(.doNotRetryWithError(error))
            return
        }
        print("URL String: \(url.absoluteString)")
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401, !url.absoluteString.contains("refresh") else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        let refreshToken = authCache.getToken(of: .refreshToken)
        let request = RefreshRequest(refreshToken: refreshToken)
        
        print("refreshToken - \(refreshToken)")
        
        Task {
            do {
                let response = try await authService.refresh(request)
                print("-- refreshed --")
                dump(response)
                authCache.saveToken(response.data.accessToken, to: .accessToken)
                completion(.retry)
            } catch {
                completion(.doNotRetryWithError(AuthError.refreshFailure))
            }
        }
    }
}
