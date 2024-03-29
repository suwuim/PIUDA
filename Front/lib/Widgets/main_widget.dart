import 'package:flutter/material.dart';
import 'package:piuda/NewBooksPage.dart';
import '../main.dart';
import '../LoginPage.dart';
import 'package:http/http.dart' as http;
import 'package:piuda/BookSearch.dart';
import 'dart:convert';
import '../Utils/BookUtils.dart';
import 'package:piuda/BookDetail.dart';
import 'package:piuda/RecommendBooksPage.dart';
import 'package:piuda/Widgets/bookcontainer_widget.dart';

class MyPageView extends StatefulWidget {
  final GlobalKey<MyPageViewState> myPageViewStateKey = GlobalKey<MyPageViewState>();
  final Function(String) onLibraryChanged; // 추가된 콜백

  MyPageView({Key? key, required this.onLibraryChanged}) : super(key: key);


  @override
  MyPageViewState createState() => MyPageViewState();

}


class MyPageViewState extends State<MyPageView> {
  late PageController _pageController;
  int _currentPageIndex = 999;
  String library = '';
  bool _isMounted = false;

  void updateLibrary(String newLibrary) {
    //print("updateLibrary 호출됨: $newLibrary");
    if (library != newLibrary) {
      setState(() {
        library = newLibrary;
        fetchMainNewBooks(library);
      });
      // onLibraryChanged 콜백 호출
      widget.onLibraryChanged(newLibrary);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
    _pageController.addListener(_pageListener);
    _isMounted = true; // 상태가 마운트된 것으로 설정
    library = '성동구립도서관';
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.wait([
      fetchMainNewBooks(library),
      fetchMainRecommendBooks(),
    ]);
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    _isMounted = false; // 상태가 언마운트된 것으로 설정
    super.dispose();
  }

  void _pageListener() {
    if (_isMounted) { // 상태가 마운트된 경우에만 setState() 호출
      setState(() {
        _currentPageIndex = _pageController.page!.round();
      });
    }
  }

  //신착도서3개
  String _newimageUrl = '';
  List<BookContainer> _newbookMainWidget = [];
  Future<void> fetchMainNewBooks(String selectedLibrary) async {
    try {
      String url = 'http://34.64.173.65:8080/newbooks/latest/$selectedLibrary';

      final response = await http.get(Uri.parse(url));
      //print('선택된도서관:$selectedLibrary');

      if (response.statusCode == 200) {
        final List<dynamic> newBooksData = jsonDecode(utf8.decode(response.bodyBytes));
        List<BookContainer> newBooks = [];

        setState(() {
          _newimageUrl = '';
        });

        for (var i = 0; i < newBooksData.length && i < 3; i++) {
          var bookData = newBooksData[i];
          String _imageUrl = await BookUtils.fetchBookCover(bookData['book']['book_isbn']);

          newBooks.add(BookContainer(
            book_id: bookData['book']['id'] ?? '',
            imageUrl: _imageUrl,
            bookTitle: bookData['book']['title'] ?? '',
            author: bookData['book']['author'] ?? '',
            library: bookData['book']['library'] ?? '',
            publisher: bookData['book']['publisher'] ?? '',
            location: bookData['book']['location'] ?? '',
            loanstatus: !bookData['book']['borrowed'],
            book_isbn: bookData['book']['book_isbn'] ?? '',
            reserved: bookData['book']['reserved'],
            size: bookData['book']['size'] ?? '',
            price: bookData['book']['price'] ?? 0,
            classification: bookData['book']['classification'] ?? '',
            media: bookData['book']['media'] ?? '',
            field_name: bookData['book']['field_name'] ?? '',
            book_ii: bookData['book']['book_ii'] ?? '',
            series: bookData['book']['series'] ?? '',
            onReservationCompleted: () {
              // 예약이 완료되었을 때 수행할 작업을 여기에 추가
            },
            recommender: null,
          ));
        }
        setState(() {
          _newbookMainWidget = newBooks;
        });
      } else {
        print('Failed to fetch new books for library $selectedLibrary: ${response.statusCode}');

      }
    } catch (e) {
      if (_isMounted) { // 상태가 마운트된 경우에만 setState() 호출
        setState(() {
          print('Error fetching new books: $e');
        });
      }
    }
  }

  //추천도서 3개
  String _recommendimageUrl = '';
  List<BookContainer> _recommendbookMainWidget = [];
  Future<void> fetchMainRecommendBooks() async {
    try {
      String url = 'http://34.64.173.65:8080/recommendbooks/latest';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> recommendBooksData = jsonDecode(utf8.decode(response.bodyBytes));
        List<BookContainer> recommendBooks = [];

        setState(() {
          _recommendimageUrl = '';
        });

        for (var i = 0; i < recommendBooksData.length && i < 3; i++) {
          var bookData = recommendBooksData[i];
          String _imageUrl = await BookUtils.fetchBookCover(bookData['book']['book_isbn']);

          recommendBooks.add(BookContainer(
            book_id: bookData['book']['id'] ?? '',
            imageUrl: _imageUrl,
            bookTitle: bookData['book']['title'] ?? '',
            author: bookData['book']['author'] ?? '',
            library: bookData['book']['library'] ?? '',
            publisher: bookData['book']['publisher'] ?? '',
            location: bookData['book']['location'] ?? '',
            loanstatus: !bookData['book']['borrowed'],
            book_isbn: bookData['book']['book_isbn'] ?? '',
            reserved: bookData['book']['reserved'],
            size: bookData['book']['size'] ?? '',
            price: bookData['book']['price'] ?? 0,
            classification: bookData['book']['classification'] ?? '',
            media: bookData['book']['media'] ?? '',
            field_name: bookData['book']['field_name'] ?? '',
            book_ii: bookData['book']['book_ii'] ?? '',
            series: bookData['book']['series'] ?? '',
            onReservationCompleted: () {
            },
            recommender: null,
          ));
        }
        setState(() {
          _recommendbookMainWidget = recommendBooks;
        });
      } else {
        print('Failed to fetch recommend books}');
      }
    } catch (e) {
      if (_isMounted) { // 상태가 마운트된 경우에만 setState() 호출
        setState(() {
          print('Error fetching recommend books: $e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Row(
      children: [
        GestureDetector(
          onTap: () {_goToPreviousPage();
          },
          child: Container(margin: EdgeInsets.only(top: 5),
              height:screenSize.height*0.075, width: screenSize.width*0.08,
              decoration: BoxDecoration(color: Colors.cyan.shade800, border: Border.symmetric(horizontal: BorderSide(color: Colors.cyan.shade900, width: 2.5))),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white)
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.28, //0.265 ~ 0.27
          width: screenSize.width * 0.84,
          child: buildPageView(),
        ),
        GestureDetector(
          onTap: () {_goToNextPage();},
          child: Container(margin: EdgeInsets.only(top: 5),
              height:screenSize.height*0.075, width: screenSize.width*0.08,
              decoration: BoxDecoration(color: Colors.cyan.shade800, border: Border.symmetric(horizontal: BorderSide(color: Colors.cyan.shade900, width: 2.5))),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white)
          ),
        ),
      ],
    );
  }

  Widget buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) {
        return buildContent(index % 3 + 1);
      },
      itemCount: 3000, // Set a large number of items to enable infinite scrolling
    );
  }

