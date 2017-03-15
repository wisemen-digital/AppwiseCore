//
//  DataRequest.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Alamofire
import AlamofireCoreData

public extension DataRequest {
	/// Adds a handler to be called once the request has finished.
	///
	/// - parameter queue:             The queue on which the completion handler is dispatched.
	/// - parameter jsonSerializer:    The se
	/// - parameter type:              The `Insertable` type that will be used in the serialization
	/// - parameter completionHandler: The code to be executed once the request has finished.
	///
	/// - returns: the request
	@discardableResult public func responseInsert<T: Insertable>(
		queue: DispatchQueue? = nil,
		jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer(),
		type: T.Type,
		completionHandler: @escaping (DataResponse<T>, @escaping DB.SaveBlock) -> Void)
		-> Self
	{
		do {
			try DB.operation() { [unowned self] (context, save) -> Void in
				self.responseInsert(queue: queue, jsonSerializer: jsonSerializer, context: context, type: T.self) { response in
					completionHandler(response, save)
				}
			}
		} catch let e {
			let result = Result<T>.failure(e)
			let response = DataResponse(request: request, response: self.response, data: delegate.data, result: result)
			
			completionHandler(response, {})
		}
		
		return self
	}
}
