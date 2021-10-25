import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GraphQLGateway', () {
    
  });
}

class CountryGateway extends GraphQLGateway<CountryGatewayOutput,
    CountryRequest, CountrySuccessInput> {
  CountryGateway()
      : super(
          context: providersContext,
          provider: countryUseCaseProvider,
        );

  @override
  CountryRequest buildRequest(CountryGatewayOutput output) {
    return CountryRequest(
      continentCode: output.continentCode,
    );
  }

  @override
  FailureInput onFailure(FailureResponse failureResponse) {
    return FailureInput(message: 'test');
  }

  @override
  CountrySuccessInput onSuccess(GraphQLSuccessResponse response) {
    return CountrySuccessInput.fromJson(response.data);
  }
}

class CountryRequest extends QueryGraphQLRequest {
  CountryRequest({required this.continentCode});

  final String continentCode;

  @override
  String get document => r'''
    query ($countriesFilter: CountryFilterInput) {
      countries(filter: $countriesFilter) {
        name
        emoji
        capital
      }
    }
  ''';

  @override
  Map<String, dynamic>? get variables {
    return {
      'countriesFilter': {
        'continent': {'eq': continentCode}
      }
    };
  }

  @override
  List<Object?> get props => [continentCode];
}