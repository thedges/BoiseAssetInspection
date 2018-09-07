public class DemoUtils {
    public DemoUtils() {

    }

    public static Decimal calculateHaversineDistance(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2, Integer scale) {
        if ((lat1 == null) || (lon1 == null) || (lat2 == null) || (lon2 == null)) {
            return null;
        }
        // Earth's radius varies from 6356.752 km at the poles to 6378.137 km at the equator
        Double radius = 6371.00;
        Double dLat = toRadians(lat2 - lat1);
        Double dLon = toRadians(lon2 - lon1);
        Double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        Double c = 2 * Math.asin(Math.sqrt(a));

        double kmToMiles = 0.621371;
        return Decimal.valueOf(radius * c * kmToMiles).setScale(scale);
    }

    private static Double toRadians(Decimal degree) {
        return degree * 3.1415926 / 180;
    }
}