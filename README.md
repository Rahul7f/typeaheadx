# 🧠 TypeAheadX

[![Pub Version](https://img.shields.io/pub/v/typeaheadx.svg)](https://pub.dev/packages/typeaheadx)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter Platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev)
[![GitHub stars](https://img.shields.io/github/stars/<your-github-username>/typeaheadx.svg?style=social)](https://github.com/<your-github-username>/typeaheadx)

A powerful, dependency-free **TypeAhead widget for Flutter** — supporting async API search, pagination, keyboard navigation, and full custom styling.

---

## ✨ Features

- 🔍 Async search & pagination
- ⌨️ Keyboard navigation (↑ ↓ Enter)
- ⚡ Debounced queries (no spam calls)
- 💾 Local or remote data search
- 🎨 Fully customizable UI (via `TypeAheadXStyle`)
- 🧱 No external dependencies — just Flutter

---

## 🚀 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  typeaheadx: ^0.0.1
```

Import it:

```dart
import 'package:typeaheadx/typeaheadx.dart';
```

---

## 💡 Basic Example

```dart
TypeAheadX(
  hintText: 'Search fruits...',
  itemList: ['Apple', 'Banana', 'Orange', 'Mango'],
  onValueChanged: (value) {
    print('Selected: $value');
  },
);
```

---

## 🌐 Async Search Example

```dart
TypeAheadX(
  hintText: 'Search products...',
  fetchSuggestions: (query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final products = ['Book', 'Bottle', 'Brush', 'Basket'];
    return products
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  },
  onValueChanged: (value) {
    print('Selected async item: $value');
  },
);
```

---

## 📜 Paginated API Example

```dart
TypeAheadX(
  hintText: 'Search paginated items...',
  pagination: true,
  pageSize: 10,
  fetchPaginated: (query, page, pageSize) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final allItems = List.generate(
      100,
      (index) => 'Item ${index + 1}',
    ).where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();

    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, allItems.length);
    return allItems.sublist(start, end);
  },
  onValueChanged: print,
);
```

---

## 🎨 Custom Styling Example

```dart
TypeAheadX(
  hintText: 'Search in style...',
  itemList: ['Apple', 'Banana', 'Orange'],
  style: const TypeAheadXStyle(
    backgroundColor: Color(0xFF121212),
    borderColor: Colors.deepPurple,
    highlightColor: Color(0xFF2C2C2C),
    textColor: Colors.white,
    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
    textStyle: TextStyle(color: Colors.white, fontSize: 14),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
  onValueChanged: (value) {
    print('Styled search selected: $value');
  },
);
```

---

## ⚙️ Constructor Parameters

| Parameter | Type | Description |
|------------|------|-------------|
| `hintText` | `String` | Placeholder text for the search bar |
| `itemList` | `List<String>` | Local list for offline search |
| `fetchSuggestions` | `Future<List<String>> Function(String)` | Async callback for remote data |
| `fetchPaginated` | `Future<List<String>> Function(String, int, int)` | Async paginated callback |
| `onValueChanged` | `Function(String)` | Called when an item is selected |
| `onChanged` | `Function(String)?` | Called on each keystroke |
| `onSubmitted` | `Function(String)?` | Called on enter/search |
| `enabled` | `bool` | Enable or disable the field |
| `pagination` | `bool` | Enable pagination |
| `pageSize` | `int` | Number of items per page |
| `style` | `TypeAheadXStyle` | Custom visual style configuration |

---

## 🧱 Example App

You can find a full working demo under `/example/lib/main.dart`.

Run it directly with:

```bash
flutter run -t example/lib/main.dart
```

### Demo features:
- Local search
- Async search
- Pagination
- Custom styling
- Keyboard navigation

---

## 📸 Example Preview

Add your screenshot or demo GIF here:

```
screenshots/demo.gif
```

---

## 🧩 Architecture Overview

| Concept | Implementation |
|----------|----------------|
| State management | StreamControllers (no GetX, no setState) |
| Async calls | Debounced Futures |
| UI updates | StreamBuilder + ValueNotifier |
| Styling | `TypeAheadXStyle` |
| Default colors | `AppColors` (override-ready) |

---

## 🧪 Example Snippet (Full Page)

```dart
import 'package:flutter/material.dart';
import 'package:typeaheadx/typeaheadx.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TypeAheadX Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('TypeAheadX Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TypeAheadX(
            hintText: 'Search fruits...',
            itemList: ['Apple', 'Banana', 'Orange', 'Mango', 'Grapes'],
            fetchSuggestions: (query) async {
              await Future.delayed(const Duration(milliseconds: 400));
              final all = ['Apple', 'Banana', 'Orange', 'Mango', 'Grapes'];
              return all
                  .where((item) =>
                      item.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            },
            onValueChanged: (value) {
              debugPrint('Selected: $value');
            },
          ),
        ),
      ),
    );
  }
}
```

---

## 🧠 Design Philosophy

- Zero external dependencies  
- Fully reactive (no `setState`)  
- Clean, extensible architecture  
- Simple API — plug & play  
- Easy to customize & contribute

---

## 🤝 Contributing

Contributions are welcome!  

### To contribute:
1. Fork this repo  
2. Create a feature branch  
3. Make your changes  
4. Run `flutter analyze` and `dart format .`  
5. Submit a pull request  

Please keep your code clean, documented, and well-tested.

---

## 🧾 CHANGELOG

See [`CHANGELOG.md`](CHANGELOG.md) for version history.

---

## 📄 License

This project is licensed under the MIT License.  
See [LICENSE](LICENSE) for details.

---

## ❤️ Maintainer

**<Your Name>**  
GitHub → [https://github.com/<your-github-username>](https://github.com/<your-github-username>)  
Twitter → [@<your-handle>](https://twitter.com/<your-handle>)

---

## ⭐️ Support

If you find this package useful:
- ⭐ Star the repo  
- 🐞 Report bugs  
- 💬 Suggest features  
- 📢 Share it with the Flutter community  

Together, let’s make **TypeAheadX** the best search widget for Flutter!
