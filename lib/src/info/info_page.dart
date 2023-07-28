import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  final List<Widget> entries;

  const InfoPage({
    super.key,
    required this.entries,
  });

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with AutomaticKeepAliveClientMixin {
  // Re-calculating the information is expensive.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.entries.isEmpty) {
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
      if (constraints.maxWidth > 1100 && widget.entries.length > 1) {
        var firstList =
            widget.entries.sublist(0, (widget.entries.length / 2).ceil());
        var secondList = widget.entries.sublist(firstList.length);
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
              for (int i = 0; i < widget.entries.length; i++)
                ...buildItem(i, widget.entries),
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
