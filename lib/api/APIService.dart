import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:olr_rooms_web/api/Environment.dart';
import 'package:olr_rooms_web/model/AmenitiesResponse.dart';
import 'package:olr_rooms_web/model/AmenityResponse.dart';
import 'package:olr_rooms_web/model/AreaResponse.dart';
import 'package:olr_rooms_web/model/BannerResponse.dart';
import 'package:olr_rooms_web/model/BookingDetailResponse.dart';
import 'package:olr_rooms_web/model/BookingResponse.dart';
import 'package:olr_rooms_web/model/CancellationReasonResponse.dart';
import 'package:olr_rooms_web/model/CategoryResponse.dart';
import 'package:olr_rooms_web/model/CityResponse.dart';
import 'package:olr_rooms_web/model/CitySearchResponse.dart';
import 'package:olr_rooms_web/model/ConfirmBookingResponse.dart';
import 'package:olr_rooms_web/model/DashboardResponse.dart';
import 'package:olr_rooms_web/model/DataResponse.dart';
import 'package:olr_rooms_web/model/HOResponse.dart';
import 'package:olr_rooms_web/model/HelpResponse.dart';
import 'package:olr_rooms_web/model/HelplineResponse.dart';
import 'package:olr_rooms_web/model/HotelDetailResponse.dart';
import 'package:olr_rooms_web/model/HotelImagesResponse.dart';
import 'package:olr_rooms_web/model/HotelOfferResponse.dart';
import 'package:olr_rooms_web/model/HotelResponse.dart';
import 'package:olr_rooms_web/model/HotelSlotsResponse.dart';
import 'package:olr_rooms_web/model/HotelTimingsResponse.dart';
import 'package:olr_rooms_web/model/LoginResponse.dart';
import 'package:olr_rooms_web/model/NearbyResponse.dart';
import 'package:olr_rooms_web/model/PolicyResponse.dart';
import 'package:olr_rooms_web/model/PopBanner.dart';
import 'package:olr_rooms_web/model/PopBannerResponse.dart';
import 'package:olr_rooms_web/model/RequestTypeResponse.dart';
import 'package:olr_rooms_web/model/Response.dart' as R;
import 'package:olr_rooms_web/model/ReviewsResponse.dart';
import 'package:olr_rooms_web/model/SearchResponse.dart';
import 'package:olr_rooms_web/model/SignUpResponse.dart';
import 'package:olr_rooms_web/model/SpecialRequestResponse.dart';
import 'package:olr_rooms_web/model/TicketResponse.dart';
import 'package:olr_rooms_web/model/UserResponse.dart';
import 'package:olr_rooms_web/model/WishlistResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/OfferDetailResponse.dart';
import '../model/PopularCityResponse.dart';
import 'APIConstant.dart';

