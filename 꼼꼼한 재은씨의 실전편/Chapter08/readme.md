# 챕터8 - 서버 연동

## 서버 연동을 위한 기초

### http 메시지

 웹브라우저를 통해 페이지를 이동하는 순간 텍스트 기반 메시지로 웹 서버에 요청을 보내게 되는데, 이 메시지 형식을 http 메시지 라고 합니다.

 대부분 웹 서버는 응답용 http 메시지에 HTML이나 CSS, 자바 스크립트, 이미지 등을 담아 보냅니다.

> ### http 메시지 구조
> 
> http 메시지는 크게 `요청`, `응답` 두가지 메시지로 나눌 수 있습니다. 그리고 메시지는 다시 `라인`, `헤더`, `바디` 세 부분으로 구성됩니다.
> 
> - 라인은 HTTP 메시지의 첫 줄로 응답/요청 여부 전송 방식, 상태 정보 등이 저장됩니다.
> 
> - 헤더는 메시지 본문에대한 메타 정보.
> 
> - 바디는 실제로 보내는 데이터가 있습니다.

```http
POST /userAccount/login HTTP/1.1
Host: swiftapi.asdfasf.co.kr:2020
Content-Type: application/x-www-form-urlencoded

account=swift%40swift.com&passwd=1234
```

http 메시지의 예시로 구조가 간단하게 되어있습니다.

- 첫번째 줄은 `라인`입니다. POST 방식으로 어떤 경로에 요청을 보내야 하는지, 그리고 HTTP 버전이 따라옵니다.

- 두번째 줄 부터 `헤더`이고 공백을 만나면 그 아래로는 바디입니다. 헤더는 key-value 형태로 구성되며 위의 예제는 Host와 Content-Type을 가지고있습니다.
  
  Content-Type의 `application/x-www-form-urlencoded`는 우리가 알고있는 일반적인 방식으로 전송하라는 의미입니다. 만약 바디에 json 형태로 요청을 보내야한다면 `application/json`으로 보내야 합니다.

- 공백 다음 줄 부터 `바디`입니다. `application/x-www-form-urlencoded`방식의 요청에서 바디는 `&`를 사용해서 데이터를 구분합니다.
  
  특수 문자가 있을경우 URLEncoding형식으로 변환합니다. swift@swift.com이 swift%40swift.com으로 변환되었습니다.

만약 POST가 아닌 GET 방식인 경우 구조가 달라집니다.

```http
GET /userAccount/login?account=swift%40swift.com&passwd=1234 HTTP/1.1

Host: swiftapi.asdfasf.co.kr:2020
Cache-Control: no-cache
```

 메시지 본문이 사라지고 본문에 있어야할 데이터가 `라인`의 경로에 `?` 다음 위치에 존재합니다. 이 처럼 GET방식에서 URL에 연결된 파라미터를 `쿼리 스트링(Query String)`이라고 합니다.

 메시지 본문이 사라지기 때문에 헤더에 `Content-Type`이 없습니다. 하지만 URL 경로는 1024Byte 길이 제한이 있으므로 큰 값을 전달 할 수 없고 주로 GET방식은 무언가를 요청할때 쓰입니다.



### HTTPS

HTTP + Secure의 약자로 보안 인증에는 SSL 인증, TLS 인증 등 다양한 버전이 존재합니다.



### RESTful API

 REST는 Representational State Transfer의 약자로 HTTP를 위한 아키텍처입니다. 일정 규칙에 따라 HTTP 프로토콜을 주고받도록 하는 약속일 뿐입니다.

 REST구조를 따라 만든 시스템을 RESTful이라고 합니다. 이를 기반으로 서버와 주고받을 수 있도록 정의된 형식을 RESTful API라고 합니다.

RESTful API에서 주고 받는 내용은 `바디`에 담겨 `JSON`형식으로 전달됩니다. 



### JSON

JavaScript Object Notation의 약자로 자바스크립트 객체를 간결하게 표현하기위한 형식 입니다. 지금은 다른 언어에서도 지원하는 대표적인 텍스트 기반 데이터 구조입니다.



## 파운데이션 프레임워크를 이용하여 API 호출하기

메모 앱 기능을 구현할 때는 파운데이션을 직접 사용하는 대신 라이브러리를 사용할 예정이지만 라이브러리 내부에서 파운데이션 객체를 이용하므로 이를 잘 이해해야 잘 다룰 수 있습니다.

- 첫 번째 GET 방식으로 현재 시간 확인용 API 호출하기

- 두 번째 POST 방식으로 에코 API 호출하기

- 세 번째 JSON 방식으로 에코 JSON API 호출하기

> 각 예제는 동일한 방법으로 통신이 가능합니다.
> 
> 우선 url 객체를 정의합니다. 만약 GET방식인 경우 이 객체안에 전송 데이터가 들어갑니다.
> 
> url 객체를 이용하여 URLRequest 객체를 생성합니다. 이 객체에서 GET / POST 방식을 결정 해 주고 또 httpBody 속성을 통해 `바디`를 구성합니다. 
> 
> 추가로 setValue혹은 addValue를 사용하여 헤더를 설정합니다.
> 
> URLSession 객체에 request 객체를 담아 전송 준비를하고, 응답값을 받을 클로저를 만듭니다.



## Alamofire

 위에서 API 호출에 이용한 URLRequest는 사용하기 다소 복잡합니다. URLRequst와 URLSession 객체를 간소화 해 쉽게 쓸 수 있게 만든 라이브러리가 있으며 그 중 하나가 Alamofire입니다.

 Alamofire는 HTTP 네트워킹을 위해 스위프트 기반으로 개발된 비동기 라이브러리로 API 호출 역시 간결하게 작성 할 수 있습니다.


