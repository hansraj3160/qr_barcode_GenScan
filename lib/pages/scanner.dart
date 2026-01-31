import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrgenscan/main.dart';
import 'package:qrgenscan/services/db_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String qrCodeResult = "Scan a QR code to see the result";
  bool isLoading = false;
 Future<void> scanQR() async {
  try {
    setState(() {
      isLoading = true;
    });

    final result = await BarcodeScanner.scan();

    if (result.type == ResultType.Barcode) {
      final content = result.rawContent;

      // async work OUTSIDE setState
      await DatabaseHelper().insertHistory(content, 'Scanned');

      setState(() {
        isLoading = false;
        qrCodeResult = content;
      });

      _showResultSheet(content);

    } else if (result.type == ResultType.Cancelled) {
      setState(() {
        isLoading = false;
        qrCodeResult = "Scan cancelled";
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Scan Result: $qrCodeResult"),
        backgroundColor: AppColors.iconColor,
      ),
    );

  } on PlatformException catch (e) {
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: ${e.message}"),
        backgroundColor: Colors.red,
      ),
    );

  } catch (e) {
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  void _showResultSheet(String code) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.tileColor, // Theme ke hisab se
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(10)),
              ),
              const Text("Scanned Result",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white)),
              const SizedBox(height: 15),
              SelectableText(code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.copy,
                    label: "Copy",
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Copied to Clipboard")));
                    },
                  ),
                  if (code
                      .startsWith("http")) // Sirf URL par Open button dikhayein
                    _buildActionButton(
                      icon: Icons.open_in_browser,
                      label: "Open",
                      onTap: () async {
                        final Uri url = Uri.parse(code);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

// Helper Widget for Buttons
  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.tileColor,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change icon color to white
        ),
        title: const Text(
          'QR Code Scanner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Scan a QR Code',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.tileColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(30),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 120,
                  color: AppColors.iconColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Scan Result",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.tileColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          qrCodeResult,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: qrCodeResult));

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Copied to clipboard"),
                              backgroundColor: AppColors.iconColor,
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy,
                          color: AppColors.iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: Text(
                    isLoading ? "Scanning..." : "Scan QR Code",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iconColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : scanQR,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
