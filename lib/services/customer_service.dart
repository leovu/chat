import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/customer_account.dart';

class CustomerService {
  static Future<CustomerAccount?> detect(HTTPConnection connection, String userId) async {
    final responseData = await connection.post('api/customer/detect', {'user_id': userId});
    if (responseData.isSuccess) return CustomerAccount.fromJson(responseData.data);
    return null;
  }

  static Future<bool> customerLink(
    HTTPConnection connection,
    String userId,
    int? customerId, {
    String? typeCustomer,
    String? mappingId,
    String? source,
    String? socialId,
    String? customerLeadId = '',
  }) async {
    final json = {
      'user_id': userId,
      if (mappingId != null) 'mapping_id': mappingId,
      'type_customer': typeCustomer,
      'customer_id': customerId,
      'type_social': source,
      'social_id': socialId,
      if (customerLeadId != null && customerLeadId.isNotEmpty)
        'customer_lead_id': customerLeadId,
    };
    final responseData = await connection.post('api/customer/link', json);
    return responseData.isSuccess;
  }

  static Future<CustomerAccount?> customerUnlink(
    HTTPConnection connection,
    String userId,
    int? customerId, {
    int? customerLeadId,
  }) async {
    final Map<String, dynamic> json = {'user_id': userId};
    if (customerId != null) json['customer_id'] = customerId;
    if (customerLeadId != null) json['customer_lead_id'] = customerLeadId;
    final responseData = await connection.post('api/customer/remove-link', json);
    if (responseData.isSuccess) return CustomerAccount.fromJson(responseData.data);
    return null;
  }

  static Future<List<CustomerAccount?>?> searchCustomer(HTTPConnection connection, String keyword) async {
    final responseData = await connection.post('api/customer/search', {'keyword': keyword, 'limit': 50});
    if (responseData.isSuccess) {
      try {
        final List<dynamic> data = responseData.data['data'];
        return data.map((e) => CustomerAccount.fromJson({'data': e})).toList();
      } catch (_) {}
    }
    return null;
  }

  static Future<bool> updateNameChatHub(HTTPConnection connection, String id, String typeCustomer, String fullName) async {
    final responseData = await connection.post('api/customer/update/$id', {
      'type_customer': typeCustomer,
      'data': {'full_name': fullName},
    });
    return responseData.isSuccess;
  }
}
