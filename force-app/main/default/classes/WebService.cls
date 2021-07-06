
public with sharing class WService {

    public static void main(String cityId) {

        List<WeatherResults> myList = get5DaysForc(cityId);

        List <ForecastItem_c__c> myForecastList = new List<ForecastItem_c__c>();

        Set<Date> mySetOfDates = new Set<Date>();

        for (WeatherResults itemWeatherResultDate : myList) {
            mySetOfDates.add(Datetime.newInstance(itemWeatherResultDate.dataForecasted).date());
        }

        Set<Date> mySetOfNoDublicatesSet = new Set<Date>();

        List <ForecastItem_c__c> myNoDublicateDatesList = [SELECT Date__c FROM ForecastItem_c__c WHERE Date__c IN :mySetOfDates];
        for (ForecastItem_c__c itemForecastDates : myNoDublicateDatesList) {
            mySetOfNoDublicatesSet.add(itemForecastDates.Date__c);
        }

        for (WeatherResults myListItem : myList) {

            if (!mySetOfNoDublicatesSet.contains(Datetime.newInstance(myListItem.dataForecasted).date())) {

                ForecastItem_c__c myForecastListItem = new ForecastItem_c__c();

                Date newDate = Datetime.newInstance(myListItem.dataForecasted).date();

                myForecastListItem.Name = 'Day' + newDate.format();
                myForecastListItem.Date__c = newDate;
                myForecastListItem.Temp_min__c = myListItem.minTemp;
                myForecastListItem.Temp_max__c = myListItem.maxTemp;
                myForecastListItem.Weather_condition__c = myListItem.condition;

                myForecastList.add(myForecastListItem);
            }
        }
        insert myForecastList;

    }


    public static List<WeatherResults> get5DaysForc(String cityId) {
        List<WeatherResults> result = new List<WeatherResults>();

        if (String.isNotBlank(cityId)) {
            String requestBody = getRequestBody(cityId);

            if (String.isNotBlank(requestBody)) {
                result = parseRequestBody(requestBody);
            }
        }

        return result;

    }


    public static String getRequestBody(String cityId) {
        String result = null;


        HttpRequest request = new HttpRequest();

        request.setEndpoint('https://api.openweathermap.org/data/2.5/forecast?id=' + cityId + '&appid=123eb0c25a954ebc9655135f457a8de3&units=metric');
        request.setMethod('GET');

        try {
            HttpResponse response = (new Http()).send(request);

            if (response.getStatusCode() == 200) {
                result = response.getBody();
            }
        } catch (Exception e) {

            System.debug('The following exception has occurred:' + e.getMessage());
        }

        return result;
    }

    private static List<WeatherResults> parseRequestBody(String requestBody) {
        List<WeatherResults> result = new List<WeatherResults>();

        Map<String, Object> mainObj = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

        List<Object> listNode = (List<Object>) mainObj.get('list');

        for (Object listNodeItem : listNode) {

            Map<String, Object> listNodeMap = (Map<String, Object>) listNodeItem;

            Long dtNode = (Long) listNodeMap.get('dt');

            Datetime currentDate = Datetime.newInstance(dtNode * 1000);

            Integer currentHour = currentDate.hourGmt();

            if (currentHour == 12) {


                Map<String, Object> mainNode = (Map<String, Object>) listNodeMap.get('main');

                Decimal temp_min = (Decimal) mainNode.get('temp_min');
                Decimal temp_max = (Decimal) mainNode.get('temp_max');

                List<Object> weatherArray = (List<Object>) listNodeMap.get('weather');
                Map<String, Object> weatherNode = (Map<String, Object>) weatherArray.get(0);
                String condition = (String) weatherNode.get('main');

                WeatherResults weatherResultsItem = new WeatherResults(
                        dtNode * 1000,
                        temp_min,
                        temp_max,
                        condition
                );
                result.add(weatherResultsItem);

            }
        }

        return result;
    }

}