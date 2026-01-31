import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/db_helper.dart';
import '../main.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: AppColors.backgroundColor,
      
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change icon color to white
        ),
        title: const Text("History",style: TextStyle(color: Colors.white),), backgroundColor: AppColors.tileColor
),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text("No history yet", style: TextStyle(color: Colors.white)));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data![index];
              return Dismissible(
                key: Key(item['content']),
                onDismissed: (direction) async {
                  await DatabaseHelper().deleteHistory(item['content']);
                  setState(() {
                    // snapshot.data!.removeAt(index);
                  });
                },
                child: ListTile(
                  leading: Icon(item['type'] == 'Scanned' ? Icons.qr_code_scanner : Icons.qr_code, color: AppColors.iconColor),
                  title: Text(item['content'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text(item['timestamp'], style: const TextStyle(color: Colors.white70)),
                  trailing: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: item['content']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    child: const Icon(Icons.copy, color: AppColors.iconColor)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}