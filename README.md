# APIClient

![cocoapods](https://img.shields.io/badge/pod-3.0-blue) ![swift](https://img.shields.io/badge/Swift-5.0-orange.svg) ![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat) [![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/Yalantis/APIClient/blob/master/LICENSE)

## Integration (Cocoapods)

`pod 'APIClient', :git => "https://github.com/rnkyr/APIClient", :tag => "3.0"`

There're two podspecs:

- `APIClient/Core` contain pure interface / types used to abstract from implementation. Use it only in case you're about to provide custom implementation of request executor.
- `APIClient/Alamofire` (default one) contain AlamofireRequestExecutor implementation.

## Usage

Any requests should be made through `APIClient`'s instance. It's constructor requires specifying at least request executor. In case of `APIClient/Alamofire` it's `AlamofireRequestExecutor` (that in turn initialized with base url to your server and optioanlly `SessionManager` that could be customized if needed). 
You could also provide a list of plugins that will be used by that client (by default you got `ErrorPreprocessorPlugin(errorPreprocessor: NetworkErrorProcessor())` so don't forget to include it in case you're using own list) and deserializer (which is `JSONDeserializer` by default).

Next step is to declare your request. Requests are pure objects(values) that used to provide required data.
Your request should conform to one of the three available types: `APIRequest`,  `DownloadAPIRequest`, or `MultipartAPIRequest` (names corresponds to their roles).
Both `DownloadAPIRequest` and `MultipartAPIRequest` are inherited from `APIRequest` so you can provide any required data (like headers, parameters, encoding etc). You must at least specify `path` for basic request.

Finally, you call `execute(request:parser:completion:` method of your client in order to execute your request. Here you also have to specify parser (an instance of `ResponseParser` protocol). You got [`DecodableParser`](https://github.com/rnlyr/APIClient/blob/master/APIClient/Default/Parser/DecodableParser.swift) and you got [`JSONParser`](https://github.com/rnkyr/APIClient/blob/master/APIClient/Default/Parser/ResponseParser.swift) out of the box.

## PluginType

APIClient adopted plugins behavior that allows you to have almost complete control over it's execution flow.
You can define your own plugin (by implementation of `PluginType` protocol and passing it to client through constructor) that will replace/modify/log/resolve/decorate etc any passing request.
Refer to [`PluginType`](https://github.com/Yalantis/APIClient/blob/master/APIClient/Default/Plugins/PluginType.swift) to find documented list of methods.

APIClient also include some basic plugins.

##### `AuthorizationPlugin` 
allows you to authorize your requests by passing token in it's headers. To use it you need to provide `AuthorizationCredentialsProvider` to the plugin and mark your request as authorizable by implementing emtpy protocol `AuthorizableRequest`. 

##### `RestorationTokenPlugin`
allows you to restore your session in case of token expiration. To use it you need to provide `AccessCredentialsProvider` (used to obtain token-related information; it also has callbacks to handle restoration results) and callback to provide executed restoration request's result. 
##### `LoggingPlugin`
simply logs any entries to the plugin using optionally provided closure.

##### `ErrorDecoratorPlugin`
used to decorate (e.g. map) incoming error `NetworkError` to custom type.

##### `ErrorRecovererPlugin`
allows use to simplify error recovering flow

##### `ErrorPreprocessorPlugin` 
allows you to process pure (`(httpResponse: HTTPURLResponse, data: Data)`) response and create appropriate error.

By default, APIClient uses `ErrorPreprocessorPlugin(errorPreprocessor: NetworkErrorProcessor())` which allows us to create `NetworkError.response` in case of unhandled errors.

## Version history

| Version  | Swift  | Dependencies | iOS |
|-----------|-------|------------------|------|
| `3.0`       | 5.0  | Alamofire 5.2.1 | 10 |
| `2.9.1`       | 5.0  | Alamofire 4.9,  YALResult 1.4 | 10 |
| `2.9`       | 5.0  | Alamofire 4.8,  YALResult 1.4 | 10 |
| `2.8`       | 4.2  | Alamofire 4.7,  YALResult 1.1 | 10 |
| `2.0.1`   | 4.2  | Alamofire 4.6,  YALResult 1.0 | 10 |
| `1.1.3`   | 4.0  | Alamofire 4.6,  BoltsSwift 1.4, ObjectMapper 3.3 | 9 |
| `1.0.7`   | 3     | Alamofire 4,  BoltsSwift 1.3, ObjectMapper 2.0 | 9 |
