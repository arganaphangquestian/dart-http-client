import 'package:cli/client.dart';

void main(List<String> arguments) async {
  // Inject into GetX DI
  final devH = APIClient(APIType.development).useAuth().build();
  final stgH = APIClient(APIType.staging).useAlterCertificate().build();
  final prdH = APIClient(APIType.production).useRetry().build();

  final dev = await devH.get("/todos");
  print(dev.data);
  final stg = await stgH.get("/todos/1");
  print(stg.data);
  final prd = await prdH.get("/todos");
  print(prd.data);
}
