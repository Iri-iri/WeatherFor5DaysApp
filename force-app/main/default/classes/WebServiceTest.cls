/**
 * Created by ilevkovich on 4/28/2021.
 */
@IsTest
private class WServiceTest {

    @IsTest static void testGetCallout() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WeatherCallout');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        WService.main('546055');

        List <ForecastItem_c__c> myListOfRorecasts = [SELECT Date__c, Weather_condition__c FROM ForecastItem_c__c];

        System.debug(myListOfRorecasts);
        System.assertEquals('Clouds', myListOfRorecasts[0].Weather_condition__c);
    }

    @IsTest static void testWFRecordCreationWInvalidStatusCode() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WetherCalloutWNoItems');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        WService.main('546055');

        System.assertEquals(0, [SELECT COUNT() FROM ForecastItem_c__c]);

    }

    @IsTest static void testWFRecordCreationWInvalidData() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WeatherCalloutWInvalidData');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        Boolean hasException = false;

        try {
            WService.main('546055');
        } catch (Exception e) {
            hasException = true;
            System.assertEquals('Invalid conversion from runtime type String to Long', e.getMessage());
        }

        System.assert(hasException);
    }

    @IsTest static void testWFRecordCreationNoDublicates() {

        List <ForecastItem_c__c> newListForecast = new List<ForecastItem_c__c>();

        ForecastItem_c__c myForecastListItem1 = new ForecastItem_c__c();

        Date newDate1 = Datetime.newInstance(1620216000L * 1000).date();
        myForecastListItem1.Name = 'Day' + newDate1.format();
        myForecastListItem1.Date__c = newDate1;
        myForecastListItem1.Temp_min__c = 5.23;
        myForecastListItem1.Temp_max__c = 5.23;
        myForecastListItem1.Weather_condition__c = 'Rain';

        newListForecast.add(myForecastListItem1);

        ForecastItem_c__c myForecastListItem2 = new ForecastItem_c__c();

        Date newDate2 = Datetime.newInstance(1620388800L * 1000).date();
        myForecastListItem2.Name = 'Day' + newDate2.format();
        myForecastListItem2.Date__c = newDate2;
        myForecastListItem2.Temp_min__c = 4.69;
        myForecastListItem2.Temp_max__c = 4.69;
        myForecastListItem2.Weather_condition__c = 'Rain';

        newListForecast.add(myForecastListItem2);
        insert newListForecast;

        Test.startTest();

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WeatherResaltsTest');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        WService.main('546055');

        Test.stopTest();

        System.assertEquals(4, [SELECT COUNT() FROM ForecastItem_c__c]);

    }
}
