// L'égalité par id garantit la stabilité des DropdownButtonFormField.

class Room {
  const Room({required this.id, required this.number});

  final String id;
  final String number;

  @override
  bool operator ==(Object other) => other is Room && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as String,
        number: json['number'] as String,
      );
}

class Building {
  const Building({required this.id, required this.name, required this.rooms});

  final String id;
  final String name;
  final List<Room> rooms;

  @override
  bool operator ==(Object other) => other is Building && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory Building.fromJson(Map<String, dynamic> json) => Building(
        id: json['id'] as String,
        name: json['name'] as String,
        rooms: (json['rooms'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(Room.fromJson)
                .toList() ??
            [],
      );
}

class Program {
  const Program({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) => other is Program && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}
