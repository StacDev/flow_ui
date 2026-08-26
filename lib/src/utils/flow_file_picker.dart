import 'package:file_selector/file_selector.dart';

import '../models/flow_attachment.dart';
import '../models/flow_attachment_options.dart';
import 'flow_attachment_intake.dart';

/// Opens the platform's file dialog and returns what came back, decoded.
///
/// Empty when the dialog was dismissed, and empty when everything chosen
/// was refused — each refusal having been reported through [onRejected]
/// first.
///
/// This is the only place in the package that knows about file_selector:
/// [FlowAttachmentTypeGroup] exists so that no host naming a file type
/// has to depend on it too.
Future<List<FlowAttachment>> flowPickAttachments({
  FlowAttachmentOptions options = const FlowAttachmentOptions(),
  void Function(String name, FlowAttachmentRejection reason)? onRejected,
}) async {
  final groups = options.accept.map(_typeGroup).toList(growable: false);

  final List<XFile> files;
  if (options.allowMultiple) {
    files = await openFiles(
      acceptedTypeGroups: groups,
      initialDirectory: options.initialDirectory,
      confirmButtonText: options.confirmButtonText,
    );
  } else {
    final file = await openFile(
      acceptedTypeGroups: groups,
      initialDirectory: options.initialDirectory,
      confirmButtonText: options.confirmButtonText,
    );
    files = file == null ? const <XFile>[] : <XFile>[file];
  }
  if (files.isEmpty) return const <FlowAttachment>[];

  // Sized together rather than one after another: picking ten photos
  // otherwise pays ten sequential round trips before the first byte is
  // read, with the attach button held disabled throughout. The reads
  // themselves stay sequential inside the intake, where that ordering is
  // what bounds peak memory and keeps rejections in a predictable order.
  final candidates = await Future.wait(
    files.map((file) => _candidate(file, options.maxFileSize != null)),
  );
  return flowIntakeAttachments(
    candidates,
    options: options,
    onRejected: onRejected,
  );
}

/// Sizing a file up front is a stat on native and a blob's length on the
/// web, so it is worth doing — but only when there is a cap to check it
/// against, and never at the cost of the pick when it fails. A null size
/// just moves the check after the read.
Future<FlowFileCandidate> _candidate(XFile file, bool measure) async {
  int? size;
  if (measure) {
    try {
      size = await file.length();
    } catch (_) {
      size = null;
    }
  }
  return FlowFileCandidate(
    name: file.name,
    size: size,
    mimeType: file.mimeType,
    read: file.readAsBytes,
  );
}

/// Every family crosses over, because each platform throws when the one
/// it reads is empty — see [FlowAttachmentTypeGroup].
XTypeGroup _typeGroup(FlowAttachmentTypeGroup group) => XTypeGroup(
  label: group.label,
  extensions: group.extensions,
  mimeTypes: group.mimeTypes,
  uniformTypeIdentifiers: group.uniformTypeIdentifiers,
  webWildCards: group.webWildCards,
);
