import '../../../../shared/services/api_client.dart';
import '../../domain/entities/bet.dart';
import '../../domain/entities/place_bet_input.dart';
import '../../domain/repositories/bets_repository.dart';
import '../models/bet_model.dart';
import '../models/place_bet_response_model.dart';

class ApiBetsRepository implements BetsRepository {
  ApiBetsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Bet> placeBet(PlaceBetInput input) async {
    final payload = await _apiClient.postJson(
      '/goals/${input.goalId}/bets',
      body: <String, dynamic>{
        'side': input.side.name,
        'amount': input.amount,
      },
    );
    return PlaceBetResponseModel.fromJson(payload).bet;
  }

  @override
  Future<List<Bet>> getBetsForGoal(String goalId) async {
    final payload = await _apiClient.getJsonList(
      '/users/me/bets',
      queryParameters: <String, String>{'goal_id': goalId},
    );
    return payload
        .map((item) => BetModel.fromJson(_asMap(item)).toEntity())
        .toList(growable: false);
  }

  @override
  Future<List<Bet>> getBetsForUser(String userId) async {
    final payload = await _apiClient.getJsonList('/users/me/bets');
    return payload
        .map((item) => BetModel.fromJson(_asMap(item)).toEntity())
        .toList(growable: false);
  }

  Map<String, dynamic> _asMap(Object? value) {
    return Map<String, dynamic>.from(value as Map);
  }
}