  Widget buildContent(int pageIndex) {
    Size screenSize = MediaQuery.of(context).size;
    final textSize = MediaQuery.textScalerOf(context);
    switch (pageIndex) {
      case 1:
        return Container(
          margin: EdgeInsets.only(top: 5, bottom: 3, left: 0.0, right: 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: Colors.cyan.shade900,
              width: 3.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
            children: [
              Container(
                  decoration: BoxDecoration(color: Colors.cyan.shade800, border: Border(bottom: BorderSide(color: Colors.cyan.shade900, width: 2))),
                  height: screenSize.height*0.095,
                  width: screenSize.width * 0.84,
                  padding: EdgeInsets.only(left: 15,),
                  child:
                  (MyApp.isLoggedIn != true)?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("모바일 회원증", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: textSize.scale(17)),),
                      Text("로그인 후 이용 가능한 서비스입니다", style: TextStyle(color: Colors.white, fontSize: textSize.scale(15)),)
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text("이름 ", style: TextStyle(color: Colors.white, fontSize: textSize.scale(18)),),
                          Text("${MyApp.userName}", style: TextStyle(color: Colors.white70, fontSize: textSize.scale(18)),),
                        ],
                      ),
                      Row(
                        children: [
                          Text("회원번호 ", style: TextStyle(color: Colors.white, fontSize: textSize.scale(18)),),
                          Text("${MyApp.userId}", style: TextStyle(color: Colors.white70, fontSize: textSize.scale(18)),),
                        ],
                      ),              ],
                  )
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                  child: (MyApp.isLoggedIn == true && MyApp.barcodeImageUrl != null) ?
                  Image.network(
                    MyApp.barcodeImageUrl!,
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  )
                      :Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          ).then((result) {
                            // 로그인 페이지에서 반환된 데이터 처리
                            if (result != null && result['isLoggedIn']) {
                              setState(() {
                                MyApp.isLoggedIn = result['isLoggedIn'];
                                MyApp.userName = result['username'];
                                MyApp.userId = result['userId'];
                                // 필요한 경우 여기에서 추가 UI 업데이트 로직을 구현합니다.
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.cyan.shade900,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.cyan.shade800, width: 1.5),
                          ),
                        ),
                        child: Text('로그인하러 가기', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 2:
        return Container(
          margin: EdgeInsets.only(top: 5, bottom: 3, left: 0.0, right: 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: Colors.cyan.shade900,
              width: 3.0,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => recommendbookspage()),
                  );
                },
                child: Container(
                  width: screenSize.width*0.07,
                  height: double.maxFinite,
                  decoration: BoxDecoration(
                      color: Colors.cyan.shade800,
                      border: Border(right: BorderSide(color: Colors.cyan.shade900, width: 2))
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text('추천 도서', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                      Icon(Icons.menu_open, color: Colors.white, )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container( //책정보박스
                  //decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.red)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _recommendbookMainWidget.map((book) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetail(book_id: book.book_id),
                            ),
                          );
                        },
                        child: Container(
                          //decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.green)),
                          height: screenSize.height*0.27,
                          width: screenSize.width * 0.84*0.27,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(book.imageUrl, height: screenSize.height*0.27*0.67),
                              Text(book.bookTitle, softWrap: true, style: TextStyle(fontSize: textSize.scale(10)), overflow: TextOverflow.ellipsis),
                              Text(book.author, style: TextStyle(color: Colors.grey.shade600, fontSize: textSize.scale(10)), overflow: TextOverflow.ellipsis)
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
        );
      case 3:
        return Container(
          margin: EdgeInsets.only(top: 5, bottom: 3, left: 0.0, right: 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: Colors.cyan.shade900,
              width: 3.0,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => newbookspage()),
                  );
                },
                child: Container(
                  width: screenSize.width*0.07,
                  height: double.maxFinite,
                  decoration: BoxDecoration(
                      color: Colors.cyan.shade800,
                      border: Border(right: BorderSide(color: Colors.cyan.shade900, width: 2))
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text('신착 도서', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                      Icon(Icons.menu_open, color: Colors.white, )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container( //책정보박스
                  //decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.red)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _newbookMainWidget.map((book) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetail(book_id: book.book_id),
                            ),
                          );
                        },
                        child: Container(
                          //decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.green)),
                          height: screenSize.height*0.27,
                          width: screenSize.width * 0.84*0.27,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(book.imageUrl, height: screenSize.height*0.27*0.67),
                              Text(book.bookTitle, softWrap: true, style: TextStyle(fontSize: textSize.scale(10)), overflow: TextOverflow.ellipsis),
                              Text(book.author, style: TextStyle(color: Colors.grey.shade600, fontSize: textSize.scale(10)), overflow: TextOverflow.ellipsis)
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
        );
      default:
        return Container();
    }
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
