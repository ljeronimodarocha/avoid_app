import 'package:equatable/equatable.dart';

class MovieEntity extends Equatable {
  final String nome;
  final String categoria;

  MovieEntity(this.nome, this.categoria);

  @override
  List<Object?> get props => [nome, categoria];
}
