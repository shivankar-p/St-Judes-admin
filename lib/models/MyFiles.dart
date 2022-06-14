import '../constants.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';


class CloudStorageInfo {
  final String? title, totalStorage;
  final int? numOfFiles, percentage;
  final Color? color;
  final icon;

  CloudStorageInfo({
    this.icon,
    this.title,
    this.totalStorage,
    this.numOfFiles,
    this.percentage,
    this.color,
  });
}

List demoMyFiles = [
  CloudStorageInfo(
    title: "Active Requests",
    numOfFiles: 1328,
    icon: Icon(Icons.help_center, size: 60),
    totalStorage: "5",
    color: primaryColor,
    percentage: 35,
  ),
  CloudStorageInfo(
    title: "Approved Requests",
    numOfFiles: 1328,
    icon: Icon(Icons.verified, size: 60),
    totalStorage: "9",
    color: Color(0xFFFFA113),
    percentage: 35,
  ),
  CloudStorageInfo(
    title: "Successful Counsellings",
    numOfFiles: 1328,
    icon: Icon(Icons.handshake, size: 60,),
    totalStorage: "6",
    color: Color(0xFFA4CDFF),
    percentage: 10,
  ),
  CloudStorageInfo(
    title: "Amount Sanctioned",
    numOfFiles: 5328,
    icon: Icon(Icons.currency_rupee, size: 60,),
    totalStorage: "25,000 INR",
    color: Color(0xFF007EE5),
    percentage: 78,
  ),
];
