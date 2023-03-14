import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  final List<Widget> entries;

  const InfoPage({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          "No entries",
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      );
    }

    List<Widget> buildItem(int i, List<Widget> entries) {
      return [
        if (i > 0) const SizedBox(height: 12),
        entries[i],
      ];
    }

    // https://github.com/flutter/flutter/issues/99158
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 1100 && entries.length > 1) {
        var firstList = entries.sublist(0, (entries.length / 2).ceil());
        var secondList = entries.sublist(firstList.length);
        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (int i = 0; i < firstList.length; i++)
                      ...buildItem(i, firstList),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    for (int i = 0; i < secondList.length; i++)
                      ...buildItem(i, secondList),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < entries.length; i++) ...buildItem(i, entries),
            ],
          ),
        );
      }
    });

    // return CustomScrollView(slivers: [
    //   SliverList(
    //     delegate: SliverChildListDelegate([
    //       for (int i = 0; i < entries.length; i++)
    //         ...buildItem(i, entries.length),
    //     ]),
    //   ),
    // ]);

    // return ListView.separated(
    //   itemCount: entries.length,
    //   itemBuilder: (context, index) => entries[index],
    //   separatorBuilder: (context, index) => const SizedBox(height: 12),
    // );
  }
}
