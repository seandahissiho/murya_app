import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/models/country.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/timezone.dart' as tz;

part 'extensions.dart';

class Pair<T, U> {
  T first;
  U second;

  Pair(this.first, this.second);

  @override
  String toString() {
    return 'Pair($first, $second)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pair && runtimeType == other.runtimeType && first == other.first && second == other.second;

  @override
  int get hashCode => first.hashCode ^ second.hashCode;
}

class AppCachedNetworkImage extends StatelessWidget {
  final double? height;
  final double? width;
  final double radius;
  final String? imageUrl;
  final Widget? errorWidget;
  final bool isRatio;

  const AppCachedNetworkImage({
    super.key,
    this.height,
    this.width,
    required this.radius,
    required this.imageUrl,
    this.errorWidget,
    this.isRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (!isRatio ? height : height?.h) ?? double.infinity,
      width: (!isRatio ? width : width?.w) ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius - 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: _buildChild(),
      ),
    );
  }

  _displayImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      errorWidget: (context, url, error) {
        return _displayError();
      },
      placeholder: (context, url) {
        return Shimmer.fromColors(
          baseColor: AppColors.whiteSwatch.shade100,
          highlightColor: AppColors.whiteSwatch.shade200,
          child: Container(
            color: AppColors.whiteSwatch.shade100,
          ),
        );
      },
    );
  }

  _displayError({bool byPassLocal = false, bool byPassOnline = false}) {
    if ((imageUrl?.isNotEmpty ?? false) && imageUrl!.contains("http") == false && !byPassLocal) {
      return _displayLocalImage();
    }

    if ((imageUrl?.isNotEmpty ?? false) && imageUrl!.contains("http") == true && !byPassOnline) {
      return Image.network(
        'https://prodiser.blob.core.windows.net/images/1728070081215-Developpement_informatique_et_applications.png',
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return _displayError(byPassOnline: true, byPassLocal: byPassLocal);
        },
      );
    }

    return errorWidget ??
        Container(
          color: AppColors.whiteSwatch.shade100,
          child: Icon(
            Icons.warning,
            color: Colors.red,
            size: 15.sp,
          ),
        );
  }

  _buildChild() {
    if (imageUrl?.isEmpty ?? true) {
      return _displayError();
    }
    return _displayImage();
  }

  _displayLocalImage() {
    return Image.asset(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _displayError(byPassLocal: true);
      },
    );
  }
}

class TextLink {
  final String text;
  final bool isLink;
  final GestureTapCallback? onTap;
  final TextStyle? textStyle;
  final bool underline;

  bool hovered = false;

  TextLink({
    required this.text,
    this.isLink = false,
    this.onTap,
    this.textStyle,
    this.underline = false,
  });
}

class TextWithLinks extends StatefulWidget {
  final List<TextLink> textsLinks;

  final TextStyle textStyleText;

  final TextStyle textStyleLink;

  final TextAlign textAlign;
  final TextOverflow textOverflow;
  final Color textHoverColor;
  final Color linkHoverColor;
  final int? maxLines;

  const TextWithLinks({
    super.key,
    required this.textsLinks,
    required this.textStyleText,
    required this.textStyleLink,
    this.textAlign = TextAlign.start,
    this.textOverflow = TextOverflow.visible,
    this.textHoverColor = AppColors.secondaryDefault,
    this.linkHoverColor = AppColors.secondaryDefault,
    this.maxLines,
  });

  @override
  State<TextWithLinks> createState() => _TextWithLinksState();
}

