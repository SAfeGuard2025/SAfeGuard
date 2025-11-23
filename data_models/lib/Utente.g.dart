// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Utente _$UtenteFromJson(Map<String, dynamic> json) => Utente(
  (json['id'] as num).toInt(),
  email: json['email'] as String?,
  telefono: json['telefono'] as String?,
  nome: json['nome'] as String?,
  cognome: json['cognome'] as String?,
  dataDiNascita: json['dataDiNascita'] == null
      ? null
      : DateTime.parse(json['dataDiNascita'] as String),
  cittaDiNascita: json['cittaDiNascita'] as String?,
  iconaProfilo: json['iconaProfilo'] as String?,
);

Map<String, dynamic> _$UtenteToJson(Utente instance) => <String, dynamic>{
  'nome': instance.nome,
  'cognome': instance.cognome,
  'dataDiNascita': instance.dataDiNascita?.toIso8601String(),
  'cittaDiNascita': instance.cittaDiNascita,
  'iconaProfilo': instance.iconaProfilo,
  'email': instance.email,
  'telefono': instance.telefono,
  'id': instance.id,
};
