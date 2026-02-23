import '../../core/constants/app_assets.dart';
import '../models/disease_model.dart';

class DiseaseRepository {
  // Static disease registry
  static const List<DiseaseModel> _diseases = [
    DiseaseModel(id: '1', localizationKey: 'dsAppleScab', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '2', localizationKey: 'dsAppleBlackRot', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '3', localizationKey: 'dsAppleCedarRust', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '4', localizationKey: 'dsCherryPowderyMildew', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '5', localizationKey: 'dsCornCercospora', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '6', localizationKey: 'dsCornCommonRust', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '7', localizationKey: 'dsCornNorthernBlight', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '8', localizationKey: 'dsGrapeBlackRot', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '9', localizationKey: 'dsGrapeEsca', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '10', localizationKey: 'dsGrapeLeafBlight', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '11', localizationKey: 'dsOrangeHLB', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '12', localizationKey: 'dsPeachBacterialSpot', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '13', localizationKey: 'dsPepperBacterialSpot', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '14', localizationKey: 'dsPotatoEarlyBlight', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '15', localizationKey: 'dsPotatoLateBlight', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '16', localizationKey: 'dsSquashPowderyMildew', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '17', localizationKey: 'dsStrawberryLeafScorch', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '18', localizationKey: 'dsTomatoBacterialSpot', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '19', localizationKey: 'dsTomatoEarlyBlight', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '20', localizationKey: 'dsTomatoLateBlight', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '21', localizationKey: 'dsTomatoLeafMold', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '22', localizationKey: 'dsTomatoSeptoria', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '23', localizationKey: 'dsTomatoSpiderMites', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '24', localizationKey: 'dsTomatoTargetSpot', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '25', localizationKey: 'dsTomatoYellowCurl', thumbnailPath: AppAssets.logo),
    DiseaseModel(id: '26', localizationKey: 'dsTomatoMosaic', thumbnailPath: AppAssets.logo),
  ];

  // Retrieve disease list
  List<DiseaseModel> getAllDiseases() => List.unmodifiable(_diseases);
}