

class InitBasSdkModel {
  final String trxToken;
  String? userIdentifier;
  String? fullName;
  String? language;
  final String platform;
  String? product;
  String? environment;

  InitBasSdkModel.prod({
    required this.trxToken,
    this.userIdentifier,
    this.fullName,
    this.language,
    this.product,
  }) : platform = "Flutter" , environment = "prod";

  InitBasSdkModel.dev({
    required this.trxToken,
    this.userIdentifier,
    this.fullName,
    this.language,
    this.product,
  }) : platform = "Flutter" , environment = "dev";


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[InitBasSdkModelFields.trxToken] = trxToken;
    data[InitBasSdkModelFields.userIdentifier] = userIdentifier;
    data[InitBasSdkModelFields.fullName] = fullName;
    data[InitBasSdkModelFields.language] = language;
    data[InitBasSdkModelFields.platform] = platform;
    data[InitBasSdkModelFields.product] = product;
    data[InitBasSdkModelFields.environment] = environment;
    return data;
  }

}


abstract class InitBasSdkModelFields {
  static const String trxToken = 'trxToken';
  static const String userIdentifier = 'userIdentifier';
  static const String fullName = 'fullName';
  static const String language = 'language';
  static const String platform = 'platform';
  static const String product = 'product';
  static const String environment = 'environment';
}