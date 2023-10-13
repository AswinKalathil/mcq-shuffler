import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FileProcessingScreen(),
    );
  }
}

class FileProcessingScreen extends StatefulWidget {
  @override
  _FileProcessingScreenState createState() => _FileProcessingScreenState();
}

class _FileProcessingScreenState extends State<FileProcessingScreen> {
  String selectedFilePath = '';
  String mcqfile = 'No File Selected';
  String ansfile = 'No File Selected';
  String mcqpath = "";
  String anspath = "";
  String ErrorMsg = "";
  int ok = 0;

  int _itemCount = 2;

// Open a file picker dialog
  Future<PlatformFile?> openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      file.path as String;

      print('File path: ${file.path}');
      print('File name: ${file.name}');
      print('File size: ${file.size}');
      return file;
    } else {
      // User canceled the file picker
      print('No file selected');
      return null; // Return a placeholder string
    }
  }

  callPythonScript(
      String exePath, String mcq, String ans, String paperCount) async {
    print(" ${mcq} ${ans} ${paperCount}");
    try {
      final result = await Process.run(exePath, [mcq, ans, paperCount]);
      if (result.exitCode == 0) {
        print('Execution successful');
        print('Standard Output:');
        print(result.stdout);
        setState(() {
          ok = 1;
        });
      } else {
        print('Execution failed');
        print('Standard Error:');
        print(result.stderr);
        ok = 0;
      }
    } catch (e) {
      ErrorMsg = "Error Processing";
      print('Error: $e');
      ok = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    PlatformFile? mcqResultFile;
    PlatformFile? ansResultFile;
    final directory = Directory.current;
    String scriptPath = Platform.script.toFilePath();
    print(directory);
    print(scriptPath);

    String filePath = scriptPath;

    // Get the directory containing the file.
    String currentDirectory = path.dirname(filePath);
    final exePath = currentDirectory + '\\workingShufling.exe';

    return Scaffold(
      appBar: AppBar(
        title: Text('MCQ  Shuffler '),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              children: [
                Container(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      mcqResultFile = await openFilePicker();
                      setState(() {
                        try {
                          ok = 0;
                          mcqfile = mcqResultFile!.name;
                          mcqpath = mcqResultFile!.path as String;
                          ErrorMsg = "";
                        } catch (e) {
                          ErrorMsg = "Error on input ";
                        }
                      });
                    },
                    child: Text('Select MCQ File'),
                  ),
                ),
                Container(
                  width: 150,
                  child: Text(" : $mcqfile"),
                ),
              ],
            ),
            // SizedBox(height: 40),
            Row(
              children: [
                Container(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      ansResultFile = await openFilePicker();
                      setState(() {
                        try {
                          ok = 0;
                          ansfile = ansResultFile!.name;
                          anspath = ansResultFile!.path as String;
                          ErrorMsg = "";
                        } catch (e) {
                          ErrorMsg = "Error on input";
                        }
                      });
                    },
                    child: Text('Select Ans Key File'),
                  ),
                ),
                Container(
                  width: 150,
                  child: Text(" : $ansfile"),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                _itemCount != 0
                    ? IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _itemCount--;
                          });
                        })
                    : Container(
                        width: 40,
                      ),
                Text(_itemCount.toString()),
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _itemCount++;
                      });
                    })
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ok == 1
                    ? Text("Shuffling Succesfull",
                        style: TextStyle(color: Colors.green))
                    : Text(ErrorMsg, style: TextStyle(color: Colors.red)),
                ElevatedButton(
                    onPressed: () {
                      if (mcqfile == 'No File Selected') {
                        setState(() {
                          ErrorMsg = "Questions input file not Selected";
                        });
                      } else if (ansfile == 'No File Selected') {
                        setState(() {
                          ErrorMsg = "Answer input file not Selected";
                        });
                      } else
                        callPythonScript(
                            exePath, mcqpath, anspath, _itemCount.toString());
                    },
                    child: Text('Shuffle')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
