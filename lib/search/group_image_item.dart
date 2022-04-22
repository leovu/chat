import 'package:chat/search/detail_group_image_screen.dart';
import 'package:flutter/material.dart';

class GroupImageItem extends StatelessWidget {
  const GroupImageItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DetailGroupImageScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(8.0)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2 - 16.0,
              height: MediaQuery.of(context).size.width / 4,
              decoration: const BoxDecoration(
                color: Colors.lightGreen,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0),
                  )),
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(8.0),
              //   child: CachedNetworkImage(imageUrl: "",),
              // ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: const Text(
                'An An',
                style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w400),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                '26 photos',
                style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}