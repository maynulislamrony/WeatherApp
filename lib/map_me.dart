import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
class Map_me extends StatefulWidget {
  const Map_me({Key? key}) : super(key: key);

  @override
  State<Map_me> createState() => _Map_meState();
}

class _Map_meState extends State<Map_me> {


 determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  var s=32 ;

  
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {

    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
  
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  position= await Geolocator.getCurrentPosition();
  getWeatherData();
  print(position);

  print("${position!.latitude} ${position!.longitude}");
}

Position ?position;

Map<String,dynamic> ?weatherMap;
Map<String,dynamic> ?forecastMap;

getWeatherData ()async{
  var weather= await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=a849b3d61b2232a2d5ba202d99554595&units=metric"));
  var forecast=await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=a849b3d61b2232a2d5ba202d99554595&units=metric"));

 setState(() {
    weatherMap=Map<String,dynamic>.from(jsonDecode(weather.body));
  forecastMap=Map<String,dynamic>.from(jsonDecode(forecast.body));
 });

}



  @override
  void initState() {
    determinePosition();
    // TODO: implement initState
  
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return weatherMap !=null ? Scaffold(
      body: Container(
        color: Colors.black,
       
       
        padding: EdgeInsets.all(25),
        width: double.infinity,
        child: Container(
          width: 400,
           decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
           color: Colors.blue,
        ),
          child: Column(
            
            children: [
               Align(
                  alignment: Alignment.center,
                  child: Column(
                    
                    children: [
                           Text("${weatherMap!["name"]}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                           SizedBox(height: 10,),
                       Text("${Jiffy.parse("${DateTime.now()}").format(pattern: 'MMM do yy')}, ${Jiffy.parse("${DateTime.now()}").format(pattern: 'hh:mm a')}",style: TextStyle(fontSize: 20,color: Colors.white)),
               
                    ],
                  ),
                ),
                Image.network("https://openweathermap.org/img/wn/${forecastMap!["list"][0]["weather"][0]["icon"]}@2x.png"),
                  Text("${weatherMap!["weather"][0]["description"]}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white)),
                Text("${weatherMap!["main"]["temp"]}°",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white) ),
        
        
        
             
        
                 Text("Feels Like ${weatherMap!["main"]["feels_like"]}",style: TextStyle(fontSize: 12,color: Colors.white)),
                    
        
                Text("Humidity ${weatherMap!["main"]["humidity"]},Pressure ${weatherMap!["main"]["pressure"]}",style: TextStyle(fontSize: 12,color: Colors.white)),
                
                Text("Sunrise ${Jiffy.parse("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}").format(pattern: "hh: mm a")}, Sunset  ${Jiffy.parse("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)}").format(pattern: "hh: mm a")}",style: TextStyle(fontSize: 12,color: Colors.white))
        
                ,SizedBox(
                  height: 300,
                 child: ListView.builder(
                   shrinkWrap: true,
                   itemCount: forecastMap!.length,
                   scrollDirection: Axis.horizontal,
                   itemBuilder: (context,index){
                     return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                          color:index==0? Colors.black26.withOpacity(1):Colors.amber,
                      ),
                    
                       width: 160,
                       margin: EdgeInsets.only(right: 12),
                       child: Column(
                         children: [
                           Text("${Jiffy.parse("${forecastMap!["list"][index]["dt_txt"]}").format(pattern: "EEE h : mm a")}",style: TextStyle(fontSize: 18,color: Colors.white))
        
                         ,  Image.network("https://openweathermap.org/img/wn/${forecastMap!["list"][index]["weather"][0]["icon"]}@2x.png"),
                           Text("${forecastMap!["list"][index]["main"]["temp_min"]}°",style: TextStyle(fontSize: 12,color: Colors.white)),
                           Text("${forecastMap!["list"][index]["weather"][0]["description"]}",style: TextStyle(fontSize: 12,color: Colors.white)),
                         ],
                       ),
                     );
                   },
                 ),
                )
            ],
          ),
        ),
      )
    ) :Center(child: CircularProgressIndicator());
  }
}