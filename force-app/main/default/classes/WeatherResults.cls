public with sharing class WeatherResults {
    public Long dataForecasted;
    public Decimal minTemp;
    public Decimal maxTemp;
    public String condition;

    public WeatherResults(Long dataForecasted, Decimal minTemp, Decimal maxTemp, String condition) {
        this.dataForecasted = dataForecasted;
        this.minTemp = minTemp;
        this.maxTemp = maxTemp;
        this.condition = condition;
    }
}