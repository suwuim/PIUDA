import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookStateReview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 뒤로가기 동작
            Navigator.pop(context);
          },
          color: Colors.black, // 뒤로가기 버튼의 색상
        ),
        title: Text(
          '서적 상태 평가',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black, // 글자색 설정
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top:20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/파피용.jpg', // 사진 경로
                  fit: BoxFit.cover, // 사진의 크기 조절 방식
                  height: 200.0,
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15, top: 8),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오염도',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  child: RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) {
                      return Icon(
                        Icons.star,
                        color: Colors.amber.shade400,
                        size: 15, // 별 크기 조절
                      );
                    },
                    onRatingUpdate: (rating) {
                      // 별점이 업데이트될 때의 로직을 추가할 수 있습니다.
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15, top: 7),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '손실도',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.0),
                Container(
                  child: RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) {
                      return Icon(
                        Icons.star,
                        color: Colors.amber.shade400,
                        size: 15, // 별 크기 조절
                      );
                    },
                    onRatingUpdate: (rating) {
                      // 별점이 업데이트될 때의 로직을 추가할 수 있습니다.
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15, right: 15, top: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기타의견',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.0),
                TextField(
                  maxLines: 3, // 여러 줄 입력 가능하도록 설정
                  decoration: InputDecoration(
                    hintText: '의견을 입력하세요...',
                    border: OutlineInputBorder(), // 외곽선 추가
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // '등록' 버튼을 눌렀을 때의 동작 정의
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.cyan.shade800, // 버튼의 배경색을 파란색으로 설정
            ),
            child: Text('등록'),
          ),
        ],
      ),
    );
  }
}