import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niconico/constant.dart';

class SearchHeader extends ConsumerStatefulWidget {
  const SearchHeader({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends ConsumerState<SearchHeader> {
  bool isBanner = false;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: SizedBox(
          height: kToolbarHeight - 25,
          child: TextField(
            decoration: InputDecoration(
              fillColor: const Color.fromARGB(255, 53, 53, 53),
              filled: true,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(5),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  if (!isBanner) {
                    isBanner = true;
                    ScaffoldMessenger.of(context).showMaterialBanner(
                      MaterialBanner(
                        content: const Text('Hello, I am a Material Banner'),
                        leading: const Icon(Icons.info),
                        actions: [
                          TextButton(
                              child: const Text('完了',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentMaterialBanner();
                                isBanner = false;
                              }),
                        ],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    isBanner = false;
                  }
                },
                child: const Icon(Icons.sort, color: Colors.blue),
              ),
            ),
            onSubmitted: (e) =>
                ref.read(SearchParam.searchWord.notifier).state = e.trim(),
          )),
      automaticallyImplyLeading: false,
    );
  }
}
