# vi:filetype=

use t::OpenResty;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a model
--- request
POST /=/model/Carrie.js
{
    "description": "我的书签",
    "columns": [
        { "name": "title", "type":"text", "label": "标题" },
        { "name": "url", "type":"text", "label": "网址" }
    ]
}
--- response
{"success":1}



=== TEST 3: check the model list again
--- request
GET /=/model.js
--- response
[{"src":"/=/model/Carrie","name":"Carrie","description":"我的书签"}]



=== TEST 4: insert a record 
--- request
POST /=/model/Carrie/~/~.js
{ "title":"hello carrie","url":"http://www.carriezh.cn/index.html#"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/1"}



=== TEST 5: insert another record
--- request
POST /=/model/Carrie/~/~.js
{"title":"second","url":"http://zhangxiaojue.cn/test.php?p=mp3&t=web"}
--- response
{"success":1,"rows_affected":1,"last_row":"/=/model/Carrie/id/2"}



=== TEST 6: read all the records
--- request
GET /=/model/Carrie/~/~
--- response
[{"url":"http://www.carriezh.cn/index.html#","title":"hello carrie","id":"1"},{"url":"http://zhangxiaojue.cn/test.php?p=mp3&t=web","title":"second","id":"2"}]



=== TEST 7: read a record according to url
--- request
GET /=/model/Carrie/url/http://www.carriezh.cn/index.html%23
--- response
[{"url":"http://www.carriezh.cn/index.html#","title":"hello carrie","id":"1"}]



=== TEST 8: read a record according to url
--- request
GET /=/model/Carrie/url/http://zhangxiaojue.cn/test%2Ephp%3Fp%3Dmp3%26t%3Dweb
--- response
[{"url":"http://zhangxiaojue.cn/test.php?p=mp3&t=web","title":"second","id":"2"}]



=== TEST 9: READ a record use 'contains'
--- request
GET /=/model/Carrie/url/zhangxiaojue?_op=contains
--- response
[{"url":"http://zhangxiaojue.cn/test.php?p=mp3&t=web","title":"second","id":"2"}]



=== TEST 10: logout
--- request
GET /=/logout
--- response
{"success":1}

