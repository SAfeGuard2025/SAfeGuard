// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soccorritore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Soccorritore _$SoccorritoreFromJson(Map<String, dynamic> json) => Soccorritore(
  (json['id'] as num).toInt(),
  json['email'] as String,
  telefono: json['telefono'] as String?,
  nome: json['nome'] as String?,
  cognome: json['cognome'] as String?,
  dataDiNascita: json['dataDiNascita'] == null
      ? null
      : DateTime.parse(json['dataDiNascita'] as String),
  cittaDiNascita: json['cittaDiNascita'] as String?,
  iconaProfilo: json['iconaProfilo'] as String?,
);

Map<String, dynamic> _$SoccorritoreToJson(Soccorritore instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'cognome': instance.cognome,
      'dataDiNascita': instance.dataDiNascita?.toIso8601String(),
      'cittaDiNascita': instance.cittaDiNascita,
      'iconaProfilo': instance.iconaProfilo,
      'email': instance.email,
      'telefono': instance.telefono,
      'id': instance.id,
    };
