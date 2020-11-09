# 챕터8 - 서버 연동

### 서버 연동을 위한 기초

##### http 메시지

 웹브라우저를 통해 페이지를 이동하는 순간 텍스트 기반 메시지로 웹 서버에 요청을 보내게 되는데, 이 메시지 형식을 http 메시지 라고 합니다.

 대부분 웹 서버는 응답용 http 메시지에 HTML이나 CSS, 자바 스크립트, 이미지 등을 담아 보냅니다.

> ###### http 메시지 구조
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

위는 http 메시지 예시로 구조가 간단하여 분석이 쉽습니다.

- 첫번째 줄은 `라인`입니다. POST 방식으로 어떤 경로에 요청을 보내야 하는지, 그리고 HTTP 버전이 따라옵니다.

- 두번째 줄 부터 `헤더`이고 공백을 만나면 그 아래로는 바디입니다. 헤더는 key-value 형태로 구성되며 위의 예제는 Host와 Content-Type을 가지고있습니다.

Content-Type의 `application/x-www-form-urlencoded`는 우리가 알고있는 일반적인 방식으로 전송하라는 의미입니다. 만약 바디에 json 형태로 요청을 보내야한다면 `application/json`으로 보내야 합니다.

- 공백 다음 줄 부터 바디입니다. 
