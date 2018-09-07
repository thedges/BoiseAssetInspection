public class AssetInspectionController {
    public List<AssetWrapper> nearybyList = new List<AssetWrapper>();
    public String fileName {get; set;}
    public String contentType {get; set;}
    public transient Blob photoUpload {get; set;}
    public Asset asset {get; set;}

    public Decimal latitude {get; set;}
    public Decimal longitude {get; set;}

    public Inspection__c inspection {get; set;}

    public Id selectedAssetId {get; set;}

    public AssetInspectionController() 
    {
        asset = new Asset();
        String tmpStr;

        //////////////////////////////////////////////////////////////////////////
        // load existing maintenance record if "id" URL parameters is passed in //
        //////////////////////////////////////////////////////////////////////////
        tmpStr = ApexPages.currentPage().getParameters().get('id');
        if (tmpStr != null) {
            asset = [SELECT Id, Name, Begin_Location__Latitude__s, Begin_Location__Longitude__s, Condition__c, Region__c, Station__c, UDOT_ID__c 
                              FROM Asset 
                             WHERE Id=:tmpStr];
        }

        inspection = new Inspection__c();

        if (asset != null && asset.Condition__c != null) inspection.Condition__c = asset.Condition__c;

        //////////////////////////////
        // set date/time to current //
        //////////////////////////////
        //asset.Date_Time__c = Datetime.now();
    }

    public String getCurrentCoords()
    {
        if (latitude != null && longitude != null)
        {
          return latitude + ',' + longitude;
        }
        else
        {
            return 'Not determined';
        }
    }

    public String getAssetCoords()
    {
        if (asset.Begin_Location__Latitude__s != null && asset.Begin_Location__Longitude__s != null)
        {
          return asset.Begin_Location__Latitude__s + ',' + asset.Begin_Location__Longitude__s;
        }
        else
        {
            return 'Not determined';
        }
    }

    public class AssetWrapper{
        public Asset asset {get; set;}
        public Integer distance {get; set;}
    }

    public PageReference backToAsset()
    {
        getNearbyList().clear();
        return null;
    }

    public PageReference selectAsset()
    {
        asset = [SELECT Id, Name, Begin_Location__Latitude__s, Begin_Location__Longitude__s, Condition__c, Region__c, Station__c, UDOT_ID__c 
                              FROM Asset 
                             WHERE Id=:selectedAssetId];
        getNearbyList().clear();

        return null;
    }

    public PageReference findNearby()
    {
        getNearbyList().clear();

        String queryStr = 'SELECT Id, Name, RecordType.Name, Begin_Location__Latitude__s, Begin_Location__Longitude__s, Condition__c, Region__c, Station__c, UDOT_ID__c, MUTCD__c, MUTCD_Description__c, Legend__c \n' +
                          '  FROM Asset \n' +
                          ' WHERE Id != \'' + asset.id + '\'\n' +
                          '   AND Begin_Location__Latitude__s != null AND Begin_Location__Longitude__s != null\n' +
 //                         '       AND DISTANCE(Begin_Location__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\') < 20\n' +
                          ' ORDER BY DISTANCE(Begin_Location__c, GEOLOCATION(' + asset.Begin_Location__Latitude__s + ',' + asset.Begin_Location__Longitude__s + '), \'mi\')\n' +
                          ' LIMIT 10';
        System.debug(queryStr);
        List<Asset> tmpList = Database.query(queryStr);

        if (tmpList.size() > 0)
        {
            for (Asset a : tmpList)
            {
              AssetWrapper aw = new AssetWrapper();
              aw.asset = a;
              aw.distance = Integer.valueOf(DemoUtils.calculateHaversineDistance(asset.Begin_Location__Latitude__s, asset.Begin_Location__Longitude__s, 
                                                                 a.Begin_Location__Latitude__s, a.Begin_Location__Longitude__s, 5)*5280);
              getNearbyList().add(aw);
            }
        }
        return null;
    }

    public List<AssetWrapper> getNearbyList()
    {
        return nearybyList;
    }

    public PageReference submit() 
    {
        /////////////////////////
        // get picture details //
        /////////////////////////
        System.debug('filename=' + fileName);
        System.debug('contentType=' + contentType);
        if (photoUpload != null)
            System.debug('photo.size=' + photoUpload.size());
        else
            System.debug('photo is empty!');

        //////////////////////////////
        // insert inspection record //
        //////////////////////////////    
        inspection.Inspector__c = UserInfo.getUserId();
        inspection.Asset__c = asset.Id;
        if (latitude != null) inspection.Inspection_Location__Latitude__s = latitude;
        if (longitude != null) inspection.Inspection_Location__Longitude__s = longitude;
        insert inspection;

        
        ///////////////////////////////////////////////////////////////
        // if photo was sent, add as attachment to inspection record //
        ///////////////////////////////////////////////////////////////
        if (photoUpload != null) {
            Attachment objA = new Attachment();
            objA.body = photoUpload;
            objA.name = fileName;
            objA.parentid = inspection.Id;
            objA.ContentType = contentType;
            insert objA;
        }

        //return new PageReference('/AssetInspectionConfirmation?id=' + asset.Id);
        return new PageReference('/' + asset.Id);

    }

}