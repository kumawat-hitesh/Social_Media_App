import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
String formatDate(Timestamp timestamp){
  //timestamp is the object we recieve from firebase
  //to displaying it, lets convert it into string
  DateTime dateTime = timestamp.toDate();
  //get year
  String year = dateTime.year.toString();
  //get month
  String month = dateTime.month.toString();
  //get day
  String day = dateTime.day.toString();
  //final formatted date
  String formattedDate = "$day/$month/$year";
  return formattedDate;
}