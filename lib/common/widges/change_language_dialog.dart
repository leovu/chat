// /*
// * Created by: nguyenan
// * Created at: 2024/05/03 09:24
// */
// part of widget;
//
// class ChangLanguageDialog extends StatelessWidget {
//   ChangLanguageDialog();
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       contentPadding: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(5.0))),
//       content: Container(
//           decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: new BorderRadius.all(Radius.circular(5))),
//           height: 300,
//           padding: EdgeInsets.symmetric(vertical: 16, horizontal: 27),
//           child: Column(
//             children: <Widget>[
//               Container(
//                 alignment: Alignment.centerLeft,
//                 margin: EdgeInsets.only(bottom: 11),
//                 child: Text(
//                   AppLocalizations.text(LangKey.change_language),
//                   style: AppTextStyles.style18BlackBold,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Divider(),
//               ),
//               Container(
//                   child: Row(
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8.0, right: 12.0),
//                         child: Image.asset(
//                           'assets/icon_-zalo.png',
//                           width: 30.0,
//                           height: 30.0, fit: BoxFit.fill,
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           alignment: Alignment.centerLeft,
//                           child: TextButton(
//                             onPressed: () async {
//                               Navigator.of(context, rootNavigator: true).pop();
//                             },
//                             child: Container(
//                                 child: Text(
//                                   'English',
//                                   style: AppTextStyles.style14BlackWeight500,
//                                 )),
//                           ),
//                         ),
//                       )
//                     ],
//                   )),
//               Divider(),
//               Container(
//                   child: Row(
//                     children: <Widget>[
//                       Padding(
//                         padding:
//                         const EdgeInsets.only(left: 8.0, right: 12.0),
//                         child: Image.asset(
//                           'assets/icon_-zalo.png',
//                           width: 30.0,
//                           height: 30.0, fit: BoxFit.fill,
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           alignment: Alignment.centerLeft,
//                           child: TextButton(
//                             onPressed: () async {
//                               Navigator.of(context, rootNavigator: true)
//                                   .pop();
//                             },
//                             child: Container(
//                                 child: Text(
//                                   'Tiếng Việt',
//                                   style: AppTextStyles.style14BlackWeight500,
//                                 )),
//                           ),
//                         ),
//                       )
//                     ],
//                   )),
//             ],
//           )),
//     );
//   }
// }