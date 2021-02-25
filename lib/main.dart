import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(NasaApp());
}

// Future<Weather> getData() async {
//   var response = await http.get(
//     Uri.encodeFull(
//         "https://api.nasa.gov/insight_weather/?api_key=DEMO_KEY&feedtype=json&ver=1.0"),
//     headers: {
//       "Accept": "application/json",
//     },
//   );

//   if (response.statusCode == 200) {
//     return Weather.fromJson(jsonDecode(response.body));
//   } else {
//     throw Exception("Failed to load");
//   }
// }

Future<Weather> getData() async {
  String data = await rootBundle.loadString("assets/weather.json");
  return Weather.fromJson(jsonDecode(data));
}

class Weather {
  List<String> solKeys;
  List<String> dateWeather;
  List<String> seasonWeather;
  List<double> lowPressure;
  List<double> highPressure;

  Weather({
    this.solKeys,
    this.dateWeather,
    this.seasonWeather,
    this.lowPressure,
    this.highPressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    var solKeysFromJson = json['sol_keys'];

    List<String> weatherList = solKeysFromJson.cast<String>();
    List<String> reversedWeatherList = weatherList.reversed.toList();

    var weatherData = new List();

    json.forEach((key, value) {
      for (int i = 0; i < weatherList.length; i++) {
        if (weatherList[i] == key) {
          weatherData.add(value);
        }
      }
    });

    List<dynamic> reversedWeatherData = weatherData.reversed.toList();

    var dateList = new List<String>();
    var seasonList = new List<String>();
    var lowPressure = new List<double>();
    var highPressure = new List<double>();

    for (int i = 0; i < reversedWeatherList.length; i++) {
      dateList.add(reversedWeatherData[i]['First_UTC']);
      seasonList.add(reversedWeatherData[i]['Season']);
      lowPressure.add(reversedWeatherData[i]['PRE']['mn']);
      highPressure.add(reversedWeatherData[i]['PRE']['mx']);
    }

    print(dateList);
    print(seasonList);
    print(lowPressure);

    return Weather(
      solKeys: reversedWeatherList,
      dateWeather: dateList,
      seasonWeather: seasonList,
      lowPressure: lowPressure,
      highPressure: highPressure,
    );
  }
}

// class DayWeather {
//   DateTime firstUTC;

//   DayWeather({
//     this.firstUTC,
//   });

//   factory DayWeather.fromJson(Map<String, dynamic> json) {
//     return DayWeather(
//       firstUTC: DateTime.parse(json["First_UTC"]),
//     );
//   }
// }

class NasaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nasa Weather App',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Weather> futureData;

  @override
  void initState() {
    super.initState();
    futureData = getData();
  }

  Widget listItem({int index, Weather json}) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Sol ${json.solKeys[index]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                  ),
                  Expanded(
                    child: Text(
                      "High: ${json.highPressure[index].toStringAsFixed(0)} Pa",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "${DateFormat.MMMMd().format(DateTime.parse(json.dateWeather[index]))}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                  ),
                  Expanded(
                    child: Text(
                      "Low: ${json.lowPressure[index].toStringAsFixed(0)} Pa",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            // colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: FutureBuilder<Weather>(
          future: futureData,
          builder: (BuildContext context, AsyncSnapshot<Weather> snapshot) {
            if (snapshot.hasError) {
              print("Error ${snapshot.error}");
              return Container();
            } else if (snapshot.hasData) {
              return Padding(
                padding:
                    EdgeInsets.only(top: 50, bottom: 15, left: 15, right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Latest Weather\nat Elysium Planitia",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "Sol ${snapshot.data.solKeys[0]}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "High: ${snapshot.data.highPressure[0].toStringAsFixed(0)} Pa",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "${DateFormat.MMMMd().format(DateTime.parse(snapshot.data.dateWeather[0]))}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Low: ${snapshot.data.lowPressure[0].toStringAsFixed(0)} Pa",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Previous Days",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 3,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ListView.builder(
                        // scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(top: 0),
                        itemCount: snapshot.data.solKeys.length - 1,
                        itemBuilder: (context, index) {
                          return listItem(
                              json: snapshot.data, index: index + 1);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