class _TextWithLinksState extends State<TextWithLinks> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return RichText(
      textAlign: widget.textAlign,
      overflow: widget.textOverflow,
      maxLines: widget.maxLines,
      text: TextSpan(
        text: widget.textsLinks[0].text,
        style: widget.textsLinks[0].textStyle ??
            (!widget.textsLinks[0].isLink ? _getThemeTextStyle(theme, 0) : _getThemeTextLinkStyle(theme, 0)),
        recognizer: !widget.textsLinks[0].isLink ? null : TapGestureRecognizer()
          ?..onTap = () {
            if (widget.textsLinks[0].onTap.isNull) {
              log(
                '`${widget.textsLinks[0].text}`'
                ' clicked but no action registered',
              );
            } else {
              widget.textsLinks[0].onTap!();
            }
          },
        children: List.generate(
          widget.textsLinks.length - 1,
          (index) {
            int goodIndex = index + 1;
            return WidgetSpan(
              child: MouseRegion(
                cursor: widget.textsLinks[goodIndex].isLink ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: GestureDetector(
                  onTap: widget.textsLinks[goodIndex].onTap,
                  child: Text(
                    widget.textsLinks[goodIndex].text,
                    style: widget.textsLinks[goodIndex].textStyle ??
                        (!widget.textsLinks[goodIndex].isLink
                            ? _getThemeTextStyle(theme, goodIndex)
                            : _getThemeTextLinkStyle(theme, goodIndex)),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      softWrap: true,
    );
  }

  _getThemeTextStyle(ThemeData theme, int i) {
    final TextStyle textStyle = (widget.textsLinks[i].textStyle ?? widget.textStyleText);
    final Color color = widget.textsLinks[i].hovered ? widget.textHoverColor : textStyle.color!;
    return widget.textStyleText.copyWith(
      shadows: [
        Shadow(
          color: widget.textsLinks[i].underline ? Colors.transparent : Colors.transparent,
          offset: const Offset(0, -1),
        )
      ],
      color: widget.textsLinks[i].underline ? Colors.transparent : Colors.transparent,
      decoration: widget.textsLinks[i].underline ? TextDecoration.underline : null,
      decorationColor: color,
      fontWeight: textStyle.fontWeight,
      decorationThickness: 1.5,
      decorationStyle: TextDecorationStyle.solid,
      overflow: TextOverflow.ellipsis,
    );
  }

  _getThemeTextLinkStyle(ThemeData theme, int i) {
    final TextStyle textStyle = (widget.textsLinks[i].textStyle ?? widget.textStyleLink);
    final Color color = widget.textsLinks[i].hovered ? widget.linkHoverColor : textStyle.color!;
    return widget.textStyleLink.copyWith(
      shadows: [
        Shadow(
          color: widget.textsLinks[i].underline ? color : Colors.transparent,
          offset: const Offset(0, -1),
        )
      ],
      color: widget.textsLinks[i].underline ? Colors.transparent : color,
      fontWeight: textStyle.fontWeight,
      decoration: widget.textsLinks[i].underline ? TextDecoration.underline : null,
      decorationColor: color,
      decorationThickness: 1.5,
      decorationStyle: TextDecorationStyle.solid,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// class PhotoPicker {
//   final List<String> allowedExtensions = ['jpg', 'png', 'jpeg'];
//   bool alreadyTap = false;
//
//   List<PlatformFile>? _paths;
//
//   Future<PlatformFile?> pickImage() async {
//     try {
//       _paths = (await FilePicker.platform.pickFiles(
//         compressionQuality: 30,
//         type: FileType.image,
//         allowMultiple: false,
//         onFileLoading: (FilePickerStatus status) => log("$status"),
//         // allowedExtensions: allowedExtensions,
//         dialogTitle: null,
//         initialDirectory: null,
//         lockParentWindow: false,
//       ))
//           ?.files;
//       if (_paths.isNotNull) {
//         return _paths!.first;
//       }
//     } on PlatformException catch (e) {
//       log('Unsupported operation $e');
//       return null;
//     } catch (e) {
//       log(e.toString());
//       return null;
//     }
//     return null;
//   }
//
//   Future<String> saveFileOnline({
//     required PlatformFile platformFile,
//     required String path,
//   }) async {
//     // final storageRef = FirebaseStorage.instance.ref();
//     // if (path.endsWith("/")) path = path.substring(0, path.length - 1);
//     // final imageRef = storageRef.child("$path/${platformFile.name}");
//     //
//     // await imageRef.putData(platformFile.bytes!);
//     // String url = await imageRef.getDownloadURL();
//     String url = "";
//
//     return url;
//   }
// }
//
// class FilePickerService {
//   final PhotoPicker _photoPicker = PhotoPicker();
//   final ImagePicker _imagePicker = ImagePicker();
//
//   Future<dynamic> pickImageFromGallery() async {
//     if (kIsWeb) {
//       PlatformFile? file = await _photoPicker.pickImage();
//       return file;
//     }
//     final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
//     return image != null ? File(image.path) : null;
//   }
//
//   Future<dynamic> takePhotoWithCamera() async {
//     if (kIsWeb) {
//       PlatformFile? file = await _photoPicker.pickImage();
//       return file;
//     }
//     final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
//     return photo != null ? File(photo.path) : null;
//   }
//
//   Future<dynamic> pickFile() async {
//     final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'doc', 'docx', 'pdf', 'xls', 'xlsx', 'csv'];
//
//     final FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: allowedExtensions,
//     );
//     return result != null ? (kIsWeb ? result.files.single : File(result.files.single.path!)) : null;
//   }
//
//   Future<dynamic> _showPickerDialog(BuildContext context) async {
//     if (kIsWeb) {
//       PlatformFile? file = await _photoPicker.pickImage();
//       return file;
//     }
//
//     final ThemeData theme = Theme.of(context);
//     return await showDialog<File?>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             'Sélectionnez une option',
//             style: theme.textTheme.labelLarge,
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               ListTile(
//                 minLeadingWidth: 0,
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Galerie'),
//                 onTap: () async {
//                   Navigator.of(context).pop(await pickImageFromGallery());
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Caméra'),
//                 onTap: () async {
//                   Navigator.of(context).pop(await takePhotoWithCamera());
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.file_present),
//                 title: const Text('Fichier'),
//                 onTap: () async {
//                   Navigator.of(context).pop(await pickFile());
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<dynamic> showPicker(BuildContext context) async {
//     return await _showPickerDialog(context);
//   }
// }

class AppSize {
  BuildContext context;

  AppSize(this.context);

  Orientation get getDeviceOrientation {
    if (kIsWeb) {
      return 100.w > 100.h ? Orientation.landscape : Orientation.portrait;
    }
    return MediaQuery.of(context).orientation == Orientation.portrait ? Orientation.portrait : Orientation.landscape;
  }

  double get screenWidth {
    if (kIsWeb) {
      return 100.w;
    }
    Orientation deviceOrientation = getDeviceOrientation;
    if (DeviceHelper.isMobile(context)) {
      return deviceOrientation == Orientation.portrait ? 100.w : 100.h;
    }
    return deviceOrientation == Orientation.portrait ? 100.h : 100.w;
  }

  double get screenHeight {
    if (kIsWeb) {
      return 100.h;
    }
    Orientation deviceOrientation = getDeviceOrientation;
    if (DeviceHelper.isMobile(context)) {
      return deviceOrientation == Orientation.portrait ? 100.h : 100.w;
    }
    return deviceOrientation == Orientation.portrait ? 100.w : 100.h;
  }

  bool get isMobileView {
    return screenWidth < AppBreakpoints.tablet;
  }

  bool get isTabletView {
    return screenWidth < AppBreakpoints.desktop;
  }

  bool get isDesktopView {
    return screenWidth >= AppBreakpoints.desktop;
  }

  Size get size => Size(screenWidth, screenHeight);
}

Future datePicker(BuildContext context) async {
  DateTime? selectedDate;
  return await showDatePickerDialog(
    context: context,
    initialDate: DateTime.now(),
    minDate: DateTime(2025, 1, 1),
    maxDate: DateTime(2050, 12, 31),
    padding: EdgeInsets.only(
      left: 65.w,
      top: 40.h,
    ),
    width: 400,
    height: 300,
    currentDate: DateTime.now(),
    selectedDate: selectedDate,
    currentDateDecoration: const BoxDecoration(),
    currentDateTextStyle: const TextStyle(),
    daysOfTheWeekTextStyle: const TextStyle(),
    disabledCellsTextStyle: const TextStyle(),
    enabledCellsDecoration: const BoxDecoration(),
    enabledCellsTextStyle: const TextStyle(),
    initialPickerType: PickerType.days,
    selectedCellDecoration: const BoxDecoration(),
    selectedCellTextStyle: const TextStyle(),
    leadingDateTextStyle: const TextStyle(),
    slidersColor: Colors.lightBlue,
    highlightColor: Colors.redAccent,
    slidersSize: 20,
    splashColor: Colors.lightBlueAccent,
    splashRadius: 40,
    centerLeadingDate: true,
    barrierColor: Colors.transparent,
  );
}

class StreamManager<T> {
  final _socketResponse = StreamController<T>();

  void Function(T) get addResponse {
    return _socketResponse.sink.add;
  }

  Stream<T> get getResponse => _socketResponse.stream;

  bool get isClosed => _socketResponse.isClosed;

  void dispose() {
    _socketResponse.close();
  }
}
