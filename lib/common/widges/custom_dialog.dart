part of widget;

class CustomDialog extends StatelessWidget {
  final Widget screen;
  final bool bottom;
  final bool cancelable;
  final List<KeyboardActionsItem>? actions;

  const CustomDialog({required this.screen,
    this.bottom = false,
    this.cancelable = true,
    this.actions});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      allowPop: cancelable,
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              GestureDetector(
                onTap: cancelable ? () => CustomNavigator.pop(context) : null,
              ),
              Column(
                mainAxisAlignment:
                bottom ? MainAxisAlignment.end : MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.sizeOf(context).width - (10.0 * 2),
                    margin:
                    EdgeInsets.symmetric(horizontal: 20.0),
                    child: screen,
                  )
                ],
              )
            ],
          ),
        ),
      ),
      actions: actions ?? [],
    );
  }
}