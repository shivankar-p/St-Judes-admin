import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'chart.dart';
import 'storage_info_card.dart';

class StarageDetails extends StatelessWidget {
  const StarageDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Language Distribution",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black
            ),
          ),
          SizedBox(height: defaultPadding),
          Chart(),
          StorageInfoCard(
            svgSrc: Icon(
              Icons.language,
              color: primaryColor,
            ),
            title: "Hindi",
            amountOfFiles: "44%",
          ),
          StorageInfoCard(
            svgSrc: Icon(
              Icons.language,
              color: Color(0xFF26E5FF),
            ),
            title: "Bengali",
            amountOfFiles: "23%",
          ),
          StorageInfoCard(
            svgSrc: Icon(
              Icons.language,
              color: Color(0xFFFFCF26),
            ),
            title: "Marathi",
            amountOfFiles: "13%",
          ),
          StorageInfoCard(
            svgSrc: Icon(
              Icons.language,
              color: Color(0xFFEE2727),
            ),
            title: "Telugu",
            amountOfFiles: "12%",
          ),
          StorageInfoCard(
            svgSrc: Icon(
              Icons.language,
              color: primaryColor.withOpacity(0.1),
            ),
            title: "Tamil",
            amountOfFiles: "8%",
          )
        ],
      ),
    );
  }
}
