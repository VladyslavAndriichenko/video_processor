import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  static Future<bool> askPermissions(BuildContext context, List<Permission> permissionList, Function showDialogFunction) async {
    List<Permission> notGrantedPermissionList = [];
    for (int i = 0; i < permissionList.length; i++) {
      bool permissionGranted = await permissionList[i].status.isGranted;
      if (!permissionGranted) {
        notGrantedPermissionList.add(permissionList[i]);
      }
    }

    ///if have not granted permissions
    if (notGrantedPermissionList.length > 0) {
      Map<Permission, PermissionStatus> permissionMapStatus = {};
      ///ask user to agree permissions like a list of them
      permissionMapStatus = await notGrantedPermissionList.request();
      if (permissionMapStatus.length == 0)
        return true;
      final iterator = permissionMapStatus.entries.iterator;
      while (iterator.moveNext()) {
        ///if some requested permission denied, ask to open app settings
        if (!iterator.current.value.isGranted) {
          showDialogFunction.call();
          return false;
        }
      }
    }
    return true;
  }
}