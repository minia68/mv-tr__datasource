import 'dart:convert';
import 'dart:io';

import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:domain/domain.dart';

import 'constants.dart';
import 'datasource.dart';

class DynamodbDataSource implements DataSource {
  final DynamoDB _db;

  DynamodbDataSource(this._db);

  @override
  Future<Movies?> getMoviesData({bool? refresh}) async {
    final result = await _db.getItem(
      tableName: mvTrTableName,
      key: {mvTrTypeKey: AttributeValue(s: mvTrMoviesType)},
    );
    if ((result.item?[mvTrDataKey]?.s ?? '').isEmpty) {
      return null;
    } else {
      return Movies(
        imageBaseUrl: result.item![mvTrImageBaseUrlKey]?.s,
        lastUpdate: result.item![mvTrLastUpdateKey]?.n == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                int.parse(result.item![mvTrLastUpdateKey]!.n!),
              ),
        movies:
            (json.decode(_decompress(result.item![mvTrDataKey]!.s!)) as List)
                .map((e) => MovieInfo.fromJson(e as Map<String, dynamic>))
                .toList(),
      );
    }
  }

  @override
  Future<void> updateMovies(
    String? baseImagePath,
    List<MovieInfo> movies, [
    DateTime? date,
  ]) async {
    await _db.putItem(
      item: {
        mvTrTypeKey: AttributeValue(s: mvTrMoviesType),
        mvTrImageBaseUrlKey: AttributeValue(s: baseImagePath),
        mvTrLastUpdateKey: AttributeValue(
            n: (date ?? DateTime.now()).millisecondsSinceEpoch.toString()),
        mvTrDataKey: AttributeValue(
          s: _compress(json.encode(movies)),
        ),
      },
      tableName: mvTrTableName,
    );
  }

  @override
  Future<Settings?> getSettings() async {
    final result = await _db.getItem(
      tableName: mvTrTableName,
      key: {mvTrTypeKey: AttributeValue(s: mvTrSettingsType)},
    );

    if (result.item?[mvTrDataKey]?.s == null) {
      return null;
    } else {
      return Settings.fromJson(
          json.decode(_decompress(result.item![mvTrDataKey]!.s!)));
    }
  }

  @override
  Future<void> setSettings(Settings settings) async {
    await _db.putItem(
      item: {
        mvTrTypeKey: AttributeValue(s: mvTrSettingsType),
        mvTrDataKey: AttributeValue(s: _compress(json.encode(settings))),
      },
      tableName: mvTrTableName,
    );
  }
}

String _compress(String json) {
  final enCodedJson = utf8.encode(json);
  final gZipJson = gzip.encode(enCodedJson);
  return base64.encode(gZipJson);
}

String _decompress(String base64Json) {
  final decodeBase64Json = base64.decode(base64Json);
  final decodegZipJson = gzip.decode(decodeBase64Json);
  return utf8.decode(decodegZipJson);
}
