import 'package:equatable/equatable.dart';

class MovieEntity extends Equatable {
  final int? id;
  final String nome;
  final String categoria;

  MovieEntity(this.id, this.nome, this.categoria);

  @override
  List<Object?> get props => [nome, categoria];
}
