/*
* Created by: nguyenan
* Created at: 2024/04/26 10:22
*/
part of widget;

class CommonAvatar extends StatelessWidget {
  Rooms data;
  CommonAvatar(this.data);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        !data.isGroup! ? data.owner!.picture == null ? CircleAvatar(
          radius: 25.0,
          child: Text(
            data.owner!.getAvatarName(),
            style: const TextStyle(color: Colors.white),),
        ) : CircleAvatar(
          radius: 25.0,
          backgroundImage:
          CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${data.shieldedID}/256/${ChatConnection.brandCode!}',headers: {'brand-code':ChatConnection.brandCode!}),
          backgroundColor: Colors.transparent,
        ) : data.picture == null ? CircleAvatar(
          radius: 25.0,
          child: Text(
            data.getAvatarGroupName(),
            style: const TextStyle(color: Colors.white),),
        ) : CircleAvatar(
          radius: 25.0,
          backgroundImage:
          CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${data.picture!.shieldedID}/256/${ChatConnection.brandCode!}',headers: {'brand-code':ChatConnection.brandCode!}),
          backgroundColor: Colors.transparent,
        ),
        if(data.source != null) Positioned(
            bottom: 0.0,
            child:
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0)
                ),
                child: Image.asset(data.source == 'zalo' ? 'assets/icon-zalo.png' : 'assets/icon-facebook.png',
                  package: 'chat',width: 25.0,height: 25.0,),
              ),
            )),
      ],
    );
  }
}