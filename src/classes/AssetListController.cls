global class AssetListController {

    public AssetListController(ApexPages.StandardController controller) {

    }

    
    @RemoteAction global static list<Asset> GetRelatedAssets(integer rowLimit, string aType)     
    {
        list<Asset> aList = new list<Asset>();
        
        try {
            aList = [
                select  id,
                        Name,
                        RecordType.Name,
                        MUTCD__c,
                        Condition__c,
                        InstallDate,
                        createdBy.name,
                        Begin_Location__Latitude__s,
                        Begin_Location__Longitude__s
                  from  Asset c
                 where  c.RecordType.Name = :aType
                   and  c.Begin_Location__Latitude__s != null
                   and  c.Begin_Location__Longitude__s!= null
                   and  DISTANCE(Begin_Location__c, GEOLOCATION(40.5791,-111.80483), 'mi') < 1
                  order by c.InstallDate
                  limit :rowLimit
            ];              
        } catch (system.Dmlexception e) {
            system.debug(e.getMessage());
        }
        
        return aList;
    }
    
    
    ApexPages.StandardController controller {get; set;}
    public Asset anAsset { get; private set; }
}