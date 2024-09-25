import 'dart:convert';

import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:datasource/datasource.dart';
import 'package:datasource/src/constants.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  final db = DynamoDB(
    region: 'region',
    endpointUrl: 'http://localhost:8000',
    credentials: AwsClientCredentials(
      accessKey: 'accessKey',
      secretKey: 'secretKey',
    ),
  );
  final ds = DynamodbDataSource(db);

  setUpAll(() async {
    await db.createTable(
      attributeDefinitions: [
        AttributeDefinition(
          attributeName: mvTrTypeKey,
          attributeType: ScalarAttributeType.s,
        )
      ],
      keySchema: [
        KeySchemaElement(
          attributeName: mvTrTypeKey,
          keyType: KeyType.hash,
        )
      ],
      tableName: mvTrTableName,
      billingMode: BillingMode.provisioned,
      provisionedThroughput: ProvisionedThroughput(
        readCapacityUnits: 5,
        writeCapacityUnits: 5,
      ),
    );
    return Future.delayed(const Duration(seconds: 2));
  });

  tearDownAll(() {
    db.close();
  });

  setUp(() async {
    await db.putItem(
      item: {
        mvTrTypeKey: AttributeValue(s: mvTrSettingsType),
        mvTrDataKey: AttributeValue(nullValue: true),
      },
      tableName: mvTrTableName,
    );
    await db.putItem(
      item: {
        mvTrTypeKey: AttributeValue(s: mvTrMoviesType),
        mvTrDataKey: AttributeValue(nullValue: true),
        mvTrImageBaseUrlKey: AttributeValue(nullValue: true),
        mvTrLastUpdateKey: AttributeValue(nullValue: true),
      },
      tableName: mvTrTableName,
    );
  });

  test('getSettings null', () async {
    final result = await ds.getSettings();
    expect(result, isNull);
  });

  test('getSettings setSettings', () async {
    final settings = Settings(
      tmdbApiKey: 'tmdbApiKey',
      imageBaseUrl: 'imageBaseUrl',
      trackerSettings: [
        TrackerSettings(
          trackerType: TrackerType.nnmclub,
          trackerUrl: 'trackerUrl',
          trackerRequest: 'trackerRequest',
        ),
      ],
    );
    await ds.setSettings(settings);
    final result = await ds.getSettings();
    expect(result, isNotNull);
    expect(json.encode(result), equals(json.encode(settings)));
  });

  test('getSettings fields null empty', () async {
    final settings = Settings(
      tmdbApiKey: null,
      imageBaseUrl: '',
      trackerSettings: [
        TrackerSettings(
          trackerType: TrackerType.nnmclub,
          trackerUrl: 'trackerUrl',
          trackerRequest: 'trackerRequest',
        ),
      ],
    );
    await ds.setSettings(settings);
    final result = await ds.getSettings();
    expect(result, isNotNull);
    expect(json.encode(result), equals(json.encode(settings)));
  });

  test('getMoviesData null', () async {
    final result = await ds.getMoviesData();
    expect(result, isNull);
  });

  test('getMoviesData updateMovies', () async {
    final movies = Movies(
      movies: [
        MovieInfo(
          tmdbId: 1,
          imdbId: 'imdbId',
          kinopoiskId: 'kinopoiskId',
          posterPath: 'posterPath',
          overview: 'overview',
          releaseDate: DateTime(2000),
          title: 'title',
          backdropPath: 'backdropPath',
          rating: MovieRating(
            imdbVoteAverage: 1,
            imdbVoteCount: 2,
            kinopoiskVoteAverage: 3,
            kinopoiskVoteCount: 4,
            tmdbVoteCount: 5,
            tmdbVoteAverage: 6,
          ),
          torrentsInfo: [
            MovieTorrentInfo(
              magnetUrl: 'magnetUrl',
              title: 'title',
              size: 1,
              seeders: 2,
              leechers: 3,
              audio: ['audio', 'audio2'],
              date: DateTime(2000),
            )
          ],
          youtubeTrailerKey: 'youtubeTrailerKey',
          cast: [
            MovieCast(
              character: 'character',
              name: 'name',
              profilePath: 'profilePath',
            )
          ],
          crew: [],
          productionCountries: ['productionCountries'],
          genres: ['genres'],
        )
      ],
      lastUpdate: DateTime(2003),
      imageBaseUrl: 'imageBaseUrl',
    );
    await ds.updateMovies(movies.imageBaseUrl, movies.movies, DateTime(2003));
    final result = await ds.getMoviesData();
    expect(result, isNotNull);
    expect(json.encode(result), equals(json.encode(movies)));
  });
}
