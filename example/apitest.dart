// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services_server.apitest;

import 'dart:html';

import 'package:codemirror/codemirror.dart';

import '../doc/generated/_dartpadsupportservices.dart' as support;
import '../doc/generated/dartservices.dart' as services;
import 'services_utils.dart' as utils;

utils.SanitizingBrowserClient client;
services.DartservicesApi servicesApi;
support.P_dartpadsupportservicesApi _dartpadSupportApi;

void main() {
  setupAnalyze();
  setupCompile();
  setupComplete();
  setupDocument();
  setupFixes();
  setupVersion();
  setupDartpadServices();
}

void setupDartpadServices() {
  setupExport();
  setupRetrieve();
  setupSummary();
  setupIdRetrieval();
  setupGistStore();
  setupGistRetrieval();
}

void _setupClients() {
  client = new utils.SanitizingBrowserClient();
  servicesApi = new services.DartservicesApi(client, rootUrl: _uriBase);
  _dartpadSupportApi =
      new support.P_dartpadsupportservicesApi(client, rootUrl: _uriBase);
}

void setupSummary() {
  CodeMirror editor = createEditor(querySelector('#summarySection .editor'));
  Element output = querySelector('#summarySection .output');
  ButtonElement button = querySelector('#summarySection button');
  button.onClick.listen((e) {
    _setupClients();
    services.SourcesRequest input = new services.SourcesRequest();
    input.sources = new Map<String, String>();
    input.sources['dart'] = editor.getDoc().getValue();
    input.sources['css'] = "";
    input.sources['html'] = "";
    Stopwatch sw = new Stopwatch()..start();
    servicesApi.summarize(input).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
}

void setupIdRetrieval() {
  Element output = querySelector('#idSection .output');
  ButtonElement button = querySelector('#idSection button');
  button.onClick.listen((e) {
    Stopwatch sw = new Stopwatch()..start();
    _dartpadSupportApi.getUnusedMappingId().then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
}

void setupGistStore() {
  CodeMirror editor = createEditor(querySelector('#storeSection .editor'),
      defaultText: "Internal ID");
  Element output = querySelector('#storeSection .output');
  ButtonElement button = querySelector('#storeSection button');
  button.onClick.listen((e) {
    String editorText = editor.getDoc().getValue();
    support.GistToInternalIdMapping saveObject =
        new support.GistToInternalIdMapping();
    saveObject.internalId = editorText;
    saveObject.gistId = "72d83fe97bfc8e735607"; //Solar
    Stopwatch sw = new Stopwatch()..start();
    _dartpadSupportApi.storeGist(saveObject).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
}

void setupGistRetrieval() {
  CodeMirror editor = createEditor(querySelector('#gistSection .editor'),
      defaultText: "Internal ID");
  Element output = querySelector('#gistSection .output');
  ButtonElement button = querySelector('#gistSection button');
  button.onClick.listen((e) {
    String editorText = editor.getDoc().getValue();
    Stopwatch sw = new Stopwatch()..start();
    _dartpadSupportApi.retrieveGist(id: editorText).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
}

void setupAnalyze() {
  CodeMirror editor = createEditor(querySelector('#analyzeSection .editor'));
  Element output = querySelector('#analyzeSection .output');
  ButtonElement button = querySelector('#analyzeSection button');
  button.onClick.listen((e) {
    _setupClients();
    services.SourceRequest srcRequest = new services.SourceRequest()
      ..source = editor.getDoc().getValue();
    Stopwatch sw = new Stopwatch()..start();
    servicesApi.analyze(srcRequest).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
}

void setupCompile() {
  CodeMirror editor = createEditor(querySelector('#compileSection .editor'));
  Element output = querySelector('#compileSection .output');
  ButtonElement button = querySelector('#compileSection button');
  button.onClick.listen((e) {
    String source = editor.getDoc().getValue();

    _setupClients();
    services.CompileRequest compileRequest = new services.CompileRequest();
    compileRequest.source = source;

    Stopwatch sw = new Stopwatch()..start();
    servicesApi.compile(compileRequest).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
}

void setupComplete() {
  CodeMirror editor = createEditor(querySelector('#completeSection .editor'));
  Element output = querySelector('#completeSection .output');
  Element offsetElement = querySelector('#completeSection .offset');
  ButtonElement button = querySelector('#completeSection button');
  button.onClick.listen((e) {
    var sourceRequest = _getSourceRequest(editor);
    Stopwatch sw = new Stopwatch()..start();
    servicesApi.complete(sourceRequest).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
  offsetElement.text = 'offset ${_getOffset(editor)}';
  editor.onCursorActivity.listen((_) {
    offsetElement.text = 'offset ${_getOffset(editor)}';
  });
}

void setupDocument() {
  CodeMirror editor = createEditor(querySelector('#documentSection .editor'));
  Element output = querySelector('#documentSection .output');
  Element offsetElement = querySelector('#documentSection .offset');
  ButtonElement button = querySelector('#documentSection button');
  button.onClick.listen((e) {
    var sourceRequest = _getSourceRequest(editor);
    Stopwatch sw = new Stopwatch()..start();
    servicesApi.document(sourceRequest).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
  offsetElement.text = 'offset ${_getOffset(editor)}';
  editor.onCursorActivity.listen((_) {
    offsetElement.text = 'offset ${_getOffset(editor)}';
  });
}

void setupFixes() {
  CodeMirror editor = createEditor(querySelector('#fixesSection .editor'));
  Element output = querySelector('#fixesSection .output');
  Element offsetElement = querySelector('#fixesSection .offset');
  ButtonElement button = querySelector('#fixesSection button');
  button.onClick.listen((e) {
    var sourceRequest = _getSourceRequest(editor);
    Stopwatch sw = new Stopwatch()..start();
    servicesApi.fixes(sourceRequest).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
  offsetElement.text = 'offset ${_getOffset(editor)}';

  editor.onCursorActivity.listen((_) {
    offsetElement.text = 'offset ${_getOffset(editor)}';
  });
}

void setupVersion() {
  Element output = querySelector('#versionSection .output');
  ButtonElement button = querySelector('#versionSection button');
  button.onClick.listen((e) {
    Stopwatch sw = new Stopwatch()..start();
    servicesApi.version().then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
}

void setupExport() {
  CodeMirror editor = createEditor(querySelector('#exportSection .editor'));
  Element output = querySelector('#exportSection .output');
  ButtonElement button = querySelector('#exportSection button');
  button.onClick.listen((e) {
    support.PadSaveObject saveObject = new support.PadSaveObject();
    saveObject.dart = editor.getDoc().getValue();
    Stopwatch sw = new Stopwatch()..start();
    _dartpadSupportApi.export(saveObject).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
}

void setupRetrieve() {
  Element output = querySelector('#retrieveSection .output');
  CodeMirror editor =
      createEditor(querySelector('#retrieveSection .editor'), defaultText: "");
  ButtonElement button = querySelector('#retrieveSection button');
  button.onClick.listen((e) {
    String uuid = editor.getDoc().getValue();

    Stopwatch sw = new Stopwatch()..start();

    support.UuidContainer uuidContainer = new support.UuidContainer()
      ..uuid = uuid;

    _dartpadSupportApi.pullExportContent(uuidContainer).then((results) {
      output.text = "${_formatTiming(sw)}${results.toJson()}";
    });
  });
}

CodeMirror createEditor(Element element, {String defaultText}) {
  final Map options = {
    'tabSize': 2,
    'indentUnit': 2,
    'autoCloseBrackets': true,
    'matchBrackets': true,
    'theme': 'zenburn',
    'mode': 'dart',
    'value': defaultText == null ? _text : defaultText
  };

  CodeMirror editor = new CodeMirror.fromElement(element, options: options);
  editor.refresh();
  return editor;
}

String _formatTiming(Stopwatch sw) => "${sw.elapsedMilliseconds}ms\n";

String get _uriBase =>
    (querySelector('input[type=text]') as InputElement).value;

int _getOffset(CodeMirror editor) {
  Position pos = editor.getDoc().getCursor();
  return editor.getDoc().indexFromPos(pos);
}

services.SourceRequest _getSourceRequest(CodeMirror editor) {
  var srcRequest = new services.SourceRequest()
    ..source = editor.getDoc().getValue()
    ..offset = _getOffset(editor);
  return srcRequest;
}

final String _text = r'''
void main() {
  for (int i = 0; i < 4; i++) {
    print('hello ${i}');
  }
}
''';
