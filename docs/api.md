# I"s - eternal me

* [get_is](#get_is)
* [get_day_is](#get_day_is)
* [get_search_is](#get_search_is)
* [add_is](#add_is)
* [error 定義](#error)


## 各 API の URL
下記のルールでアクセス可能とする

    http://is-eternal.me/api/{API名}


## 各 API 解説

<a name="get_is"></a>
### 【get_is】
登録済みの軌跡をランダムに取得する

#### ■ リクエストメソッド
GET

#### ■ リクエストパラメータ
##### - limit (int) (required)
取得する件数

#### ■ 成功時戻り値
    {
		"status": 1,
		"data": [
				{
					"id": 0,
					"uri": "http://xxxxxx",
					"image": "http://is-eternal.me/images/screen/xxxxx.jpg",
					"date": "Sunday 30 November 2014 13:59:56",
					"indicator": 0,
					"farame": 60,
					"positions": [
						{
							x: 0,
							y: 0
						},
						{
							x: 0,
							y: 0
						}
					]
				},
				{
					"id": 1,
					"uri": "http://xxxxxx",
					"date": "Sunday 30 November 2014 13:59:56",
					"image": "http://is-eternal.me/images/screen/xxxxx.jpg",
					"indicator": 0,
					"farame": 60,
					"positions": [
						{
							x: 0,
							y: 0
						},
						{
							x: 0,
							y: 0
						}
					]
				}
			]
    }

data[0].id (int): 登録されている軌跡のID  
data[0].uri (string): 登録時に閲覧していたサイトのURI  
data[0].image (string): 登録時に閲覧していたサイトのスクリーンショット  
data[0].date (string): 登録時の時間  
date[0].indicator: 軌跡の再生位置  
date[0].frame: 軌跡のトータルフレーム  
date[0].positions.x: 軌跡の x座標  
date[0].positions.y: 軌跡の y座標

#### エラーパターン
* 500: Internal Server Error
* 400: Bad Request
* 404: Not Found（アイテムが見つからない場合）


***
<a name="get_day_is"></a>
### 【get_day_is】
特定の日付に登録されて軌跡を取得する

#### ■ リクエストメソッド
GET

#### ■ リクエストパラメータ
##### - year (int) (required)
取得対象の年
##### - month (int) (required)
取得対象の月
##### - year (int) (required)
取得対象の日付

#### ■ 成功時戻り値
    {
		"status": 1,
		"data": [
				{
					"id": 0,
					"uri": "http://xxxxxx",
					"image": "http://is-eternal.me/images/screen/xxxxx.jpg",
					"date": "Sunday 30 November 2014 13:59:56",
					"indicator": 0,
					"farame": 60,
					"positions": [
						{
							x: 0,
							y: 0
						},
						{
							x: 0,
							y: 0
						}
					]
				},
				{
					"id": 1,
					"uri": "http://xxxxxx",
					"date": "Sunday 30 November 2014 13:59:56",
					"image": "http://is-eternal.me/images/screen/xxxxx.jpg",
					"indicator": 0,
					"farame": 60,
					"positions": [
						{
							x: 0,
							y: 0
						},
						{
							x: 0,
							y: 0
						}
					]
				}
			]
    }

data[0].id (int): 登録されている軌跡のID  
data[0].uri (string): 登録時に閲覧していたサイトのURI  
data[0].image (string): 登録時に閲覧していたサイトのスクリーンショット  
data[0].date (string): 登録時の時間  
date[0].indicator: 軌跡の再生位置  
date[0].frame: 軌跡のトータルフレーム  
date[0].positions.x: 軌跡の x座標  
date[0].positions.y: 軌跡の y座標

#### エラーパターン
* 500: Internal Server Error
* 400: Bad Request
* 404: Not Found（アイテムが見つからない場合）


***
<a name="get_search_is"></a>
### 【get_search_is】
特定IDの軌跡を取得する

#### ■ リクエストメソッド
GET

#### ■ リクエストパラメータ
##### - id (int) (required)
取得対象のID

#### ■ 成功時戻り値
    {
		"status": 1,
		"data": 
			{
				"id": 0
				"uri": "http://xxxxxx",
				"image" "http://is-eternal.me/images/screen/xxxxx.jpg",
				"date": "Sunday 30 November 2014 13:59:56",
				"indicator": 0,
				"farame": 60,
				"positions": [
					{
						x: 0,
						y: 0
					},
					{
						x: 0,
						y: 0
					}
				]
			}				
    }

data[0].id (int): 登録されている軌跡のID  
data[0].uri (string): 登録時に閲覧していたサイトのURI  
data[0].image (string): 登録時に閲覧していたサイトのスクリーンショット  
data[0].date (string): 登録時の時間  
date[0].indicator: 軌跡の再生位置  
date[0].frame: 軌跡のトータルフレーム  
date[0].positions.x: 軌跡の x座標  
date[0].positions.y: 軌跡の y座標

#### エラーパターン
* 500: Internal Server Error
* 400: Bad Request
* 404: Not Found（アイテムが見つからない場合）


***
<a name="add_is"></a>
### 【add_is】
軌跡のデータを保存する  

#### ■ リクエストメソッド
POST

#### ■ リクエストパラメータ

##### - uri (string) (required)
登録時に閲覧していたサイトのURI  

##### - image (string) (required)
JPEG画像を base64 エンコードした文字列  

##### - positions (object) (required)
軌跡の座標 `{ [x: (int), y: (int)] }`

#### ■ 成功時戻り値（ログイン）
    {
		"status": 1
    }

#### エラーパターン
* 500: Internal Server Error
* 400: Bad Request


***
<a name="error"></a>
### 【error 定義】

#### ■ エラーコード定義

400: Bad Request  
404: Not Found  
500: Internal Server Error  
999: その他原因不明なエラー  

#### ■ エラーレスポンス定義

    {
		"status": 0,
		"data": {
			"error_code": 400,
			"error_message": "validation error."
			"validation": {
				"id": [
					"idを指定してください"
				]
			}
		}
    }

	// error_code (int): エラーコード
	// error_message (string): エラーメッセージ
	// validation (object): バリデーション内容を収めたオブジェクト