#!/bin/sh

#  Script.sh
#  Fidelity3
#
#  Created by JiangNan on 2018/11/3.
#  Copyright © 2018 Fidelity Investments. All rights reserved.


curl -i -X GET \
-H "Authorization: OAuth" \
-H "oauth_consumer_key: A1AC63F0332A131A78FAC304D007E7D1" \
-H "oauth_token: 206ED521E5552AB32EF768A2B1CCB64C" \
-H "oauth_signature_method: PLAINTEXT" \
-H "oauth_version: 1.0" \
-H "oauth_timestamp: 1541210708" \
-H "oauth_nonce: 2rQiz7" \
-H "oauth_signature: EC7F18B17A062962C6930A8AE88B16C7%261EB57D8A2A05AF0795F0FC17DD58C187" \
-H "Content-Type: application/x-www-form-urlencoded" \
'https://api.tmsandbox.co.nz/v1/Search/General.json'


OAuth Token: 206ED521E5552AB32EF768A2B1CCB64C
OAuth Token Secret: 1EB57D8A2A05AF0795F0FC17DD58C187

Request header:
key Authorization
value OAuth oauth_consumer_key="A1AC63F0332A131A78FAC304D007E7D1",oauth_token="206ED521E5552AB32EF768A2B1CCB64C",oauth_signature_method="PLAINTEXT",oauth_timestamp="1541210708",oauth_nonce="2rQiz7",oauth_version="1.0",oauth_signature="EC7F18B17A062962C6930A8AE88B16C7%261EB57D8A2A05AF0795F0FC17DD58C187"


let time = Date()
print(time.timeIntervalSince1970)

curl -i -X GET \
-H "Authorization: OAuth oauth_consumer_key=\"A1AC63F0332A131A78FAC304D007E7D1\",oauth_token=\"206ED521E5552AB32EF768A2B1CCB64C\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"1541210708\",oauth_nonce=\"2rQiz7",oauth_version="1.0",oauth_signature="EC7F18B17A062962C6930A8AE88B16C7%261EB57D8A2A05AF0795F0FC17DD58C187"" \
