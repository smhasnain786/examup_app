import 'package:ready_lms/config/app_color.dart';
import 'package:ready_lms/config/theme.dart';
import 'package:ready_lms/routes.dart';
import 'package:ready_lms/service/hive_service.dart';
import 'package:ready_lms/utils/context_less_nav.dart';
import 'package:ready_lms/view/more/component/info_box_card.dart';
import 'package:ready_lms/view/more/component/language.dart';
import 'package:ready_lms/view/more/component/mode.dart';
import 'package:ready_lms/generated/l10n.dart';
import 'package:ready_lms/utils/entensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Column(
        children: [
          24.ph,
          Row(
            children: [
              InfoBoxCard(
                  icon: 'assets/svg/ic_certificates.svg',
                  title: S.of(context).certificates,
                  color: colors(context).primaryColor ??
                      AppStaticColor.primaryColor,
                  onTap: () {
                    context.nav.pushNamed(Routes.certificateScreen);
                  }),
              16.pw,
              Consumer(builder: (context, ref, _) {
                return InfoBoxCard(
                    icon: 'assets/svg/ic_notification.svg',
                    title: S.of(context).notifications,
                    color: AppStaticColor.orangeColor,
                    showNotification:
                        ref.read(hiveStorageProvider).isGuest() ? false : true,
                    onTap: () {});
              })
            ],
          ),
          16.ph,
          LanguageCard(),
          16.ph,
          const ModeCard(),
          16.ph,
        ],
      ),
    );
  }
}
