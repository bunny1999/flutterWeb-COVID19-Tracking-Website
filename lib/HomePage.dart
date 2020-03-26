import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String url="https://api.rootnet.in/covid19-in/stats/daily";
  bool _isLoding=true;
  var todayData;
  ScrollController _scrollController;
  bool _atMaxPos=false;
  bool _scrolling=false;
  List states;
  @override
  void initState(){
    super.initState();
    this.getApiData();
    _scrollController=new ScrollController();
    _scrollController.addListener(listenScroll);
  }

  listenScroll(){
    if(_scrollController.offset==_scrollController.position.minScrollExtent){
      setState(() {
        _atMaxPos=false;
        _scrolling=false;
      });
    }else if(_scrollController.offset==_scrollController.position.maxScrollExtent){
      setState(() {
        _atMaxPos=true;
      });
    }else{
      setState(() {
        _atMaxPos=false;
        _scrolling=true; 
      });
    }
  }
  
  Future getApiData() async{
    var responce=await http.get(Uri.encodeFull(url));
    List data=jsonDecode(responce.body)["data"];
    states=data[data.length-1]["regional"];
    for(int i=1;i<=states.length;i++){
      for(int j=0;j<states.length-i;j++){
        if(states[j]["confirmedCasesIndian"]<states[j+1]["confirmedCasesIndian"]){
          var temp=states[j];
          states[j]=states[j+1];
          states[j+1]=temp;
        }
      }
    }
    setState(() {
      todayData=data[data.length-1];
      _isLoding=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CORONA TRACKER",textScaleFactor: 1.1,style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
        centerTitle:true,
      ),
      body: _isLoding 
      ?Center(child: CircularProgressIndicator(backgroundColor: Colors.black))
      :Container(
        color: Color.fromRGBO(227, 238, 241, 1.0),
        // decoration: BoxDecoration(
        //   gradient:LinearGradient(colors: [Colors.deepOrange,Colors.black]) 
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:<Widget>[
            GestureDetector(
              onVerticalDragStart: (context){
                setState(() {
                  _scrolling=true;
                });
              },
              child: Container(
                child: Column(children: <Widget>[
                  !_scrolling?Card(
                    elevation: 2.0,
                    child: Container(
                      padding: EdgeInsets.only(top:MediaQuery.of(context).size.height/20.0),
                      color: Color.fromRGBO(227, 238, 241, 1.0),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      height: 3*(MediaQuery.of(context).size.height/20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:<Widget>[
                          Column(children: <Widget>[
                            Text("Total Cases",textScaleFactor: 1.4,style: TextStyle(fontWeight:FontWeight.bold),),
                            Text(todayData["summary"]["total"].toString(),textScaleFactor: 1.4,style: TextStyle(fontWeight:FontWeight.bold)),
                          ],),
                          Column(children: <Widget>[
                            Text("Indians",textScaleFactor: 1.1,style: TextStyle(fontWeight:FontWeight.bold),),
                            Text(todayData["summary"]["confirmedCasesIndian"].toString(),),
                          ],),
                          Column(children: <Widget>[
                            Text("Foreigners",textScaleFactor: 1.1,style: TextStyle(fontWeight:FontWeight.bold),),
                            Text(todayData["summary"]["confirmedCasesForeign"].toString(),),
                          ],),
                        ]
                      ),
                    ),
                  ):Container(),
                  Card(
                    elevation: 2.0,
                    color: Color.fromRGBO(227, 238, 241, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width:(MediaQuery.of(context).size.width-(147))*0.3,
                            child: Text("State",style: TextStyle(fontWeight:FontWeight.bold),)),
                          Container(
                            width:(MediaQuery.of(context).size.width-(147))/5,
                            child: Text("Cases",style: TextStyle(fontWeight:FontWeight.bold),),),
                          Container(
                            width:(MediaQuery.of(context).size.width-(147))/5,
                            child: Text("Active",style: TextStyle(fontWeight:FontWeight.bold),)),
                          Container(
                            width:(MediaQuery.of(context).size.width-(147))/5,
                            child: Text("Deaths",style: TextStyle(fontWeight:FontWeight.bold),),),
                          Container(
                            width:(MediaQuery.of(context).size.width-(147))/5,
                            child: Text("Cured",style: TextStyle(fontWeight:FontWeight.bold),)),
                        ],
                      ),
                    ),
                  ),
                ],),
              ),
            ),
            Expanded(
              child:Card(
                elevation: 2.0,
                color: Color.fromRGBO(227, 238, 241, 1.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: states.length,
                    itemBuilder: (BuildContext context,int i){
                      int totalCase=states[i]["confirmedCasesIndian"];
                      int activeCase=totalCase-states[i]["discharged"];
                      return Column(
                        children: <Widget>[
                          Container(
                            child:Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                              Container(
                                width:(MediaQuery.of(context).size.width-(147))*0.3,
                                child: Text(states[i]["loc"])),
                              Container(
                                width:(MediaQuery.of(context).size.width-(147))/5,
                                child: Text(totalCase.toString())),
                              Container(
                                width:(MediaQuery.of(context).size.width-(147))/5,
                                child: Text(activeCase.toString())),
                              Container(
                                width:(MediaQuery.of(context).size.width-(147))/5,
                                child: Text(states[i]["deaths"].toString())),
                              Container(
                                width:(MediaQuery.of(context).size.width-(147))/5,
                                child: Text(states[i]["discharged"].toString())),
                            ],)
                          ),
                          Divider(color:Colors.transparent)
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),
            _atMaxPos?Container(height:MediaQuery.of(context).size.height/20.0):Container()
          ]
        ),
      ),
      bottomSheet: _atMaxPos?BottomAppBar(
        child: Container(
          color: Color.fromRGBO(52, 58, 64, 1.0),
          height: MediaQuery.of(context).size.height/20.0,
          padding: EdgeInsets.only(top:5.0),
          width: MediaQuery.of(context).size.width,
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () async{
                  await launch("https://www.instagram.com/_bunny1999/");
                },
                child: Text.rich(
                  TextSpan(
                    text: 'Made By:',
                    style: TextStyle(color: Colors.white),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sourav Singh Rawat',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue
                        )
                      ),
                    ],
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Data API:',
                  style: TextStyle(color: Colors.white),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'The Ministry of Health and Family Welfare',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ):Container(height: 0.0,),
    );
  }
}