class APIService {
  getHeader() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      APIConstant.authorization : APIConstant.token+(sharedPreferences.getString("token")??"")+"."+base64Encode(utf8.encode(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()))),
      "Accept": "application/json",
    };
    return headers;
  }

  getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token")??"";
    return token;
  }
  Future<Map<String, dynamic>> getGSTDetails(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.getGSTDetails, queryParameters);
    print(url);
    var result = await http.get(url);
    print(result.body);

    return json.decode(result.body);
  }

  Future<String> sendSMS(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.sendSMS, queryParameters);
    // var url = Uri.https(APIConstant.smsApi1, APIConstant.smsApi2, queryParameters);
    print(url);
    // print(Uri.https(APIConstant.smsApi1, APIConstant.smsApi2, queryParameters));
    var result = await http.get(url);

    return result.body;
  }

  Future<dynamic> sendNSE(Map<String, dynamic> data) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.sendNSE, data);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    return result.body;
  }


  Future<DataResponse> getRazorApi() async{
    var url = Uri.parse(APIConstant.razorpayApiKey);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    DataResponse dataResponse = DataResponse.fromJson(json.decode(result.body));
    return dataResponse;
  }

  Future<R.Response> insertUserFCM(Map<String, dynamic> data) async {
    var url = Uri.parse(APIConstant.insertUserFCM);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);

    R.Response response = R.Response.fromJson(json.decode(result.body));
    return response;
  }

  Future<SignUpResponse> signUp(Map<String, dynamic> data) async{
    var url = Uri.parse(APIConstant.signUp);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    SignUpResponse signUpResponse = SignUpResponse.fromJson(json.decode(result.body));
    return signUpResponse;
  }

  Future<LoginResponse> login(Map<String, dynamic> data) async {
    print("hhs");
    var url = Uri.parse(APIConstant.login);
    // var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.login, data);
    print(Uri.https(Environment.url2, Environment.api2 + APIConstant.login, data).path);
    print("hhxxs");
    Map<String, String> headers = await getHeader();
    print("hhsxx");
    print(await http.post(url, body: jsonEncode(data), headers: headers));
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    print("hhsss");
  print(result.body);
    LoginResponse loginResponse = LoginResponse.fromJson(json.decode(result.body));
    return loginResponse;
  }

  Future<UserResponse> getUserDetails(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.manageCustomer, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    UserResponse userResponse = UserResponse.fromJson(json.decode(result.body));
    return userResponse;
  }

  Future<R.Response> updateUserDetails(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1 + Environment.api1 + APIConstant.manageCustomer);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    R.Response response = R.Response.fromJson(json.decode(result.body));
    return response;
  }

  Future<CityResponse> getAllCities(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.manageCities, queryParameters);
    print(url);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    CityResponse cityResponse = CityResponse.fromJson(json.decode(result.body));
    return cityResponse;
  }

  Future<CityResponse> getCitiesByName(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.manageCities, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    CityResponse cityResponse = CityResponse.fromJson(json.decode(result.body));
    return cityResponse;
  }

  Future<PopularCityResponse> getPopularCities(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.manageCities, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    PopularCityResponse popularCityResponse = PopularCityResponse.fromJson(json.decode(result.body));
    return popularCityResponse;
  }

  Future<BannerResponse> getBanners() async{
    var url = Uri.parse(APIConstant.getBanners);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    BannerResponse bannerResponse = BannerResponse.fromJson(json.decode(result.body));
    return bannerResponse;
  }

  Future<HOResponse> getHeadOffices() async{
    var url = Uri.parse(APIConstant.getHeadOffices);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HOResponse hoResponse = HOResponse.fromJson(json.decode(result.body));
    return hoResponse;
  }

  Future<PopBannerResponse> getPopBanner() async{
    var url = Uri.parse(APIConstant.getPopBanner);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    PopBannerResponse popBannerResponse = PopBannerResponse.fromJson(json.decode(result.body));
    return popBannerResponse;
  }

  Future<HotelResponse> getBannerHotels(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.manageHotels, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HotelResponse hotelResponse = HotelResponse.fromJson(json.decode(result.body));
    return hotelResponse;
  }

  Future<DashboardResponse> getDashboard() async{
    var url = Uri.parse(APIConstant.manageDashboard);
    Map<String, String> headers = await getHeader();
    // String token = await getToken();
    // print("token");
    var result = await http.get(url, headers: headers);
    DashboardResponse dashboardResponse = DashboardResponse.fromJson(json.decode(result.body));
    print(dashboardResponse.toJson());
    return dashboardResponse;
  }

  Future<HotelResponse> getDashboardHotels(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.manageHotels, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HotelResponse hotelResponse = HotelResponse.fromJson(json.decode(result.body));
    return hotelResponse;
  }

  Future<HotelResponse> getNearbyHotels(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.manageHotels, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HotelResponse hotelResponse = HotelResponse.fromJson(json.decode(result.body));
    return hotelResponse;
  }

  Future<HotelDetailResponse> getHotelDetails(Map<String, dynamic> queryParameters) async{

    var url = Uri.https(Environment.url2, APIConstant.manageHotels, queryParameters);
    print("queryParameterssss");
    Map<String, String> headers = await getHeader();
    print("queryParameterggeesdds");
    print(url);
    var result = await http.get(url, headers: headers);
    print("result.body");
    print(result.body);
    HotelDetailResponse hotelDetailResponse = HotelDetailResponse.fromJson(json.decode(result.body));
    return hotelDetailResponse;
  }

  Future<HotelImagesResponse> getHotelImages(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 +APIConstant.getHotelImages, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HotelImagesResponse hotelImagesResponse = HotelImagesResponse.fromJson(json.decode(result.body));
    return hotelImagesResponse;
  }


  Future<WishlistResponse> manageWishlist(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1 + Environment.api1 +APIConstant.manageWishlist);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    WishlistResponse wishlistResponse = WishlistResponse.fromJson(json.decode(result.body));
    return wishlistResponse;
  }

  Future<HotelSlotsResponse> getHotelSlots(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2,APIConstant.getHotelSlots, queryParameters);
    print(url);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HotelSlotsResponse hotelSlotsResponse = HotelSlotsResponse.fromJson(json.decode(result.body));
    return hotelSlotsResponse;
  }

  Future<CategoryResponse> getCategories(Map<String, dynamic> data) async{
    var url = Uri.parse(APIConstant.getCategories);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    CategoryResponse categoryResponse = CategoryResponse.fromJson(json.decode(result.body));
    return categoryResponse;
  }

  Future<AmenityResponse> getAmenities(Map<String, dynamic> data) async{
    var url = Uri.parse(APIConstant.getAmenities);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    AmenityResponse amenityResponse = AmenityResponse.fromJson(json.decode(result.body));
    return amenityResponse;
  }

  Future<HotelTimingsResponse>  getHotelTimings(Map<String, dynamic> data) async{
    var url = Uri.parse(APIConstant.manageHotelTimings);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    HotelTimingsResponse hotelTimingsResponse = HotelTimingsResponse.fromJson(json.decode(result.body));
    return hotelTimingsResponse;
  }

  Future<HotelTimingsResponse> checkAvailability(Map<String, dynamic> data) async{
    var url = Uri.parse(APIConstant.manageHotelTimings);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    print(result.body);
    HotelTimingsResponse hotelTimingsResponse = HotelTimingsResponse.fromJson(json.decode(result.body));
    return hotelTimingsResponse;
  }

  Future<NearbyResponse> getNearbyPlaces(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.getNearbyPlaces, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    NearbyResponse nearbyResponse = NearbyResponse.fromJson(json.decode(result.body));
    return nearbyResponse;
  }

  Future<SpecialRequestResponse> getSpecialRequests() async{
    var url = Uri.parse(APIConstant.getSpecialRequests);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    SpecialRequestResponse specialRequestResponse = SpecialRequestResponse.fromJson(json.decode(result.body));
    return specialRequestResponse;
  }

  Future<HotelOfferResponse> getHotelOffers(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1+Environment.api1+APIConstant.manageOffers);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    HotelOfferResponse hotelOfferResponse = HotelOfferResponse.fromJson(json.decode(result.body));
    return hotelOfferResponse;
  }

  Future<HotelOfferResponse> getAllOffers(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2+APIConstant.manageOffers, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HotelOfferResponse hotelOfferResponse = HotelOfferResponse.fromJson(json.decode(result.body));
    return hotelOfferResponse;
  }

  Future<OfferDetailResponse> getOfferDetails(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1+Environment.api1+APIConstant.manageOffers);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    OfferDetailResponse offerDetailResponse = OfferDetailResponse.fromJson(json.decode(result.body));
    return offerDetailResponse;
  }

  Future<ConfirmBookingResponse> insertBooking(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1 + Environment.api1 + APIConstant.manageBookings);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    ConfirmBookingResponse confirmBookingResponse = ConfirmBookingResponse.fromJson(json.decode(result.body));
    return confirmBookingResponse;
  }


  Future<BookingResponse> getMyBookings(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.manageBookings, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    BookingResponse bookingResponse = BookingResponse.fromJson(json.decode(result.body));
    return bookingResponse;
  }

  Future<BookingDetailResponse> getBookingDetails(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.manageBookings, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    BookingDetailResponse bookingDetailResponse = BookingDetailResponse.fromJson(json.decode(result.body));
    return bookingDetailResponse;
  }

  Future<HotelResponse> getWishlistHotels(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.manageWishlist, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HotelResponse hotelResponse = HotelResponse.fromJson(json.decode(result.body));
    return hotelResponse;
  }

  Future<PolicyResponse> getPolicy(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.managePolicies, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    PolicyResponse policyResponse = PolicyResponse.fromJson(json.decode(result.body));
    return policyResponse;
  }

  Future<RequestTypeResponse> getRequestTypes(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.getRequestTypes, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    RequestTypeResponse requestTypeResponse = RequestTypeResponse.fromJson(json.decode(result.body));
    return requestTypeResponse;
  }

  Future<TicketResponse> getRequestedTickets(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, Environment.api2 + APIConstant.manageTickets, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    TicketResponse ticketResponse = TicketResponse.fromJson(json.decode(result.body));
    return ticketResponse;
  }

  Future<R.Response> raiseTicket(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1 + Environment.api1 + APIConstant.manageTickets);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    R.Response response = R.Response.fromJson(json.decode(result.body));
    return response;
  }

  Future<SearchResponse> search(Map<String, dynamic> data) async{
    var url = Uri.parse(APIConstant.manageSearch);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    SearchResponse searchResponse = SearchResponse.fromJson(json.decode(result.body));
    return searchResponse;
  }

  Future<CitySearchResponse> citySearch(Map<String, dynamic> data) async{
    var url = Uri.parse(APIConstant.manageSearch);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    CitySearchResponse citySearchResponse = CitySearchResponse.fromJson(json.decode(result.body));
    return citySearchResponse;
  }

  Future<HotelResponse> getSearchedHotels(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.manageHotels, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HotelResponse hotelResponse = HotelResponse.fromJson(json.decode(result.body));
    return hotelResponse;
  }

  Future<HotelResponse> getFilteredHotels(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.manageHotels, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HotelResponse hotelResponse = HotelResponse.fromJson(json.decode(result.body));
    return hotelResponse;
  }

  Future<HelplineResponse> getOlrHelplines() async{
    var url = Uri.parse(APIConstant.getOlrHelplines);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HelplineResponse helplineResponse = HelplineResponse.fromJson(json.decode(result.body));
    return helplineResponse;
  }

  Future<HelpResponse> getOlrHelps() async{
    var url = Uri.parse(APIConstant.getOlrHelps);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    HelpResponse helpResponse = HelpResponse.fromJson(json.decode(result.body));
    return helpResponse;
  }

  Future<ReviewsResponse> getRatings(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2 ,Environment.api2 + APIConstant.manageReviews, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    ReviewsResponse reviewsResponse = ReviewsResponse.fromJson(json.decode(result.body));
    return reviewsResponse;
  }

  Future<R.Response> becomePartner(Map<String, dynamic> data) async{
    var url = Uri.parse(APIConstant.becomePartner);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    R.Response response = R.Response.fromJson(json.decode(result.body));
    return response;
  }

  Future<AreaResponse> getAreasByName(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.manageAreas, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    AreaResponse areaResponse = AreaResponse.fromJson(json.decode(result.body));
    return areaResponse;
  }

  Future<AreaResponse> getAreasByCity(Map<String, dynamic> queryParameters) async{
    var url = Uri.https(Environment.url2, APIConstant.manageAreas, queryParameters);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    AreaResponse areaResponse = AreaResponse.fromJson(json.decode(result.body));
    return areaResponse;
  }

  Future<AmenitiesResponse> getAllAmenities() async{
    var url = Uri.parse(APIConstant.getAmenities);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    AmenitiesResponse amenitiesResponse = AmenitiesResponse.fromJson(json.decode(result.body));
    return amenitiesResponse;
  }

  Future<CancellationReasonResponse> getCancellationReasons() async{
    var url = Uri.parse(APIConstant.getCancellationReasons);
    Map<String, String> headers = await getHeader();
    var result = await http.get(url, headers: headers);
    CancellationReasonResponse cancellationReasonResponse = CancellationReasonResponse.fromJson(json.decode(result.body));
    return cancellationReasonResponse;
  }

  Future<R.Response> cancelBooking(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1 + Environment.api1 + APIConstant.manageBookings);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    R.Response response = R.Response.fromJson(json.decode(result.body));
    return response;
  }

  Future<R.Response> deleteBooking(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1 + Environment.api1 + APIConstant.manageBookings);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    print(result.body);
    R.Response response = R.Response.fromJson(json.decode(result.body));
    return response;
  }

  Future<R.Response> modifyGuestName(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1 + Environment.api1 + APIConstant.manageBookings);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    R.Response response = R.Response.fromJson(json.decode(result.body));
    return response;
  }

  Future<R.Response> giveRatings(Map<String, dynamic> data) async{
    var url = Uri.parse(Environment.url1 + Environment.api1 + APIConstant.manageReviews);
    Map<String, String> headers = await getHeader();
    var result = await http.post(url, body: jsonEncode(data), headers: headers);
    R.Response response = R.Response.fromJson(json.decode(result.body));
    return response;
  }
}
