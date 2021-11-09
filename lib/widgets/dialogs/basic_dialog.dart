import 'package:flutter/material.dart';
import 'package:video_processor/widgets/buttons/common_button.dart';

class BasicDialog extends StatelessWidget {
  final String headerText;
  final String contentText;
  final String actionButtonText;
  final Function action;
  final String action2ButtonText;
  final Function action2;

  final bool useCancel;

  const BasicDialog({
    Key key,
    this.headerText,
    this.contentText,
    @required this.actionButtonText,
    this.useCancel = false,
    @required this.action,
    this.action2ButtonText,
    this.action2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 21),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //Header
            if (headerText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(headerText,
                    // style: TextStyles.cardHeaderTextStyle,
                ),
              ),
            //Content
            if (contentText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  contentText,
                  // style: TextStyles.cardContentTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            //Buttons
            Padding(
              padding: const EdgeInsets.only(top: 29),
              child: _buildButtonsRow(context),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildButtonsRow(BuildContext context) {
    if (action2ButtonText != null) {
      //build action1 and action2 buttons
      return Row(
        children: <Widget>[
          Expanded(
            child: _buildActionButton(context, action, actionButtonText),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _buildActionButton(context, action2, action2ButtonText),
          ),
        ],
      );
    }

    if (useCancel) {
      //build action1 and cancel button
      return Row(
        children: <Widget>[
          Expanded(
            child: _buildActionButton(context, action, actionButtonText),
          ),
          SizedBox(width: 20),
          Expanded(
            child: _buildCancelButton(context),
          ),
        ],
      );
    }

    //show only action1 button
    return Row(

      children: <Widget>[
        Spacer(),
        Expanded(
          flex: 2,
          child: _buildActionButton(context, action, actionButtonText),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Function buttonAction, String label) => CommonButton(
    onClick: () {
      buttonAction();
      Navigator.of(context).pop();
    },
    buttonText: label,
  );

  Widget _buildCancelButton(BuildContext context) => CommonButton(
    onClick: () => Navigator.of(context).pop(),
    buttonText: 'Cancel',
  );
}
