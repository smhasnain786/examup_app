import 'package:ready_lms/model/common/common_response_model.dart';
import 'package:ready_lms/model/course_detail.dart';
import 'package:ready_lms/service/checkout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckOutController extends StateNotifier<CheckOut> {
  final Ref ref;
  CheckOutController(super.state, this.ref);

  getNewCourseDetails(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final response =
          await ref.read(checkoutServiceProvider).courseDetailByID(id: id);
      state.courseDetails = CourseDetailModel.fromJson(response.data['data']);
      state.totalPrice =
          double.parse(state.courseDetails!.course.price.toString());
      state.discountPresent = (1 -
              (state.courseDetails!.course.price! /
                  state.courseDetails!.course.regularPrice!)) *
          100;
      state.discountAmount = double.parse(
          (state.courseDetails!.course.regularPrice! -
                  state.courseDetails!.course.price!)
              .toString());
    } catch (error) {
      debugPrint(error.toString());
      state.courseDetails = null;
    } finally {
      state.isLoading = false;
      state = state._update(state);
    }
  }

  Future<CommonResponse> enrollCourseById(
      {required int id, int? couponId}) async {
    state = state.copyWith(isEnrollLoading: true);
    bool isSuccess = false;

    try {
      final response = await ref
          .read(checkoutServiceProvider)
          .enrollCourseById(id: id, couponId: couponId, query: {
        'payment_gateway': state.paymentMethod,
        if (state.couponCode != '') 'coupon_code': state.couponCode
      });
      state.isEnrollLoading = false;
      if (response.statusCode == 201) {
        isSuccess = true;
      }
      return CommonResponse(
          isSuccess: isSuccess,
          message: response.data['message'],
          response:
              !isSuccess ? null : response.data['data']['payment_webview_url']);
    } catch (error) {
      debugPrint(error.toString());
      state.isEnrollLoading = false;
      return CommonResponse(isSuccess: isSuccess, message: error.toString());
    } finally {
      state.isEnrollLoading = false;
      state = state._update(state);
    }
  }

// Future<CommonResponse> enrollCourseById(
//       {required int id, int? couponId}) async {
//     state = state.copyWith(isEnrollLoading: true);
//     bool isSuccess = false;

//     try {
//       final response = await ref.read(checkoutServiceProvider).enrollCourseById(
//           id: id,
//           couponId: couponId,
//           query: {'payment_gateway': state.paymentMethod});
//       state.isEnrollLoading = false;
//       if (response.statusCode == 200) {
//         isSuccess = true;
//       }
//       return CommonResponse(
//           isSuccess: isSuccess,
//           message: response.data['message'],
//           response: !isSuccess ? null : response.data['data']['enrollment_id']);
//     } catch (error) {
//       debugPrint(error.toString());
//       state.isEnrollLoading = false;
//       return CommonResponse(isSuccess: isSuccess, message: error.toString());
//     } finally {
//       state.isEnrollLoading = false;
//       state = state._update(state);
//     }
//   }
  removeCoupon() {
    state = state.copyWith(
        couponValidStatus: false, couponAmount: 0.0, couponCode: '');
  }

  Future<CommonResponse> couponValidate({required String code}) async {
    state = state.copyWith(applyCouponLoading: true);

    bool isSuccess = false;

    try {
      final response =
          await ref.read(checkoutServiceProvider).couponValidate(code: code);
      state.applyCouponLoading = false;
      if (response.statusCode == 200) {
        isSuccess = true;
        state = state.copyWith(
            couponValidStatus: true,
            couponAmount:
                double.parse(response.data['data']['discount'].toString()),
            couponCode: code);
      }
      return CommonResponse(
          isSuccess: isSuccess, message: response.data['message']);
    } catch (error) {
      debugPrint(error.toString());
      removeCoupon();
      return CommonResponse(isSuccess: isSuccess, message: error.toString());
    } finally {
      state.applyCouponLoading = false;
      state = state._update(state);
    }
  }

  setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }
}

class CheckOut {
  String couponCode;
  bool isLoading, applyCouponLoading, couponValidStatus, isEnrollLoading;
  double discountAmount, discountPresent, couponAmount, totalPrice;
  CourseDetailModel? courseDetails;
  String paymentMethod;
  CheckOut(
      {this.isLoading = false,
      this.isEnrollLoading = false,
      this.applyCouponLoading = false,
      this.couponValidStatus = false,
      this.discountAmount = 0,
      this.discountPresent = 0,
      this.couponAmount = 0,
      this.totalPrice = 0,
      this.couponCode = '',
      this.courseDetails,
      this.paymentMethod = ''});

  CheckOut copyWith(
      {isLoading,
      isEnrollLoading,
      applyCouponLoading,
      couponValidStatus,
      discountAmount,
      discountPresent,
      couponAmount,
      totalPrice,
      couponCode,
      courseDetails,
      paymentMethod}) {
    return CheckOut(
      isLoading: isLoading ?? this.isLoading,
      isEnrollLoading: isEnrollLoading ?? this.isEnrollLoading,
      applyCouponLoading: applyCouponLoading ?? this.applyCouponLoading,
      couponValidStatus: couponValidStatus ?? this.couponValidStatus,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPresent: discountPresent ?? this.discountPresent,
      couponAmount: couponAmount ?? this.couponAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      courseDetails: courseDetails ?? this.courseDetails,
      couponCode: couponCode ?? this.couponCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  CheckOut _update(CheckOut state) {
    return CheckOut(
      isLoading: state.isLoading,
      isEnrollLoading: state.isEnrollLoading,
      applyCouponLoading: state.applyCouponLoading,
      couponValidStatus: state.couponValidStatus,
      discountAmount: state.discountAmount,
      discountPresent: state.discountPresent,
      couponAmount: state.couponAmount,
      totalPrice: state.totalPrice,
      courseDetails: state.courseDetails,
      couponCode: state.couponCode,
      paymentMethod: state.paymentMethod,
    );
  }
}

final checkoutController =
    StateNotifierProvider.autoDispose<CheckOutController, CheckOut>(
        (ref) => CheckOutController(CheckOut(), ref));
