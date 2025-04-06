import 'package:ari/presentation/widgets/common/button_large.dart';
import 'package:flutter/material.dart';

class CreatePlaylistModal extends StatefulWidget {
  final Function(String title, bool publicYn) onCreate;

  const CreatePlaylistModal({Key? key, required this.onCreate})
    : super(key: key);

  @override
  _CreatePlaylistModalState createState() => _CreatePlaylistModalState();
}

class _CreatePlaylistModalState extends State<CreatePlaylistModal> {
  final TextEditingController _titleController = TextEditingController();
  bool _publicYn = false;

  @override
  Widget build(BuildContext context) {
    // 화면의 키보드 영역까지 포함하도록 하기 위해 SingleChildScrollView를 사용
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              "새 플레이리스트 만들기",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "플레이리스트 제목",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("공개 여부"),
                Switch(
                  value: _publicYn,
                  onChanged: (value) {
                    setState(() {
                      _publicYn = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButtonLarge(
              text: "만들기",
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isEmpty) return;
                widget.onCreate(title, _publicYn);
                Navigator.pop(context);
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
